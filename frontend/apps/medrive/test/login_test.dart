import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive/features/auth/login_screen.dart';
import 'package:medrive/state/session.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

import 'helpers.dart';

void main() {
  late FakeBackend backend;
  late ProviderContainer container;

  Future<void> pumpLogin(WidgetTester tester) async {
    container = ProviderContainer(overrides: backend.overrides(), retry: (_, _) => null);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: buildMedTheme(), home: const LoginScreen()),
      ),
    );
  }

  Future<void> submit(WidgetTester tester, {required String email, required String password}) async {
    await tester.enterText(find.descendant(of: find.byKey(const Key('login-email')), matching: find.byType(TextField)), email);
    await tester.enterText(
      find.descendant(of: find.byKey(const Key('login-password')), matching: find.byType(TextField)),
      password,
    );
    await tester.ensureVisible(find.byKey(const Key('login-submit')));
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
  }

  testWidgets('login berhasil menyimpan token dan membuka sesi pelapor', (tester) async {
    backend = FakeBackend((request) {
      if (request.uri.path == '/api/v1/auth/login') {
        return ok({'token': 'token-pelapor', 'token_type': 'Bearer', 'must_change_password': false, 'user': reporterJson});
      }
      return apiError('not_found', 'Tidak ditemukan.', 404);
    });
    await pumpLogin(tester);

    await submit(tester, email: 'budi@medrive.test', password: 'password123');

    final body = backend.to('POST', '/auth/login').single.data as Map<String, dynamic>;
    expect(body['email'], 'budi@medrive.test');
    expect(body['password'], 'password123');

    final session = container.read(sessionProvider);
    expect(session.status, SessionStatus.authenticated);
    expect(session.user?.name, 'Budi Santoso');
    expect(await container.read(tokenStorageProvider).read(), 'token-pelapor');
    expect(find.byKey(const Key('login-error')), findsNothing);
  });

  testWidgets('login gagal menampilkan pesan server dan sesi tetap keluar', (tester) async {
    backend = FakeBackend((_) => apiError('invalid_credentials', 'Email atau password salah.', 401));
    await pumpLogin(tester);

    await submit(tester, email: 'budi@medrive.test', password: 'salah-sandi');

    expect(find.byKey(const Key('login-error')), findsOneWidget);
    expect(find.text('Email atau password salah.'), findsOneWidget);
    expect(container.read(sessionProvider).status, isNot(SessionStatus.authenticated));
    expect(await container.read(tokenStorageProvider).read(), isNull);
  });

  testWidgets('validasi klien menahan permintaan bila field kosong', (tester) async {
    backend = FakeBackend((_) => apiError('unexpected', 'Tidak boleh dipanggil.', 500));
    await pumpLogin(tester);

    await tester.ensureVisible(find.byKey(const Key('login-submit')));
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Masukkan email yang valid.'), findsOneWidget);
    expect(find.text('Kata sandi wajib diisi.'), findsOneWidget);
    expect(backend.requests, isEmpty);
    expect(container.read(sessionProvider).status, isNot(SessionStatus.authenticated));
  });

  test('ApiError login memakai pesan berbahasa Indonesia dari server', () {
    final error = ApiError.fromResponseBody({
      'success': false,
      'error': {'code': 'invalid_credentials', 'message': 'Email atau password salah.'},
    }, 401);
    expect(error.isUnauthenticated, isTrue);
    expect(error.message, 'Email atau password salah.');
  });
}
