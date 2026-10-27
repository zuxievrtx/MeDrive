import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/api_error.dart';
import '../models/driver.dart' show formatIsoWithOffset;

/// Satu titik GPS dari perangkat.
@immutable
class LocationFix {
  const LocationFix({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracyM,
    this.altitudeM,
    this.speedMps,
    this.heading,
    this.provider = 'fused',
    this.isMock = false,
  });

  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? accuracyM;
  final double? altitudeM;

  /// Kecepatan meter/detik dari GPS (negatif = tidak diketahui).
  final double? speedMps;

  /// Arah gerak derajat dari utara (negatif = tidak diketahui).
  final double? heading;

  /// `gps`, `network`, atau `fused` (nilai yang diterima backend).
  final String provider;
  final bool isMock;
}

/// Sumber lokasi perangkat. Implementasi Android (geolocator + foreground service) ada di
/// aplikasi driver; test memakai sumber palsu.
abstract class LocationSource {
  /// Aliran titik kira-kira tiap [interval]. Dipanggil ulang saat interval berubah.
  Stream<LocationFix> watch({required Duration interval});
}

abstract class BatteryReader {
  /// Persen baterai 0-100, atau null bila tidak terbaca.
  Future<int?> level();
}

/// Antrean titik yang gagal terkirim, bertahan saat aplikasi ditutup.
abstract class PingQueueStore {
  Future<List<Map<String, dynamic>>> load();

  Future<void> save(List<Map<String, dynamic>> points);
}

class MemoryPingQueueStore implements PingQueueStore {
  List<Map<String, dynamic>> points = [];

  @override
  Future<List<Map<String, dynamic>>> load() async => [...points];

  @override
  Future<void> save(List<Map<String, dynamic>> points) async => this.points = [...points];
}

/// Antrean di berkas JSON (mis. di direktori dokumen aplikasi).
class FilePingQueueStore implements PingQueueStore {
  FilePingQueueStore(this.file);

  final File file;

  @override
  Future<List<Map<String, dynamic>>> load() async {
    try {
      if (!await file.exists()) {
        return [];
      }
      final decoded = jsonDecode(await file.readAsString());
      return decoded is List ? decoded.whereType<Map<String, dynamic>>().toList() : [];
    } on Object {
      return [];
    }
  }

  @override
  Future<void> save(List<Map<String, dynamic>> points) async {
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(points), flush: true);
    } on Object {
      // Antrean tetap ada di memori; disimpan lagi pada percobaan berikutnya.
    }
  }
}

/// Keadaan pengirim lokasi untuk UI (indikator GPS, antrean offline).
@immutable
class PingStatus {
  const PingStatus({
    this.running = false,
    this.lastFix,
    this.lastSentAt,
    this.buffered = 0,
    this.queued = 0,
    this.interval = LocationPingService.defaultInterval,
    this.batteryLevel,
    this.lastError,
    this.shiftClosed = false,
  });

  final bool running;
  final LocationFix? lastFix;
  final DateTime? lastSentAt;

  /// Titik di buffer memori yang belum dicoba dikirim.
  final int buffered;

  /// Titik di antrean offline (gagal terkirim, menunggu koneksi).
  final int queued;
  final Duration interval;
  final int? batteryLevel;
  final ApiError? lastError;

  /// Server membalas `409 no_open_shift`: pelacakan dihentikan.
  final bool shiftClosed;

  bool get hasFix => lastFix != null;

  PingStatus copyWith({
    bool? running,
    LocationFix? lastFix,
    DateTime? lastSentAt,
    int? buffered,
    int? queued,
    Duration? interval,
    int? batteryLevel,
    ApiError? lastError,
    bool clearError = false,
    bool? shiftClosed,
  }) =>
      PingStatus(
        running: running ?? this.running,
        lastFix: lastFix ?? this.lastFix,
        lastSentAt: lastSentAt ?? this.lastSentAt,
        buffered: buffered ?? this.buffered,
        queued: queued ?? this.queued,
        interval: interval ?? this.interval,
        batteryLevel: batteryLevel ?? this.batteryLevel,
        lastError: clearError ? null : (lastError ?? this.lastError),
        shiftClosed: shiftClosed ?? this.shiftClosed,
      );
}

/// Pengirim lokasi driver selama shift terbuka (`POST /driver/location`).
///
/// - **Batch**: titik ditampung di memori dan dikirim saat terkumpul [maxBatchPoints] titik atau
///   titik tertua berumur [maxBatchAge], mana yang lebih dulu. Tidak pernah satu permintaan per
///   titik di luar aturan itu.
/// - **Interval adaptif**: jarak antar titik mengikuti `next_interval_seconds` dari respons
///   server (standby ±25 dtk, bertugas ±5 dtk, diam ±60 dtk). Klien hanya mengambil titik lebih
///   awal bila sudah berpindah ≥ [distanceFilterM] meter.
/// - **Antrean offline**: batch yang gagal karena jaringan/server masuk antrean (maks
///   [maxQueuedPoints] titik, FIFO), disimpan di [store], dan dikirim lebih dulu saat koneksi
///   pulih. Titik yang lebih tua dari [retention] dibuang karena ditolak server.
class LocationPingService {
  LocationPingService({
    required this._api,
    required this._source,
    this._battery,
    PingQueueStore? store,
    this._device,
    this.maxBatchPoints = 10,
    this.maxBatchAge = const Duration(seconds: 15),
    this.distanceFilterM = 50,
    this.maxQueuedPoints = 200,
    this.retention = const Duration(days: 14),
    this.retryDelay = const Duration(seconds: 15),
    Duration initialInterval = defaultInterval,
  })  : _store = store ?? MemoryPingQueueStore(),
        _interval = initialInterval;

  /// Interval standby bawaan server, dipakai sampai respons pertama datang.
  static const defaultInterval = Duration(seconds: 25);

  static const path = '/driver/location';

  final ApiClient _api;
  final LocationSource _source;
  final BatteryReader? _battery;
  final PingQueueStore _store;
  final Map<String, dynamic>? Function()? _device;

  int maxBatchPoints;
  Duration maxBatchAge;
  int distanceFilterM;
  final int maxQueuedPoints;
  final Duration retention;
  final Duration retryDelay;

  Duration _interval;
  final status = ValueNotifier<PingStatus>(const PingStatus());
  final _shiftClosed = StreamController<void>.broadcast();

  StreamSubscription<LocationFix>? _fixes;
  Timer? _sampleTimer;
  Timer? _flushTimer;
  LocationFix? _latest;
  LocationFix? _lastCaptured;
  final _pending = <_Pending>[];
  final _queue = <Map<String, dynamic>>[];
  bool _running = false;
  bool _disposed = false;
  bool _sending = false;
  bool _flushRequested = false;
  int? _batteryLevel;

  Duration get interval => _interval;

  bool get isRunning => _running;

  /// Dipancarkan saat server menyatakan shift sudah tertutup.
  Stream<void> get onShiftClosed => _shiftClosed.stream;

  /// Titik yang belum dikirim (buffer + antrean), urut lama → baru. Untuk test dan diagnosa.
  List<Map<String, dynamic>> get unsentPoints => [..._queue, for (final item in _pending) item.point];

  Future<void> start() async {
    if (_running || _disposed) {
      return;
    }
    _running = true;
    _queue
      ..clear()
      ..addAll(await _store.load());
    _purgeExpired();
    _publish(running: true, shiftClosed: false);
    unawaited(_refreshBattery());
    _listen();
    if (_queue.isNotEmpty) {
      unawaited(flush());
    }
  }

  /// Hentikan pelacakan. [flushPending] mencoba mengirim sisa buffer sekali (mis. saat shift ditutup
  /// sendiri, titik terakhir masih berguna di riwayat).
  Future<void> stop({bool flushPending = false}) async {
    if (!_running) {
      return;
    }
    if (flushPending && (_pending.isNotEmpty || _queue.isNotEmpty)) {
      await flush();
    }
    _running = false;
    // Tidak di-await: pembatalan langganan GPS tidak perlu ditunggu untuk berhenti mengirim.
    unawaited(_fixes?.cancel());
    _fixes = null;
    _sampleTimer?.cancel();
    _sampleTimer = null;
    _flushTimer?.cancel();
    _flushTimer = null;
    _latest = null;
    _lastCaptured = null;
    _publish(running: false);
  }

  void _listen() {
    unawaited(_fixes?.cancel());
    _fixes = _source.watch(interval: _interval).listen(_onFix, onError: (Object _) {});
    _restartSampleTimer();
  }

  void _restartSampleTimer() {
    _sampleTimer?.cancel();
    _sampleTimer = Timer.periodic(_interval, (_) {
      final latest = _latest;
      if (latest != null) {
        _capture(latest);
      }
    });
  }

  void _onFix(LocationFix fix) {
    if (!_running) {
      return;
    }
    _latest = fix;
    final previous = _lastCaptured;
    if (previous == null) {
      _capture(fix);
      _restartSampleTimer();
    } else if (distanceMeters(previous.latitude, previous.longitude, fix.latitude, fix.longitude) >= distanceFilterM) {
      // Berpindah cukup jauh: ambil titik sekarang tanpa menunggu interval berikutnya.
      _capture(fix);
      _restartSampleTimer();
    } else {
      _publish(lastFix: fix);
    }
  }

  void _capture(LocationFix fix) {
    // Titik yang sama diambil ulang (perangkat diam, GPS tidak memberi titik baru): tandai waktu
    // sekarang agar server tahu driver masih aktif tanpa membuat titik "lama".
    final recordedAt = identical(fix, _lastCaptured) ? clock.now() : fix.timestamp;
    _lastCaptured = fix;
    _pending.add(_Pending(_toPoint(fix, recordedAt), clock.now()));
    unawaited(_refreshBattery());
    _publish(lastFix: fix);

    if (_pending.length >= maxBatchPoints) {
      _flushTimer?.cancel();
      _flushTimer = null;
      unawaited(flush());
    } else if (_flushTimer == null) {
      final age = clock.now().difference(_pending.first.capturedAt);
      _scheduleFlush(maxBatchAge - age);
    }
  }

  Map<String, dynamic> _toPoint(LocationFix fix, DateTime recordedAt) {
    final speed = fix.speedMps;
    final heading = fix.heading;
    final accuracy = fix.accuracyM;

    return {
      'latitude': fix.latitude,
      'longitude': fix.longitude,
      'accuracy_m': accuracy != null && accuracy >= 0 ? _round(accuracy, 1) : null,
      'altitude_m': fix.altitudeM == null ? null : _round(fix.altitudeM!, 1),
      'speed_kmh': speed != null && speed >= 0 ? _round(math.min(speed * 3.6, 999), 1) : null,
      'heading': heading != null && heading >= 0 ? heading.round() % 360 : null,
      'battery_level': _batteryLevel,
      'provider': fix.provider,
      'is_mock_location': fix.isMock,
      'recorded_at': formatIsoWithOffset(recordedAt),
    };
  }

  static double _round(double value, int digits) {
    final factor = math.pow(10, digits);
    return (value * factor).round() / factor;
  }

  Future<void> _refreshBattery() async {
    final battery = _battery;
    if (battery == null) {
      return;
    }
    try {
      final level = await battery.level();
      if (level != null && level >= 0 && level <= 100) {
        _batteryLevel = level;
        _publish();
      }
    } on Object {
      // Baterai tidak terbaca; titik dikirim tanpa battery_level.
    }
  }

  void _scheduleFlush(Duration delay) {
    _flushTimer?.cancel();
    _flushTimer = Timer(delay.isNegative ? Duration.zero : delay, () {
      _flushTimer = null;
      unawaited(flush());
    });
  }

  /// Kirim buffer + antrean sekarang (dipakai timer batch, saat aplikasi kembali online, dan test).
  Future<void> flush() async {
    if (_sending) {
      _flushRequested = true;
      return;
    }
    _sending = true;
    try {
      do {
        _flushRequested = false;
        final keepGoing = await _sendOnce();
        if (!keepGoing) {
          break;
        }
      } while (_running && (_queue.isNotEmpty || _pending.length >= maxBatchPoints || _flushRequested));
    } finally {
      _sending = false;
    }

    if (_running && _pending.isNotEmpty && _flushTimer == null) {
      final age = clock.now().difference(_pending.first.capturedAt);
      _scheduleFlush(maxBatchAge - age);
    }
  }

  /// Satu permintaan berisi maks [maxBatchPoints] titik (antrean lama lebih dulu).
  /// Hasil `false` = berhenti mengirim untuk sekarang.
  Future<bool> _sendOnce() async {
    _purgeExpired();
    final fromQueue = math.min(_queue.length, maxBatchPoints);
    final fromPending = math.min(_pending.length, maxBatchPoints - fromQueue);
    if (fromQueue + fromPending == 0) {
      return false;
    }

    final points = [
      ..._queue.take(fromQueue),
      for (final item in _pending.take(fromPending)) item.point,
    ];
    final sentPending = _pending.sublist(0, fromPending);
    _pending.removeRange(0, fromPending);

    try {
      final response = await _api.post(path, data: {'points': points, 'device': ?_device?.call()});
      _queue.removeRange(0, fromQueue);
      if (fromQueue > 0) {
        await _store.save(_queue);
      }
      _applyServerRules(response.data);
      _publish(lastSentAt: clock.now(), clearError: true);
      return true;
    } on ApiError catch (error) {
      if (error.code == 'no_open_shift') {
        _queue.clear();
        _pending.clear();
        await _store.save(_queue);
        _publish(lastError: error, shiftClosed: true);
        _shiftClosed.add(null);
        await stop();
        return false;
      }
      if (error.isUnauthenticated || error.isValidation || error.statusCode == 403) {
        // Tidak akan pernah diterima: titik dibuang agar antrean tidak macet.
        _queue.removeRange(0, fromQueue);
        await _store.save(_queue);
        _publish(lastError: error);
        return !error.isUnauthenticated && error.statusCode != 403;
      }

      // Jaringan putus, server sibuk (5xx), atau dibatasi (429): simpan ke antrean offline.
      _enqueue([for (final item in sentPending) item.point]);
      await _store.save(_queue);
      _publish(lastError: error);
      if (_running) {
        _scheduleFlush(retryDelay);
      }
      return false;
    }
  }

  void _enqueue(List<Map<String, dynamic>> points) {
    _queue.addAll(points);
    if (_queue.length > maxQueuedPoints) {
      _queue.removeRange(0, _queue.length - maxQueuedPoints);
    }
  }

  void _purgeExpired() {
    final limit = clock.now().subtract(retention);
    _queue.removeWhere((point) {
      final recordedAt = DateTime.tryParse('${point['recorded_at']}');
      return recordedAt == null || recordedAt.isBefore(limit);
    });
  }

  void _applyServerRules(Object? data) {
    if (data is! Map) {
      return;
    }
    final points = (data['max_batch_points'] as num?)?.toInt();
    if (points != null && points > 0) {
      maxBatchPoints = points;
    }
    final age = (data['max_batch_age_seconds'] as num?)?.toInt();
    if (age != null && age > 0) {
      maxBatchAge = Duration(seconds: age);
    }
    final filter = (data['distance_filter_m'] as num?)?.toInt();
    if (filter != null && filter > 0) {
      distanceFilterM = filter;
    }
    final next = (data['next_interval_seconds'] as num?)?.toInt();
    if (next != null && next > 0 && Duration(seconds: next) != _interval) {
      _interval = Duration(seconds: next);
      if (_running) {
        _listen();
      }
    }
  }

  void _publish({
    bool? running,
    LocationFix? lastFix,
    DateTime? lastSentAt,
    ApiError? lastError,
    bool clearError = false,
    bool? shiftClosed,
  }) {
    if (_disposed) {
      return;
    }
    status.value = status.value.copyWith(
      running: running,
      lastFix: lastFix,
      lastSentAt: lastSentAt,
      buffered: _pending.length,
      queued: _queue.length,
      interval: _interval,
      batteryLevel: _batteryLevel,
      lastError: lastError,
      clearError: clearError,
      shiftClosed: shiftClosed,
    );
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    await stop();
    _disposed = true;
    await _shiftClosed.close();
    status.dispose();
  }
}

class _Pending {
  _Pending(this.point, this.capturedAt);

  final Map<String, dynamic> point;
  final DateTime capturedAt;
}

/// Jarak haversine dalam meter.
double distanceMeters(double lat1, double lng1, double lat2, double lng2) {
  const earthRadius = 6371000.0;
  double rad(double degrees) => degrees * math.pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLng = rad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.sin(dLng / 2) * math.sin(dLng / 2);
  return earthRadius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}
