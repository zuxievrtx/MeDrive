# medrive_core

Lapisan data bersama aplikasi pelapor dan (nanti) aplikasi driver:

- `AppConfig` dari `--dart-define`, `ApiClient` (Dio) dengan `ApiError`, logout global saat 401, retry jaringan 1×.
- `TokenStorage` (flutter_secure_storage), repository auth/laporan/chat/geocode.
- Model freezed + json_serializable sesuai resource Laravel.
- `RealtimeService` (Reverb / protokol Pusher, kanal privat via `/api/v1/broadcasting/auth`).
- `PushService` (FCM + notifikasi lokal, aman tanpa konfigurasi Firebase).

Setelah mengubah model: `dart run build_runner build -d` dari folder ini.
