# Build & jalankan aplikasi Android (MeDrive & MeDriveR)

Panduan untuk Windows (perintah sama di macOS/Linux, ganti `\` dengan `/`).

| Aplikasi | Folder | Package |
|---|---|---|
| MeDrive (pelapor) | `frontend/apps/medrive` | `com.medrive.pelapor` |
| MeDriveR (driver) | `frontend/apps/medriver` | `com.medrive.driver` |

## 1. Prasyarat (sekali saja)

1. **Flutter 3.47.x** (Dart 3.13). Cek: `flutter --version`.
2. **Android Studio** (memasang Android SDK dan JDK 21 bawaan). AGP 9 butuh JDK 17 atau lebih baru.
3. Buka Android Studio → **Settings → Languages & Frameworks → Android SDK**:
   - Tab **SDK Platforms**: centang **Android API 37** dan **Android API 36**.
   - Tab **SDK Tools**: centang **Android SDK Build-Tools**, **Android SDK Command-line Tools (latest)**, **Android SDK Platform-Tools**, **NDK (Side by side)**.
   - Klik **Apply**.

   Lewat command line (alternatif):
   ```bat
   sdkmanager --list | findstr android-37
   sdkmanager "platforms;android-37" "platforms;android-36" "platform-tools" "build-tools;36.0.0"
   ```
4. Hubungkan Flutter ke SDK dan terima lisensi:
   ```bat
   flutter config --android-sdk C:\Android
   flutter doctor --android-licenses
   flutter doctor
   ```
   `flutter doctor` harus menampilkan centang pada **Android toolchain**.

> **API 37 wajib untuk MeDriveR.** Plugin `permission_handler_android` 14.x dikompilasi dengan
> API 37. Tanpa platform ini build gagal dengan pesan
> `Failed to find target with hash string 'android-37'`.

## 2. Siapkan backend

Jalankan backend Laravel (lihat `backend/docs/deploy.md`):

```bat
cd backend
php artisan serve --host=0.0.0.0 --port=8000
php artisan reverb:start
php artisan queue:work
php artisan schedule:work
```

Catat nilai `REVERB_APP_KEY` di `backend/.env`; nilai ini dipakai sebagai `WS_KEY`.
Akun driver dibuat dari dashboard admin (Driver → Tambah), lalu buat juga minimal satu ambulans
berstatus tersedia di klinik driver tersebut.

## 3. Jalankan di emulator / HP (debug)

Selalu jalankan dari **folder aplikasi**, bukan dari `frontend/`:

```bat
cd frontend
flutter pub get
cd apps\medriver
flutter devices
flutter run ^
  --dart-define=API_BASE_URL=http://10.0.2.2:8000 ^
  --dart-define=WS_URL=ws://10.0.2.2:8080 ^
  --dart-define=WS_KEY=<REVERB_APP_KEY>
```

- `10.0.2.2` = localhost komputer dilihat dari **emulator**.
- Untuk **HP fisik**, ganti dengan IP LAN komputer (mis. `http://192.168.1.10:8000`), pastikan HP dan
  komputer satu Wi-Fi dan firewall Windows mengizinkan port 8000 dan 8080.
- Build debug mengizinkan HTTP biasa; build release wajib HTTPS/WSS.
- Aplikasi pelapor sama, cukup ganti folder ke `apps\medrive`.

## 4. Build APK

```bat
cd frontend\apps\medriver
flutter build apk --release ^
  --dart-define=API_BASE_URL=https://medrive.example.id ^
  --dart-define=WS_URL=wss://medrive.example.id:443 ^
  --dart-define=WS_KEY=<REVERB_APP_KEY> ^
  --dart-define=APP_VERSION=1.0.0
```

Hasil: `frontend\apps\medriver\build\app\outputs\flutter-apk\app-release.apk`.

- APK lebih kecil per arsitektur: tambahkan `--split-per-abi` (hasil `app-arm64-v8a-release.apk`
  untuk hampir semua HP modern).
- APK uji di jaringan lokal (HTTP): pakai `flutter build apk --debug` dengan dart-define IP LAN.
- Pasang ke HP: `flutter install` atau `adb install -r build\app\outputs\flutter-apk\app-release.apk`.
- Build release **masih ditandatangani debug key**. Untuk distribusi, buat keystore dan isi
  `signingConfigs` di `android/app/build.gradle.kts`.

## 5. Push notification (opsional)

Tanpa Firebase aplikasi tetap jalan; tawaran driver masuk lewat tarik berkala. Untuk mengaktifkan:
letakkan `google-services.json` (package `com.medrive.driver`) di
`apps\medriver\android\app\`, atau isi `--dart-define=FIREBASE_API_KEY=... FIREBASE_APP_ID=...
FIREBASE_PROJECT_ID=... FIREBASE_SENDER_ID=...`.

## 6. Setelah aplikasi terpasang (MeDriveR)

Saat membuka shift pertama kali, izinkan: **lokasi**, **notifikasi**, **abaikan optimasi baterai**,
dan di Android 14+ **notifikasi layar penuh** (Settings → Apps → MeDriveR → Notifications).
Tanpa ini alarm tawaran tidak muncul di layar terkunci dan ping lokasi bisa dihentikan sistem.

## 7. Masalah umum

| Pesan | Penyebab | Solusi |
|---|---|---|
| `Failed to find target with hash string 'android-37'` | Platform API 37 belum terpasang | Langkah 1.3, lalu `flutter clean` dan ulangi. |
| `flutter.sdk not set in local.properties` | Belum pernah `flutter pub get`/`flutter run` di folder app | Jalankan dari `apps\medriver`; Flutter membuat `android\local.properties` sendiri. |
| `Unsupported class file major version` / JDK error | JDK lama | `flutter config --jdk-dir "C:\Program Files\Android\Android Studio\jbr"` |
| `No NDK found` / NDK mengunduh lama | NDK belum ada | Pasang **NDK (Side by side)** di SDK Tools atau tunggu unduhan otomatis pertama. |
| Login gagal "Tidak ada koneksi" | URL salah / firewall | Buka `http://<IP>:8000/api/v1/me` dari browser HP; harus menjawab JSON 401. |
| Realtime tidak jalan (chat lambat) | `WS_KEY` tidak sama dengan `REVERB_APP_KEY` | Samakan, jalankan ulang. Aplikasi tetap berjalan lewat polling 10 detik. |

Bila build masih gagal setelah mengganti SDK: `flutter clean`, hapus `apps\medriver\android\.gradle`,
lalu ulangi `flutter run`.
