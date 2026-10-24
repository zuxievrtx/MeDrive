# HANDOFF: MeDrive

Dokumen serah terima untuk sesi pengerjaan berikutnya. Kondisi per commit `a76b2d3` di branch
`claude/compassionate-knuth-j6ac5c` (sudah di-push; belum ada pull request).

Rincian keputusan yang lebih panjang ada di dua dokumen sumber, dan dokumen ini merangkumnya:

- `backend/ASSUMPTIONS.md`: fase 1 sampai 3 (dashboard admin, API v1, chat/rute/geocode).
- `frontend/ASSUMPTIONS.md`: fase 4 (aplikasi pelapor Flutter).

---

## 1. Status progres

### Selesai

| Fase | Cakupan | Commit |
|---|---|---|
| 1 | Dashboard admin Laravel (Blade + Alpine, sidebar gelap, merah brand): beranda, peta live, laporan, driver, ambulans, master data, statistik, log lokasi, log aktivitas. | sebelum `b43fbb5` (repo lama), dipindah ke `backend/` |
| 2 | API `/api/v1` dengan Sanctum: auth mobile, grup pelapor/driver/admin, mesin dispatch + eskalasi radius, pipeline lokasi (buffer, flush 10 detik), FCM HTTP v1, idempotency, Reverb, dokumentasi Scribe + `docs/api.md`. Halaman admin dipindah ke fetch API. | `4d2a8bc`, `649b1d9` (riwayat lama) |
| 3 | Chat pelapor ↔ driver (tabel `chat_messages`, kanal `chat.{id}`, FCM), badge Terverifikasi, proxy rute/ETA OSRM, proxy geocoding Nominatim, `PUT /reporter/profile`, CORS dipersempit. | `ac06852` |
| 4 | Aplikasi pelapor Flutter `frontend/apps/medrive` + paket `medrive_core` dan `medrive_ui` dalam pub workspace. Seluruh 15 layar dari prompt sudah ada (splash, sambutan, masuk, daftar, wajib ganti sandi, beranda peta, form laporan 4 jenis, sukses, lacak, detail, chat, riwayat, profil + edit, keamanan + ubah sandi, bantuan, dialog keluar). | `a76b2d3` |

Hasil verifikasi terakhir:

- **Fase 4 (sesi ini):**
  - `flutter analyze` di seluruh workspace: nol isu.
  - Test `packages/core`: 16 lulus.
  - Widget test `apps/medrive`: 7 lulus (login berhasil, login gagal, validasi login, submit form laporan, validasi lokal form, error validasi server).
- **Backend:** suite Pest lulus pada saat commit fase 3. Suite ini tidak dijalankan ulang di sesi fase 4 karena `backend/` tidak diubah.

### Sedang dikerjakan

Tidak ada pekerjaan setengah jadi di working tree; semua sudah di-commit. Yang **belum tuntas** dari
fase 4 adalah verifikasi di perangkat (lihat bagian 4, poin 1 dan 2).

### Belum mulai

- Aplikasi driver `frontend/apps/medriver`. Desain Figma sudah ada di `frontend/design/driver/`
  (Authentication, Dashboard Driver, Chat, Profile). Endpoint driver di backend sudah lengkap sejak fase 2 dan 3.
- Endpoint `GET /reporter/report-types` di backend (aplikasi pelapor memakai katalog bawaan sebagai pengganti).
- Konfigurasi rilis Android (signing key, server tile/rute/geocode sendiri, Firebase produksi).

---

## 2. Keputusan arsitektur dan aturan bisnis yang sudah dikunci

### Umum

- **Monorepo:** `backend/` (Laravel 12, PHP 8.4, MySQL) dan `frontend/` (Flutter, pub workspaces, **bukan** melos).
- **Bahasa dan waktu:** semua teks UI dan pesan error API berbahasa Indonesia. Zona waktu Asia/Jakarta. Format tanggal di aplikasi: `dd MMM yyyy · HH:mm`.
- **Peta:**
  - Hanya OSM (flutter_map di aplikasi, Leaflet di dashboard). **Google Maps SDK dilarang.**
  - Aplikasi **tidak boleh** memanggil Nominatim atau OSRM langsung. Semuanya lewat proxy backend: `/api/v1/geocode/*` dan `/api/v1/reporter/reports/{id}/route`.
- **Fitur yang dilarang ada di mana pun:**
  - Rating dalam bentuk apa pun.
  - Registrasi mandiri driver/admin; akun driver hanya dibuat admin.
  - Pembatalan laporan oleh pelapor; hanya admin, dan hanya saat status `menunggu`.
  - Penugasan manual oleh admin.
  - Penutupan shift otomatis.
  - Akses chat oleh admin.
- **Skema database:**
  - 23 tabel ERD v3 tidak boleh diubah.
  - Tambahan hanya yang ada di whitelist: `personal_access_tokens`, tabel jobs/cache, `users.remember_token`, `driver_last_locations.battery_level` dan `is_mock_location`, serta `chat_messages`.

### Kontrak API v1

- **Amplop respons:** sukses `{success, data, meta}`; gagal `{success:false, error:{code, message, details}}`.
- **Kode HTTP:**
  - Validasi gagal: **HTTP 400 `validation_failed`**.
  - Aturan bisnis: 422.
  - Konflik status: 409 (mis. `too_late`, `chat_closed`, `report_not_cancellable`).
- **Header dan rute:**
  - Header `Accept: application/json` wajib.
  - Path mobile memakai prefix grup: `/api/v1/reporter/...` dan `/api/v1/driver/...`.
  - Auth di `/api/v1/auth/*` dan `GET /api/v1/me`.
- **Token Sanctum:**
  - Ability `reporter` atau `driver`.
  - Login mobile menolak admin. Aplikasi pelapor juga mencabut token akun driver.
- **Wajib ganti password:** `must_change_password` membalas 403. Pengecualian: `me`, `change-password`, `logout`, `fcm`. Di aplikasi, layar wajib ganti sandi memblokir semua layar lain.
- **Idempotency-Key** (disimpan 24 jam per pengguna) berlaku pada:
  - `POST /reporter/reports`
  - `POST /driver/dispatches/{id}/accept`
  - `POST /driver/reports/{id}/status`

  Aplikasi membuat satu UUID per draft form. Retry memakai kunci yang sama.
- **Pagination server di semua daftar:**
  - Laporan: 15 per halaman.
  - Klinik: 20 per halaman.
  - Chat: kursor `before_id`, metadata di `meta.cursor`.
  - Aplikasi tidak pernah memuat semua data sekaligus.
- **Multipart laporan:**
  - Field `details[...]`; boolean dikirim `"1"`/`"0"`.
  - Maksimal 5 foto `photos[]`, masing-masing ≤ 2 MB.
  - Aplikasi mengompres ke ≤ 300 KB, sisi terpanjang ≤ 1280 px.
  - Foto chat ≤ 1 MB, jpg/png.
- **Media privat:** hanya lewat `GET /api/v1/media/{type}/{id}` dengan Bearer token.

### Status laporan dan dispatch

- **Urutan status:** `menunggu → diambil → dalam_perjalanan → tiba_di_lokasi → (mengantar_pasien) → selesai`. Status akhir lain: `dibatalkan`, hanya oleh admin.
- **Transisi oleh driver:** `tiba_di_lokasi` boleh langsung ke `selesai`.
- **Status aktif** = `diambil` sampai `mengantar_pasien`. Hanya di status ini:
  - kanal `report.{id}` bisa di-subscribe;
  - chat bisa dikirim;
  - pelacakan berjalan.
- **Warna status:** menunggu amber, diambil biru, dalam perjalanan violet, tiba cyan, mengantar teal, selesai hijau, dibatalkan abu. Berlaku sama di dashboard dan aplikasi.
- **Dispatch:**
  - Radius ronde 5 → 10 → 15 km → tanpa batas.
  - Jeda ronde: prioritas 1 = 60 detik, prioritas 2 = 120 detik, default 180 detik, terjadwal 300 detik.
  - Ronde tanpa kandidat langsung naik ke radius berikutnya.
  - Setelah ronde terakhir: alarm akhir ke admin.
  - State ronde disimpan di cache, bukan kolom.
- **Pengambilan atomik:** klaim `is_on_duty` driver lalu UPDATE bersyarat `status = 'menunggu'`. Driver yang kalah mendapat `409 too_late`.
- **Kode laporan:** `MDR-YYMMDD-NNNN`.
- **Badge Terverifikasi:** sertifikat berlaku bila `expires_at` kosong atau `>= hari ini`.

### Lokasi, realtime, dan push

- **Interval ping driver:**
  - Bertugas 5 detik (selalu, walau diam).
  - Standby 25 detik.
  - Diam 60 detik.
  - Baterai < 20%: interval ×2.
- **Pipeline lokasi:**
  - Buffer di cache, flush tiap 10 detik (bulk insert log).
  - Snapshot maksimal sekali per 15 detik per driver.
  - Broadcast maksimal sekali per 5 detik per driver.
  - Retensi log 14 hari.
- **Kanal broadcast:**
  - `admin`, `admin.tracking`;
  - `report.{id}`: pelapor pemilik, saat status aktif;
  - `chat.{id}`: pelapor + driver yang ditugaskan.
  - Otorisasi mobile lewat `POST /api/v1/broadcasting/auth` dengan Bearer token.
- **Event:**
  - `ReportCreated`, `ReportStatusChanged`, `DispatchEscalated`;
  - `DriverLocationUpdated` (ke admin dan ke `report.{id}`);
  - `ChatMessageSent`, `ChatMessageRead` (membawa `last_read_id`).
  - Semua `ShouldBroadcastNow` + after commit.
  - Reverb mati tidak menggagalkan request (`ResilientPusherBroadcaster`); klien beralih ke polling 10 detik.
- **FCM HTTP v1** lewat antrean, payload terenkripsi. Tanpa kredensial: mode log-only. Aplikasi pelapor tetap berjalan tanpa Firebase; token didaftarkan ke `POST /auth/fcm` setelah login dan saat token diperbarui.
- **Rute/ETA:**
  - Backend: maksimal satu panggilan OSRM per laporan per 30 detik. Bila OSRM gagal: rute lama dengan `stale: true`, atau `502` bila belum ada rute.
  - Saat `mengantar_pasien`, rute mengarah ke tujuan antar.
  - Aplikasi menyegarkan rute tiap 30 detik.
- **Geocoding:** batas global 1 panggilan upstream per detik (`429 geocode_busy`). Aplikasi memberi debounce 700 ms (reverse) dan 600 ms (search), dan mencoba ulang `geocode_busy` sekali.

### Keputusan khusus aplikasi pelapor (fase 4)

- **Stack:**
  - Riverpod 3 tanpa codegen, go_router 18, dio, freezed + json_serializable.
  - Pustaka Material: paket `material_ui`. go_router 18 mendeteksi `MaterialApp` dari paket ini.
  - Realtime memakai `dart_pusher_channels`, bukan `pusher_client` yang sudah tidak dirawat.
- **Konfigurasi lewat `--dart-define`:**
  - `API_BASE_URL`, `WS_URL`, `WS_KEY`;
  - opsional: `FIREBASE_*`, `SUPPORT_PHONE`, `SUPPORT_EMAIL`, `TILE_URL`, `APP_VERSION`.
- **Jenis laporan:** aplikasi mencoba `/reporter/report-types`; bila 404/405 memakai katalog bawaan yang identik dengan `MasterDataSeeder`.
- **Deskripsi laporan:** wajib di backend, opsional di UI. Bila kosong, aplikasi menyusunnya dari pilihan form.
- **Pelacakan:**
  - Saat `menunggu`: poll detail tiap 10 detik.
  - Saat aktif: event WebSocket.
  - Bila WebSocket putus atau kanal ditolak: poll posisi dan detail tiap 10 detik.
  - Marker diinterpolasi selama 1,6 detik, dimatikan bila pengguna memilih kurangi animasi.
- **Filter riwayat "Aktif":** disaring di aplikasi dari halaman server; maksimal 3 halaman kosong dilewati.
- **Desain:**
  - Merah brand `#E2062C`, merah tua `#B30000` untuk teks merah kecil.
  - Font Nunito di-bundle.
  - Header merah + sheet putih sudut besar.
  - Dial antislop ENERGY 2 / RHYTHM 2 / MOTION 1.

---

## 3. Struktur folder penting dan lokasi logika utama

```
MeDrive/
├── HANDOFF.md                     dokumen ini
├── backend/                       Laravel (API v1 + dashboard admin)
│   ├── ASSUMPTIONS.md             keputusan fase 1–3 (A–I)
│   ├── docs/api.md                panduan API untuk Flutter
│   ├── docs/deploy.md             panduan deploy (Reverb, queue, scheduler)
│   ├── public/docs/               dokumentasi Scribe statis + OpenAPI + Postman
│   ├── config/medrive.php         semua angka bisnis (radius, interval, batas file, OSRM, Nominatim)
│   ├── routes/api.php             seluruh endpoint /api/v1 (auth, reporter, driver, admin, media, geocode)
│   ├── routes/channels.php        otorisasi kanal admin, report.{id}, chat.{id}
│   ├── routes/console.php         jadwal: flush lokasi 10 dtk, eskalasi tiap menit, prune log 01.30
│   ├── routes/admin.php           halaman dashboard (kerangka Blade)
│   ├── app/Services/              logika bisnis (lihat tabel di bawah)
│   ├── app/Events/                event broadcast
│   ├── app/Jobs/SendFcmNotification.php
│   ├── app/Console/Commands/      EscalateDispatches, FlushLocationBuffer
│   ├── app/Http/Controllers/Api/V1/{Reporter,Driver,Admin}/ + Auth/Chat/Geocode/Media
│   ├── app/Http/Middleware/       JSON wajib, wajib ganti sandi, role, idempotency
│   ├── app/Http/Resources/        bentuk JSON (ChatMessageResource::forBroadcast, dst.)
│   ├── app/Broadcasting/          ResilientPusherBroadcaster
│   ├── app/Enums/ReportStatus.php status, label, tone, daftar status aktif
│   ├── database/migrations/       23 tabel v3 (jangan diubah) + whitelist 2026_10_15_*, 2026_10_21_*
│   ├── database/seeders/          MasterDataSeeder (jenis laporan, warna, ikon), DemoDataSeeder
│   ├── resources/views/admin/, resources/js/admin/   UI dashboard
│   └── tests/Feature/Api/         Auth, ReportDispatch, DriverShift, LocationPipeline, Chat, MobileExtras, AdminApi
└── frontend/                      Flutter pub workspace
    ├── README.md                  cara menjalankan, dart-define, FCM, build_runner, test
    ├── ASSUMPTIONS.md             keputusan fase 4 (B1–B10, S1–S7, D1–D13)
    ├── design/pelapor/, design/driver/   ekspor Figma
    ├── packages/core/lib/src/
    │   ├── config/app_config.dart       dart-define + FirebaseConfig
    │   ├── api/                         ApiClient (Bearer, retry 1×, 401 → onUnauthorized, reachable), ApiError, ApiResponse/Paged
    │   ├── storage/token_storage.dart   flutter_secure_storage
    │   ├── models/                      freezed: user, report (union detail per jenis), report_type (+ katalog bawaan), chat, common, report_draft
    │   ├── repositories/                auth, report, chat, geocode
    │   ├── realtime/realtime_service.dart   Reverb, kanal privat ber-ref-count, subscribe ulang saat reconnect
    │   ├── push/push_service.dart       FCM + notifikasi lokal, aman tanpa Firebase
    │   └── providers.dart               provider Riverpod dasar (dipakai juga oleh app driver nanti)
    ├── packages/ui/lib/src/       tokens, theme, format tanggal, widgets (tombol, field, badge, kartu, state, dialog, form, MedMapView)
    └── apps/medrive/lib/
        ├── main.dart, app.dart, router.dart   bootstrap, redirect sesi, navigasi dari notifikasi
        ├── state/session.dart                 SessionController (login, logout global, registrasi FCM)
        ├── widgets/                           pita offline, feedback error, photo_picker (kompresi), media (gambar ber-auth)
        └── features/{auth,home,report,tracking,chat,history,profile}/
```

### Peta service backend

| Service | Tanggung jawab |
|---|---|
| `ReportService` | Buat laporan + detail + lampiran (transaksi), transisi status driver (`DRIVER_TRANSITIONS`), pembatalan admin, push ke pelapor. |
| `DispatchService`, `DispatchState`, `EscalationService` | Broadcast ke ambulans terdekat, ronde radius, state ronde di cache, eskalasi tiap menit. |
| `ShiftService`, `FleetService`, `OrganizationService` | Shift driver; ambulans dan jenisnya; instansi dan klinik. |
| `LocationService`, `LocationBuffer`, `TrackingService`, `LocationHistoryService` | Pipeline ping → buffer → flush; posisi live; riwayat rute. |
| `Routing/RouteService` + `OsrmProvider` (kontrak `RouteProvider`) | Rute/ETA dengan cache dan pembatasan upstream. |
| `GeocodeService` | Proxy Nominatim. |
| `ChatService` | Peserta chat, kirim, tandai baca, unread. |
| `MobileAuthService`, `ReporterAccountService`, `DriverAccountService` | Login/registrasi mobile, akun pelapor, akun driver oleh admin. |
| `FcmService` | Push FCM HTTP v1 lewat antrean. |
| `DashboardMetrics`, `StatisticsService`, `ReportQuery`, `AdminLogger`, `ReportTypeService` | Angka dashboard, statistik, filter laporan + export CSV, log aktivitas admin, aturan jenis laporan. |

---

## 4. Bug dan persoalan yang diketahui belum selesai

### Prioritas tinggi

1. **Aplikasi Android belum pernah dibuild atau dijalankan.** Lingkungan sesi tidak punya Android SDK, dan unduhan Gradle diblokir. Belum terverifikasi:
   - konfigurasi Gradle (AGP 9.1.0, Kotlin 2.4.0 dari template, desugaring, plugin google-services 4.4.2 kondisional);
   - izin runtime (lokasi, kamera, notifikasi);
   - perilaku plugin native: geolocator, image_picker, flutter_image_compress, secure storage.
2. **Alur penuh belum diuji end-to-end dengan backend sungguhan:** register → login → beranda → lapor 4 jenis (foto + tujuan) → sukses → lacak → chat → selesai → riwayat. Delivery Gate antislop item R-35 masih **FAIL** karena ini.
3. **Chat tanpa pembaruan saat kanal gagal tapi koneksi hidup.** Polling cadangan di layar Chat hanya aktif bila WebSocket terputus. Bila koneksi tersambung tetapi otorisasi kanal `chat.{id}` gagal, pesan baru tidak muncul sampai layar dibuka ulang. Layar Lacak sudah menangani kasus ini lewat flag `_channelRejected`; Chat belum.

### Prioritas sedang

4. **Endpoint jenis laporan pelapor belum ada di backend.** Bila admin mengubah nama, warna, atau ikon jenis laporan, aplikasi tetap menampilkan katalog bawaan.
5. **Panah arah ambulans mengabaikan rotasi peta.** Bila pengguna memutar peta, arah panah ikut keliru.
6. **Timer layar Lacak dan Chat tetap berjalan saat aplikasi di background.** Saat aplikasi kembali, data hanya dimuat ulang. Perlu jeda polling saat aplikasi di-pause untuk menghemat baterai dan kuota.
7. **Chip status di layar Lacak selalu menampilkan "Mengantar Pasien"**, padahal driver boleh langsung `tiba_di_lokasi → selesai`. Chip itu tampak terlewati tanpa penjelasan.
8. **Saat status `menunggu → diambil`**, pelapor baru tahu dalam ≤ 10 detik (polling), karena kanal `report.{id}` belum boleh di-subscribe sebelum status aktif. FCM menutup celah ini bila Firebase aktif.
9. **Tile, OSRM, dan Nominatim memakai server publik.** Ketiganya dibatasi kebijakan penggunaan; produksi perlu server sendiri:
   - tile: `TILE_URL` di aplikasi;
   - rute: `OSRM_BASE_URL` di backend;
   - geocoding: `NOMINATIM_BASE_URL` dan `NOMINATIM_UPSTREAM_PER_SECOND` di backend.
10. **Build rilis masih ditandatangani debug key** bawaan template Flutter.

### Prioritas rendah / dokumentasi

11. **`WS_KEY` tidak cocok antara aplikasi dan backend.** Default aplikasi `medrive-local-key`, sedangkan `.env.example` backend `ganti-dengan-kunci-acak`. `WS_KEY` harus selalu diisi sesuai `REVERB_APP_KEY`.
12. **`backend/README.md` masih README bawaan Laravel**, padahal `frontend/README.md` merujuk ke sana untuk menjalankan backend. Panduan sebenarnya ada di `backend/docs/deploy.md`.
13. **Versi PHP dan Pest.** `composer.lock` mengunci Pest 5 (butuh PHP 8.4), sedangkan lingkungan sesi sebelumnya memakai PHP 8.3 + Pest 4 lewat `composer.local.*` yang tidak di-commit. Suite backend perlu dijalankan sekali di PHP 8.4.
14. **API FCM deprecated.** firebase_messaging 17 menandai `getToken`/`onTokenRefresh` sebagai deprecated. API ini tetap dipakai karena backend butuh registration token untuk FCM HTTP v1. Pantau saat upgrade paket.
15. **Cakupan widget test.** Test hanya mencakup login dan form laporan; Lacak, Chat, Riwayat, dan Profil belum punya test.

---

## 5. Langkah berikutnya (urutan mengikuti prompt fase 4 dan rencana proyek)

1. **Build dan jalankan aplikasi pelapor** di mesin dengan Android SDK. Ikuti `frontend/README.md`, isi `WS_KEY` sesuai backend, dan perbaiki konfigurasi Gradle bila gagal.
2. **Jalankan backend lengkap:**
   - `serve`;
   - `reverb:start`;
   - `queue:work`;
   - `schedule:work` (atau `composer dev`).

   Isi data demo, siapkan satu driver dengan shift terbuka, lalu ikuti DoD fase 4 berurutan:
   1. register;
   2. login;
   3. beranda (izin lokasi, geser pin, cari alamat);
   4. lapor **keempat jenis**, dengan foto, dan tujuan faskes untuk ibu hamil dan jenazah;
   5. layar sukses;
   6. Lacak (marker bergerak mulus, rute, ETA) dengan driver mengirim lokasi lewat API driver;
   7. chat dua arah termasuk foto;
   8. driver menyelesaikan laporan;
   9. riwayat dan detail.
3. **Verifikasi FCM** dengan `google-services.json` atau `FIREBASE_*`:
   - token terdaftar di `user_devices`;
   - notifikasi status dan chat muncul;
   - ketukan notifikasi membuka layar yang benar.

   Lalu pastikan aplikasi juga berjalan tanpa Firebase.
4. **Tutup Delivery Gate antislop R-35:** klik setiap kontrol di emulator, catat hasilnya, dan cek overflow di layar kecil (360 dp) serta dengan font besar.
5. **Perbaiki persoalan bagian 4 secara berurutan:**
   - poin 3: polling cadangan Chat saat kanal ditolak;
   - poin 6: jeda timer di background;
   - poin 5: rotasi peta;
   - poin 7: chip status;
   - poin 12: README backend.

   Tambahkan widget test untuk Lacak dan Chat.
6. **Fase backend berikutnya** (perlu izin eksplisit karena fase 4 melarang mengubah `backend/`): tambah `GET /api/v1/reporter/report-types`. Aplikasi otomatis memakainya tanpa perubahan kode.
7. **Aplikasi driver `frontend/apps/medriver`:**
   - Desain di `frontend/design/driver/`.
   - Pakai ulang `medrive_core` dan `medrive_ui`.
   - Endpoint `/api/v1/driver/*`: profil, ambulans tersedia, buka/tutup shift, tawaran dispatch + accept, ubah status, pasien, lampiran, rute, chat, dan kirim lokasi `POST /driver/location` dengan interval dari bagian 2.
8. **Persiapan rilis:**
   - signing key;
   - server tile, OSRM, dan Nominatim sendiri;
   - HTTPS/WSS;
   - Firebase produksi;
   - `APP_VERSION`.
