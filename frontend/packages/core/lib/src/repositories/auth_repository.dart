import '../api/api_client.dart';
import '../api/api_error.dart';
import '../models/user.dart';
import '../storage/token_storage.dart';

/// Autentikasi pelapor: `/auth/*`, `/me`, dan profil `/reporter/profile`.
class AuthRepository {
  AuthRepository(this._api, this._tokens);

  final ApiClient _api;
  final TokenStorage _tokens;

  static const deviceName = 'MeDrive Android';

  Future<bool> hasToken() async => (await _tokens.read()) != null;

  Future<AuthSession> login({required String email, required String password}) async {
    final response = await _api.post(
      '/auth/login',
      data: {'email': email.trim(), 'password': password, 'device_name': deviceName},
    );
    return _startSession(response.data);
  }

  Future<AuthSession> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _api.post('/auth/register', data: {
      'name': name.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'password': password,
      'password_confirmation': passwordConfirmation,
      'device_name': deviceName,
    });
    return _startSession(response.data);
  }

  Future<AppUser> me() async {
    final response = await _api.get('/me');
    return AppUser.fromJson(_map(response.data));
  }

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _api.post('/auth/change-password', data: {
      'current_password': currentPassword,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }

  Future<AppUser> updateProfile({required String name, required String phone}) async {
    final response = await _api.put('/reporter/profile', data: {'name': name.trim(), 'phone': phone.trim()});
    return AppUser.fromJson(_map(response.data));
  }

  /// Daftarkan token FCM perangkat (upsert di server).
  Future<void> registerDevice({required String fcmToken, String? deviceModel, String? appVersion}) async {
    await _api.post('/auth/fcm', data: {
      'fcm_token': fcmToken,
      'platform': 'android',
      'device_model': ?deviceModel,
      'app_version': ?appVersion,
    });
  }

  /// Cabut token di server (bila masih bisa) lalu hapus token lokal.
  Future<void> logout() async {
    try {
      if (await hasToken()) {
        await _api.post('/auth/logout');
      }
    } on ApiError {
      // Token mungkin sudah tidak berlaku; sesi lokal tetap dihapus.
    } finally {
      await _tokens.clear();
    }
  }

  Future<void> clearLocalSession() => _tokens.clear();

  Future<AuthSession> _startSession(Object? data) async {
    final session = AuthSession.fromJson(_map(data));

    // Aplikasi ini hanya untuk pelapor; akun driver memakai aplikasi MeDrive Driver.
    if (!session.user.isReporter) {
      try {
        await _api.post('/auth/logout', headers: {'Authorization': 'Bearer ${session.token}'});
      } on ApiError {
        // Token dibiarkan kedaluwarsa di server; yang penting tidak disimpan di perangkat.
      }
      throw const ApiError(
        code: 'wrong_app',
        message: 'Akun ini bukan akun pelapor. Driver memakai aplikasi MeDrive Driver.',
      );
    }

    await _tokens.write(session.token);
    return session;
  }

  static Map<String, dynamic> _map(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw const ApiError(code: 'invalid_response', message: 'Respons server tidak dikenali. Coba lagi.');
  }
}
