/// Konfigurasi lingkungan dari `--dart-define`. Default menunjuk backend lokal yang dibuka dari
/// emulator Android (10.0.2.2 = localhost komputer pengembang).
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.wsUrl,
    required this.wsKey,
    this.firebase,
  });

  factory AppConfig.fromEnvironment() {
    const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000');
    const wsUrl = String.fromEnvironment('WS_URL', defaultValue: 'ws://10.0.2.2:8080');
    const wsKey = String.fromEnvironment('WS_KEY', defaultValue: 'medrive-local-key');

    return AppConfig(
      apiBaseUrl: _trimSlash(apiBaseUrl),
      wsUrl: _trimSlash(wsUrl),
      wsKey: wsKey,
      firebase: FirebaseConfig.fromEnvironment(),
    );
  }

  /// Contoh: `https://medrive.example.id` (tanpa `/api/v1`).
  final String apiBaseUrl;

  /// Contoh: `wss://medrive.example.id:443` (host Reverb, tanpa path).
  final String wsUrl;

  /// Nilai `REVERB_APP_KEY` di backend.
  final String wsKey;

  /// Opsional: konfigurasi Firebase tanpa google-services.json.
  final FirebaseConfig? firebase;

  String get apiV1 => '$apiBaseUrl/api/v1';

  String get broadcastingAuthUrl => '$apiV1/broadcasting/auth';

  static String _trimSlash(String value) => value.endsWith('/') ? value.substring(0, value.length - 1) : value;
}

/// Opsi Firebase lewat `--dart-define` (FIREBASE_API_KEY, FIREBASE_APP_ID, FIREBASE_PROJECT_ID,
/// FIREBASE_SENDER_ID). Bila kosong, aplikasi mencoba konfigurasi dari google-services.json.
class FirebaseConfig {
  const FirebaseConfig({
    required this.apiKey,
    required this.appId,
    required this.projectId,
    required this.messagingSenderId,
  });

  static FirebaseConfig? fromEnvironment() {
    const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
    const appId = String.fromEnvironment('FIREBASE_APP_ID');
    const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
    const senderId = String.fromEnvironment('FIREBASE_SENDER_ID');

    if (apiKey.isEmpty || appId.isEmpty || projectId.isEmpty || senderId.isEmpty) {
      return null;
    }

    return const FirebaseConfig(apiKey: apiKey, appId: appId, projectId: projectId, messagingSenderId: senderId);
  }

  final String apiKey;
  final String appId;
  final String projectId;
  final String messagingSenderId;
}
