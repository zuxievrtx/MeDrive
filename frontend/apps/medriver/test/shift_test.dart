import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medriver/features/home/home_screen.dart';
import 'package:medriver/services/location_ping.dart';
import 'package:medrive_ui/medrive_ui.dart';

import 'helpers.dart';

void main() {
  setUpAll(initMedFormats);

  testWidgets('buka shift: pilih ambulans, POST /driver/shifts, lalu beranda standby dengan nopol dari API', (tester) async {
    var shiftOpen = false;
    final backend = FakeBackend((request) {
      final path = request.uri.path;
      if (request.method == 'GET' && path == '/api/v1/driver/profile') {
        return ok(driverProfileJson(openShift: shiftOpen ? openShiftJson() : null));
      }
      if (request.method == 'GET' && path == '/api/v1/driver/ambulances/available') {
        return ok([ambulanceJson]);
      }
      if (request.method == 'POST' && path == '/api/v1/driver/shifts') {
        shiftOpen = true;
        return ok(openShiftJson(), status: 201);
      }
      if (request.method == 'GET' && path == '/api/v1/driver/dispatches/active') {
        return ok(<Object>[]);
      }
      return apiError('not_found', 'Tidak ditemukan.', 404);
    });

    final container = ProviderContainer(overrides: backend.overrides(), retry: (_, _) => null);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: buildMedTheme(), home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nonaktif'), findsOneWidget);
    expect(find.byKey(const Key('standby-banner')), findsNothing);

    await tester.tap(find.byKey(const Key('duty-toggle')));
    await tester.pumpAndSettle();

    // Bottom sheet pilih ambulans: tombol mulai nonaktif sampai ambulans dipilih.
    expect(find.text('Pilih ambulans'), findsOneWidget);
    await tester.tap(find.text('H 1234 KS'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-shift-submit')));
    await tester.pumpAndSettle();

    final body = backend.to('POST', '/driver/shifts').single.data as Map<String, dynamic>;
    expect(body['ambulance_id'], 7);
    expect(backend.requests.first.headers['Authorization'], 'Bearer token-driver');

    expect(find.text('Aktif'), findsOneWidget);
    expect(find.byKey(const Key('standby-banner')), findsOneWidget);
    expect(find.text('H 1234 KS'), findsOneWidget, reason: 'nopol dari open_shift API, bukan hardcode');
    expect(container.read(locationPingProvider).isRunning, isTrue, reason: 'ping lokasi berjalan selama shift terbuka');

    await tester.pumpWidget(const SizedBox.shrink());
    await container.read(locationPingProvider).stop();
    container.dispose();
  });

  testWidgets('gagal membuka shift menampilkan pesan server di bottom sheet', (tester) async {
    final backend = FakeBackend((request) {
      final path = request.uri.path;
      if (path == '/api/v1/driver/profile') {
        return ok(driverProfileJson());
      }
      if (path == '/api/v1/driver/ambulances/available') {
        return ok([ambulanceJson]);
      }
      if (path == '/api/v1/driver/shifts') {
        return apiError('ambulance_in_use', 'Ambulans H 1234 KS baru saja dipakai driver lain.', 409);
      }
      return ok(<Object>[]);
    });

    final container = ProviderContainer(overrides: backend.overrides(), retry: (_, _) => null);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: buildMedTheme(), home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('duty-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('H 1234 KS'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-shift-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('open-shift-error')), findsOneWidget);
    expect(find.text('Ambulans H 1234 KS baru saja dipakai driver lain.'), findsOneWidget);
    expect(container.read(locationPingProvider).isRunning, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
  });
}
