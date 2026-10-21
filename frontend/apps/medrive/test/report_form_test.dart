import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive/features/report/report_form_screen.dart';
import 'package:medrive_ui/medrive_ui.dart';

import 'helpers.dart';

void main() {
  late FakeBackend backend;

  setUpAll(initMedFormats);

  ResponseBody respond(RequestOptions request) => switch ((request.method, request.uri.path)) {
        // Endpoint jenis laporan belum ada di backend: aplikasi memakai katalog bawaan.
        ('GET', '/api/v1/reporter/report-types') => apiError('not_found', 'Tidak ditemukan.', 404),
        ('POST', '/api/v1/reporter/reports') => ok({
            'id': 9,
            'code': 'MDR-261021-0009',
            'status': {'value': 'menunggu', 'label': 'Menunggu'},
            'latitude': -6.9902,
            'longitude': 110.4229,
          }, status: 201),
        _ => apiError('not_found', 'Tidak ditemukan.', 404),
      };

  Future<void> pumpForm(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/report/new/medis_darurat',
      routes: [
        GoRoute(
          path: '/report/new/:type',
          builder: (_, state) => ReportFormScreen(typeCode: state.pathParameters['type']!),
        ),
        GoRoute(
          path: '/report/:id/success',
          builder: (_, state) => Scaffold(body: Text('Sukses ${state.pathParameters['id']}')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: backend.overrides(token: 'token-pelapor'),
        retry: (_, _) => null,
        child: MaterialApp.router(theme: buildMedTheme(), routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapSubmit(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('report-submit')));
    await tester.pumpAndSettle();
  }

  testWidgets('form medis darurat terkirim multipart dengan Idempotency-Key lalu ke layar sukses', (tester) async {
    backend = FakeBackend(respond);
    await pumpForm(tester);

    expect(find.text('Laporan Medis Darurat'), findsOneWidget);

    await tester.ensureVisible(find.text('Stroke'));
    await tester.tap(find.text('Stroke'));
    await tester.pumpAndSettle();
    await tapSubmit(tester);

    final request = backend.to('POST', '/reporter/reports').single;
    expect(request.headers['Idempotency-Key'], matches(RegExp(r'^[0-9a-f-]{36}$')));
    expect(request.headers['Authorization'], 'Bearer token-pelapor');

    final fields = Map.fromEntries((request.data as FormData).fields);
    expect(fields['report_type_code'], 'medis_darurat');
    expect(fields['details[medical_category]'], 'stroke');
    expect(fields['latitude'], startsWith('-6.9902'));
    expect(fields['description'], contains('Stroke'));

    expect(find.text('Sukses 9'), findsOneWidget);
  });

  testWidgets('pilihan wajib kosong ditahan di aplikasi tanpa memanggil server', (tester) async {
    backend = FakeBackend(respond);
    await pumpForm(tester);

    await tapSubmit(tester);

    expect(backend.to('POST', '/reporter/reports'), isEmpty);
    expect(find.text('Pilih kondisi pasien.'), findsOneWidget);
  });

  testWidgets('error validasi server ditampilkan di field terkait', (tester) async {
    backend = FakeBackend((request) => request.method == 'POST'
        ? apiError('validation_failed', 'Data tidak valid.', 400, details: {
            'details.medical_category': ['Kategori medis tidak dikenal.'],
          })
        : respond(request));
    await pumpForm(tester);

    await tester.ensureVisible(find.text('Stroke'));
    await tester.tap(find.text('Stroke'));
    await tester.pumpAndSettle();
    await tapSubmit(tester);

    expect(backend.to('POST', '/reporter/reports'), hasLength(1));
    expect(find.text('Kategori medis tidak dikenal.'), findsOneWidget);
    expect(find.text('Sukses 9'), findsNothing);
  });
}
