import 'dart:async';

import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

/// Sumber GPS palsu: mencatat interval yang diminta dan memancarkan titik dari test.
class FakeLocationSource implements LocationSource {
  final intervals = <Duration>[];
  StreamController<LocationFix>? _controller;

  @override
  Stream<LocationFix> watch({required Duration interval}) {
    intervals.add(interval);
    _controller = StreamController<LocationFix>();
    return _controller!.stream;
  }

  void emit(LocationFix fix) => _controller!.add(fix);
}

class FixedBattery implements BatteryReader {
  @override
  Future<int?> level() async => 64;
}

/// Titik di Semarang; [northMeters] menggeser ke utara (±111 m per 0,001 derajat).
LocationFix fixAt(double northMeters, {bool mock = false}) => LocationFix(
      latitude: -6.9932 + northMeters / 111320,
      longitude: 110.4203,
      timestamp: clock.now(),
      accuracyM: 8.5,
      altitudeM: 12,
      speedMps: 9,
      heading: 270,
      provider: 'fused',
      isMock: mock,
    );

ApiResponse<dynamic> serverReply({int nextInterval = 25}) => ApiResponse<dynamic>(
      data: {
        'accepted': 1,
        'rejected': <Object>[],
        'next_interval_seconds': nextInterval,
        'distance_filter_m': 50,
        'max_batch_points': 10,
        'max_batch_age_seconds': 15,
        'server_time': '2026-10-24T10:00:00+07:00',
      },
    );

void main() {
  late MockApiClient api;
  late FakeLocationSource source;
  late MemoryPingQueueStore store;
  late List<ApiResponse<dynamic> Function()> replies;
  late List<List<Map<String, dynamic>>> sent;

  LocationPingService build({int maxQueued = 200}) => LocationPingService(
        api: api,
        source: source,
        battery: FixedBattery(),
        store: store,
        maxQueuedPoints: maxQueued,
      );

  /// Isi `points` setiap request POST /driver/location, urut waktu (termasuk yang gagal).
  List<List<Map<String, dynamic>>> sentBatches() => sent;

  setUp(() {
    api = MockApiClient();
    source = FakeLocationSource();
    store = MemoryPingQueueStore();
    replies = [];
    sent = [];
    when(() => api.post(any(), data: any(named: 'data'))).thenAnswer((invocation) async {
      expect(invocation.positionalArguments.first, LocationPingService.path);
      final data = invocation.namedArguments[#data] as Map;
      sent.add([...(data['points'] as List).cast<Map<String, dynamic>>()]);
      if (replies.isEmpty) {
        return serverReply();
      }
      return replies.removeAt(0)();
    });
  });

  group('batching', () {
    test('mengirim satu request berisi 10 titik begitu buffer penuh, bukan per titik', () {
      fakeAsync((async) {
        final service = build();
        unawaited(service.start());
        async.flushMicrotasks();

        // Sembilan titik, masing-masing berpindah 100 m: belum ada request.
        for (var index = 0; index < 9; index++) {
          source.emit(fixAt(index * 100.0));
          async.elapse(const Duration(milliseconds: 500));
        }
        verifyNever(() => api.post(any(), data: any(named: 'data')));

        source.emit(fixAt(900));
        async.flushMicrotasks();

        final batches = sentBatches();
        expect(batches, hasLength(1));
        expect(batches.single, hasLength(10));
        unawaited(service.stop());
        async.flushMicrotasks();
      });
    });

    test('titik tertua berumur 15 detik memicu pengiriman walau buffer belum penuh', () {
      fakeAsync((async) {
        final service = build();
        unawaited(service.start());
        async.flushMicrotasks();

        source.emit(fixAt(0, mock: true));
        async.elapse(const Duration(seconds: 14));
        verifyNever(() => api.post(any(), data: any(named: 'data')));

        async.elapse(const Duration(seconds: 1));
        final point = sentBatches().single.single;
        expect(point['latitude'], closeTo(-6.9932, 0.00001));
        expect(point['accuracy_m'], 8.5);
        expect(point['altitude_m'], 12.0);
        expect(point['speed_kmh'], 32.4);
        expect(point['heading'], 270);
        expect(point['battery_level'], 64);
        expect(point['provider'], 'fused');
        expect(point['is_mock_location'], isTrue);
        expect(point['recorded_at'], matches(RegExp(r'^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}[+-]\d\d:\d\d$')));
        unawaited(service.stop());
        async.flushMicrotasks();
      });
    });
  });

  group('interval adaptif', () {
    test('mengikuti next_interval_seconds dari server untuk jadwal titik berikutnya', () {
      fakeAsync((async) {
        replies
          ..add(() => serverReply(nextInterval: 5))
          ..add(() => serverReply(nextInterval: 5))
          ..add(() => serverReply(nextInterval: 60));
        final service = build();
        unawaited(service.start());
        async.flushMicrotasks();
        expect(source.intervals, [LocationPingService.defaultInterval]);

        // Standby 25 detik: titik pertama diambil, dikirim setelah 15 detik (umur batch).
        source.emit(fixAt(0));
        async.elapse(const Duration(seconds: 15));
        expect(service.interval, const Duration(seconds: 5));
        expect(source.intervals.last, const Duration(seconds: 5));

        // Bertugas 5 detik: titik diambil tiap 5 detik walau diam (detik 20, 25, 30) dan
        // ditampung sampai batch berumur 15 detik.
        async.elapse(const Duration(seconds: 19));
        expect(service.status.value.buffered, 3);
        expect(sentBatches(), hasLength(1));

        async.elapse(const Duration(seconds: 2));
        final batches = sentBatches();
        expect(batches.last.length, inInclusiveRange(3, 4));

        // Server menaikkan ke 60 detik (driver diam): sumber GPS dijadwal ulang.
        async.elapse(const Duration(seconds: 20));
        expect(service.interval, const Duration(seconds: 60));
        expect(source.intervals.last, const Duration(seconds: 60));
        unawaited(service.stop());
        async.flushMicrotasks();
      });
    });

    test('berpindah lebih dari 50 m mengambil titik lebih awal dari interval', () {
      fakeAsync((async) {
        final service = build();
        unawaited(service.start());
        async.flushMicrotasks();

        source.emit(fixAt(0));
        source.emit(fixAt(20)); // di bawah 50 m: tidak menjadi titik baru
        source.emit(fixAt(80)); // 80 m dari titik terakhir: diambil sekarang
        async.elapse(const Duration(seconds: 15));

        expect(sentBatches().single, hasLength(2));
        unawaited(service.stop());
        async.flushMicrotasks();
      });
    });
  });

  group('antrean offline', () {
    test('batch yang gagal karena jaringan disimpan lalu dikirim lebih dulu saat online', () {
      fakeAsync((async) {
        replies.add(() => throw const ApiError(code: ApiError.networkError, message: 'Tidak ada koneksi internet.'));
        final service = build();
        unawaited(service.start());
        async.flushMicrotasks();

        source.emit(fixAt(0));
        async.elapse(const Duration(seconds: 15));
        expect(store.points, hasLength(1));
        expect(service.status.value.queued, 1);

        // Titik baru masuk saat masih offline, lalu koneksi pulih pada percobaan ulang.
        source.emit(fixAt(200));
        async.elapse(const Duration(seconds: 15));

        final batches = sentBatches();
        expect(batches, hasLength(2));
        expect(batches.last, hasLength(2));
        expect(batches.last.first['latitude'], closeTo(-6.9932, 0.00001), reason: 'titik antrean lama dikirim lebih dulu');
        expect(store.points, isEmpty);
        expect(service.status.value.queued, 0);
        unawaited(service.stop());
        async.flushMicrotasks();
      });
    });

    test('antrean dibatasi FIFO dan titik lebih tua dari 14 hari dibuang', () {
      fakeAsync((async) {
        final now = clock.now();
        store.points = [
          {'latitude': 1.0, 'longitude': 1.0, 'recorded_at': formatIsoWithOffset(now.subtract(const Duration(days: 15)))},
          {'latitude': 2.0, 'longitude': 2.0, 'recorded_at': formatIsoWithOffset(now.subtract(const Duration(days: 2)))},
        ];
        replies
          ..add(() => throw const ApiError(code: 'http_error', message: 'Server sedang bermasalah.', statusCode: 503))
          ..add(() => throw const ApiError(code: 'http_error', message: 'Server sedang bermasalah.', statusCode: 503));
        final service = build(maxQueued: 3);
        unawaited(service.start());
        async.flushMicrotasks();

        // Titik 15 hari dibuang saat dimuat; titik 2 hari tetap dicoba (gagal 503).
        expect(sentBatches().single.map((point) => point['latitude']), [2.0]);

        for (var index = 0; index < 4; index++) {
          source.emit(fixAt(index * 100.0));
        }
        async.elapse(const Duration(seconds: 15));

        // Gagal lagi: antrean penuh 3 titik, titik paling lama terbuang lebih dulu.
        expect(store.points, hasLength(3));
        expect(store.points.any((point) => point['latitude'] == 2.0), isFalse);
        unawaited(service.stop());
        async.flushMicrotasks();
      });
    });

    test('409 no_open_shift menghentikan pelacakan dan mengosongkan antrean', () {
      fakeAsync((async) {
        replies.add(
          () => throw const ApiError(code: 'no_open_shift', message: 'Lokasi hanya dikirim selama shift terbuka.', statusCode: 409),
        );
        final service = build();
        var closed = false;
        service.onShiftClosed.listen((_) => closed = true);
        unawaited(service.start());
        async.flushMicrotasks();

        source.emit(fixAt(0));
        async.elapse(const Duration(seconds: 15));

        expect(closed, isTrue);
        expect(service.isRunning, isFalse);
        expect(service.status.value.shiftClosed, isTrue);
        expect(store.points, isEmpty);
      });
    });
  });
}
