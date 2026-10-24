# MeDrive: Frontend (Flutter)

Monorepo Flutter dengan **pub workspaces** (tanpa melos):

```
frontend/
├── pubspec.yaml            # root workspace
├── apps/medrive/           # aplikasi pelapor (Android, com.medrive.pelapor)
├── apps/medriver/          # aplikasi driver MeDriveR (Android, com.medrive.driver)
├── packages/core/          # medrive_core: config, ApiClient, model, repository, WebSocket, FCM
├── packages/ui/            # medrive_ui: token desain, tema, widget bersama, peta OSM
├── design/                 # ekspor Figma (pelapor/, driver/)
└── ASSUMPTIONS.md          # keputusan & penyimpangan dari prompt/Figma
```

Kedua aplikasi memakai `medrive_core` + `medrive_ui` yang sama. Aplikasi driver meng-override
`appRoleProvider` ke `AppRole.driver` (endpoint `/driver/...`, akun pelapor ditolak).

## Prasyarat

- Flutter 3.47 / Dart 3.13 (lihat `environment.sdk` di `pubspec.yaml`).
- Android SDK (compileSdk dari Flutter, minSdk 24), emulator atau perangkat.
- Backend Laravel di `../backend` berjalan: `php artisan serve --host=0.0.0.0 --port=8000` dan
  `php artisan reverb:start` (lihat `backend/README.md`).

## Menjalankan

```bash
cd frontend
flutter pub get                 # satu kali untuk seluruh workspace
cd apps/medrive
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000 \
  --dart-define=WS_URL=ws://10.0.2.2:8080 \
  --dart-define=WS_KEY=<REVERB_APP_KEY backend>
```

Aplikasi driver dijalankan dengan cara yang sama dari `apps/medriver` (dart-define identik). Akun
driver dibuat admin pusat dari dashboard; tidak ada registrasi di aplikasi.

Tanpa `--dart-define` aplikasi memakai nilai pengembangan di atas (`10.0.2.2` = localhost komputer
dari emulator Android; `WS_KEY` default `medrive-local-key`). Untuk perangkat fisik, pakai IP LAN
komputer. Rilis wajib HTTPS/WSS (cleartext hanya diizinkan di build debug).

| dart-define | Wajib | Keterangan |
|---|---|---|
| `API_BASE_URL` | ya (rilis) | Origin backend tanpa `/api/v1`. |
| `WS_URL` | ya (rilis) | Host Reverb, mis. `wss://medrive.example.id:443`. |
| `WS_KEY` | ya | Sama dengan `REVERB_APP_KEY` backend. |
| `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_PROJECT_ID`, `FIREBASE_SENDER_ID` | tidak | Opsi Firebase tanpa `google-services.json`. |
| `SUPPORT_PHONE`, `SUPPORT_EMAIL` | tidak | Kontak admin di layar Bantuan; disembunyikan bila kosong. |
| `TILE_URL` | tidak | Server tile peta (default tile.openstreetmap.org). |
| `APP_VERSION` | tidak | Versi yang tampil di Profil dan dikirim saat registrasi perangkat. |

### Push notification (FCM)

Aplikasi tetap berjalan tanpa Firebase; push hanya nonaktif. Untuk mengaktifkan, pilih salah satu:

1. Letakkan `google-services.json` (package `com.medrive.pelapor`) di `apps/medrive/android/app/`,
   dan untuk driver (package `com.medrive.driver`) di `apps/medriver/android/app/`.
   Plugin `com.google.gms.google-services` otomatis diterapkan bila berkas itu ada. Berkas ini
   di-*ignore* git.
2. Atau isi keempat `FIREBASE_*` lewat `--dart-define`.

Token FCM didaftarkan ke `POST /api/v1/auth/fcm` setelah login dan setiap kali token diperbarui.
Di aplikasi driver, push `type=dispatch` memunculkan alarm full-screen (juga saat layar terkunci);
tanpa Firebase, tawaran tetap masuk lewat tarik `GET /driver/dispatches/active` saat aplikasi dibuka.

## Kode hasil generate

Model memakai freezed + json_serializable. Berkas `*.freezed.dart` / `*.g.dart` ikut di-commit
agar `flutter run` langsung jalan. Setelah mengubah model:

```bash
cd frontend/packages/core
dart run build_runner build -d
```

## Pemeriksaan kualitas

```bash
cd frontend
flutter analyze                       # seluruh workspace, target nol isu
(cd packages/core && flutter test)    # parsing model, ApiError, ApiClient, LocationPingService
(cd apps/medrive && flutter test)     # widget test login + form laporan (backend palsu di lapisan HTTP)
(cd apps/medriver && flutter test)    # widget test buka shift + terima tawaran (menang, kalah cepat, abaikan)
```

## Build APK

```bash
cd frontend/apps/medrive
flutter build apk --release \
  --dart-define=API_BASE_URL=https://medrive.example.id \
  --dart-define=WS_URL=wss://medrive.example.id:443 \
  --dart-define=WS_KEY=...
```

Signing rilis belum dikonfigurasi (build rilis masih memakai debug key bawaan template Flutter).
