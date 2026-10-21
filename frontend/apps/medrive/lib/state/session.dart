import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medrive_core/medrive_core.dart';

enum SessionStatus { unknown, unauthenticated, authenticated }

@immutable
class SessionState {
  const SessionState({required this.status, this.user});

  const SessionState.unknown() : this(status: SessionStatus.unknown);

  const SessionState.signedOut() : this(status: SessionStatus.unauthenticated);

  final SessionStatus status;
  final AppUser? user;

  bool get mustChangePassword => user?.mustChangePassword ?? false;
}

/// Sesi pelapor: status login, profil, dan efek samping saat masuk/keluar (FCM, WebSocket).
class SessionController extends Notifier<SessionState> {
  StreamSubscription<void>? _unauthorized;

  @override
  SessionState build() {
    _unauthorized = ref.watch(apiClientProvider).onUnauthorized.listen((_) => unawaited(_signOutLocally()));
    ref.onDispose(() => _unauthorized?.cancel());
    return const SessionState.unknown();
  }

  AuthRepository get _auth => ref.read(authRepositoryProvider);

  /// Dipanggil splash: token tersimpan → ambil profil; selain itu ke layar masuk.
  Future<void> bootstrap() async {
    if (!await _auth.hasToken()) {
      state = const SessionState.signedOut();
      return;
    }

    try {
      final user = await _auth.me();
      if (!user.isReporter) {
        await _auth.logout();
        state = const SessionState.signedOut();
        return;
      }
      _authenticated(user);
    } on ApiError catch (error) {
      if (!error.isUnauthenticated) {
        // Splash menampilkan pesan + tombol coba lagi (mis. offline saat aplikasi dibuka).
        rethrow;
      }
      await _auth.clearLocalSession();
      state = const SessionState.signedOut();
    }
  }

  Future<void> login({required String email, required String password}) async {
    final session = await _auth.login(email: email, password: password);
    _authenticated(session.user.copyWith(mustChangePassword: session.mustChangePassword));
  }

  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final session = await _auth.register(
      name: name,
      phone: phone,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    _authenticated(session.user);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _auth.changePassword(
      currentPassword: currentPassword,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    final user = state.user;
    if (user != null) {
      state = SessionState(status: SessionStatus.authenticated, user: user.copyWith(mustChangePassword: false));
    }
  }

  Future<void> updateProfile({required String name, required String phone}) async {
    final user = await _auth.updateProfile(name: name, phone: phone);
    state = SessionState(status: SessionStatus.authenticated, user: user);
  }

  Future<void> logout() async {
    await ref.read(pushServiceProvider).unregister();
    await _auth.logout();
    await _signOutLocally();
  }

  void _authenticated(AppUser user) {
    state = SessionState(status: SessionStatus.authenticated, user: user);

    final push = ref.read(pushServiceProvider);
    unawaited(push.registerToken((token) => _auth.registerDevice(fcmToken: token, deviceModel: 'Android', appVersion: appVersion)));
  }

  Future<void> _signOutLocally() async {
    await ref.read(realtimeServiceProvider).disconnect();
    await _auth.clearLocalSession();
    state = const SessionState.signedOut();
  }
}

final sessionProvider = NotifierProvider<SessionController, SessionState>(SessionController.new);

/// Versi aplikasi untuk layar profil dan registrasi perangkat.
const appVersion = String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');
