import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medriver/features/offer/offer_screen.dart';
import 'package:medriver/services/location_ping.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

import 'helpers.dart';

void main() {
  setUpAll(initMedFormats);

  late FakeAlarm alarm;
  late ProviderContainer container;

  Future<void> pumpOffer(WidgetTester tester, FakeBackend backend) async {
    alarm = FakeAlarm();
    container = ProviderContainer(overrides: backend.overrides(alarm: alarm), retry: (_, _) => null);
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const Scaffold(body: Text('STANDBY'))),
        GoRoute(path: '/offer/:id', builder: (_, state) => OfferScreen(dispatchId: int.parse(state.pathParameters['id']!))),
        GoRoute(path: '/mission/:id', builder: (_, state) => Scaffold(body: Text('MISI ${state.pathParameters['id']}'))),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: buildMedTheme(), routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    unawaited(router.push('/offer/55'));
    await tester.pumpAndSettle();
  }

  Future<void> cleanUp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await container.read(locationPingProvider).stop();
    container.dispose();
  }

  ResponseBodyHandler handler({required bool win}) => (request) {
        final path = request.uri.path;
        if (request.method == 'GET' && path == '/api/v1/driver/dispatches/55') {
          return ok(dispatchJson());
        }
        if (request.method == 'POST' && path == '/api/v1/driver/dispatches/55/accept') {
          return win ? ok(reportJson(status: 'diambil')) : apiError('too_late', 'Laporan sudah diambil driver lain.', 409);
        }
        if (path == '/api/v1/driver/profile') {
          return ok(driverProfileJson(openShift: openShiftJson(), onDuty: win));
        }
        if (path == '/api/v1/driver/reports/history') {
          return ok([reportJson(status: 'diambil')]);
        }
        return apiError('not_found', 'Tidak ditemukan.', 404);
      };

  testWidgets('tawaran tampil dengan alarm; TERIMA menang membuka layar misi', (tester) async {
    final backend = FakeBackend(handler(win: true));
    await pumpOffer(tester, backend);

    expect(find.text('Laporan darurat masuk'), findsOneWidget);
    expect(find.text('Kecelakaan'), findsOneWidget);
    expect(find.text('MDR-261024-0007'), findsOneWidget);
    expect(find.text('2,4 km'), findsOneWidget);
    expect(alarm.started, [55]);

    await tester.tap(find.byKey(const Key('offer-accept')));
    await tester.pumpAndSettle();

    final accept = backend.to('POST', '/driver/dispatches/55/accept').single;
    expect(accept.headers[ApiClient.idempotencyHeader], isNotEmpty);
    expect(find.text('MISI 90'), findsOneWidget);
    expect(alarm.stopped, contains(55));

    await cleanUp(tester);
  });

  testWidgets('kalah cepat (409 too_late) menampilkan pesan lalu kembali ke standby', (tester) async {
    final backend = FakeBackend(handler(win: false));
    await pumpOffer(tester, backend);

    await tester.tap(find.byKey(const Key('offer-accept')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('offer-lost')), findsOneWidget);
    expect(find.text('Kalah cepat'), findsOneWidget);
    expect(find.textContaining('driver lain lebih dulu'), findsOneWidget);
    expect(alarm.stopped, contains(55));
    expect(find.text('MISI 90'), findsNothing);

    await tester.tap(find.text('Kembali ke standby'));
    await tester.pumpAndSettle();
    expect(find.text('STANDBY'), findsOneWidget);

    await cleanUp(tester);
  });

  testWidgets('Abaikan hanya menutup tawaran di perangkat tanpa memanggil server', (tester) async {
    final backend = FakeBackend(handler(win: true));
    await pumpOffer(tester, backend);

    await tester.tap(find.byKey(const Key('offer-dismiss')));
    await tester.pumpAndSettle();

    expect(find.text('STANDBY'), findsOneWidget);
    expect(backend.to('POST', '/driver/dispatches/55/accept'), isEmpty);
    expect(alarm.stopped, contains(55));

    await cleanUp(tester);
  });
}
