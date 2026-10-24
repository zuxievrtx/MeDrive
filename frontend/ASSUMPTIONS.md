# ASSUMPTIONS: Aplikasi Pelapor MeDrive (Flutter)

Keputusan yang diambil saat prompt, desain Figma (`design/pelapor/*.png`), dan kontrak backend
(`backend/docs/api.md`, `backend/routes/api.php`) tidak cocok atau tidak lengkap. Folder
`backend/` tidak diubah sama sekali.

## Kontrak backend

| # | Temuan | Keputusan di aplikasi |
|---|---|---|
| B1 | Endpoint pelapor berawalan `/api/v1/reporter/...` (prompt menulis `/reports`, `/clinics`, `/profile`). | Mengikuti `routes/api.php`: `/reporter/reports`, `/reporter/clinics`, `/reporter/profile`, `/reporter/chat/unread-count`. Geocode tetap `/geocode/*`. |
| B2 | Tidak ada `GET /report-types` untuk pelapor. | Repository mencoba `/reporter/report-types`; bila 404/405 memakai katalog bawaan yang sama persis dengan `MasterDataSeeder` (kode, nama, warna, ikon, `requires_destination`). Begitu endpoint dibuat, data server otomatis dipakai. |
| B3 | `description` wajib di `StoreReportRequest`, sedangkan Figma menandai "Keterangan Tambahan (Opsional)". | Field tetap opsional bagi pelapor. Bila kosong, aplikasi menyusun deskripsi dari pilihan form (mis. "Medis Darurat, Stroke"). |
| B4 | Kanal `report.{id}` hanya diotorisasi saat status aktif (diambil s.d. mengantar pasien). | Saat `menunggu`, layar Lacak mem-poll `GET /reporter/reports/{id}` tiap 10 detik; begitu diambil driver, aplikasi subscribe kanal. |
| B5 | Filter `status` riwayat hanya menerima satu nilai. | Chip "Aktif" menyaring di aplikasi (semua status selain selesai/dibatalkan) dari halaman server; bila satu halaman kosong setelah disaring, aplikasi lanjut ke halaman berikutnya (maks. 3) sebelum menampilkan kosong. Tidak pernah memuat semua data sekaligus. |
| B6 | Boolean `details.*` di multipart. | Dikirim sebagai `"1"`/`"0"` (aturan `boolean` Laravel tidak menerima `"true"` di form-data). |
| B7 | Event `ChatMessageSent` tidak membawa `is_mine`. | Dibandingkan dengan `sender_id` user yang login. |
| B8 | Pelapor tidak bisa membatalkan laporan. | Tidak ada tombol batal di mana pun; FAQ menjelaskan pembatalan lewat admin. |
| B9 | Lupa kata sandi tidak punya endpoint. | "Lupa kata sandi?" membuka penjelasan: reset dilakukan admin pusat + nomor darurat 112/119. |
| B10 | Login akun driver/admin di aplikasi pelapor. | Token langsung dicabut (`POST /auth/logout`) dan muncul pesan "Akun ini bukan akun pelapor". Tidak ada registrasi driver/admin dan tidak ada panggilan ke endpoint grup driver. |

## Stack

| # | Prompt | Keputusan | Alasan |
|---|---|---|---|
| S1 | `pusher_client` | `dart_pusher_channels` 1.3 (Dart murni) | `pusher_client` 2.0.0 tidak dirawat sejak 2021 dan plugin native-nya gagal di AGP 8+. Protokol sama (Pusher), otorisasi kanal privat lewat `POST /api/v1/broadcasting/auth` dengan Bearer token, reconnect otomatis + subscribe ulang. |
| S2 | flutter_map dengan cache tile sederhana | `BuiltInMapCachingProvider` flutter_map 8 (cache disk 200 MB) | Bawaan library, tanpa paket tambahan. Server tile bisa diganti lewat `TILE_URL` karena tile publik OSM dibatasi kebijakan pemakaian. |
| S3 |: | `geolocator` (lokasi perangkat) dan `url_launcher` (telepon driver/112/119, email admin) ditambahkan | Tidak ada di daftar stack, tetapi dibutuhkan fitur yang diminta. |
| S4 |: | `material_ui` sebagai pustaka Material | go_router 18 mendeteksi `MaterialApp` dari paket `material_ui`; seluruh app dan `medrive_ui` mengimpor paket ini agar konsisten. |
| S5 | FCM | `getToken()`/`onTokenRefresh` tetap dipakai walau ditandai *deprecated* di firebase_messaging 17 | Backend mengirim lewat FCM HTTP v1 `message.token`, yang butuh registration token, bukan Firebase Installation ID. |
| S6 | Tanpa `google-services.json` | Plugin google-services hanya diterapkan bila berkasnya ada; alternatif opsi `FIREBASE_*` via dart-define; semua langkah FCM di-*try-catch* | Aplikasi tetap jalan tanpa Firebase. |
| S7 | Widget test "mock ApiClient" | `ApiClient` asli dengan adapter Dio palsu | Menguji header, amplop respons, pemetaan error, dan field multipart sungguhan, bukan sekadar stub. |

## Desain (Figma → aplikasi)

| # | Figma | Aplikasi | Alasan |
|---|---|---|---|
| D1 | Label "Username" di login | "Email" | Login backend memakai email (diminta prompt). |
| D2 | Teks Inggris (History, Profile, Home, Help Center) | Bahasa Indonesia (Riwayat, Profil, Beranda, Pusat Bantuan) | Prompt: seluruh UI berbahasa Indonesia. |
| D3 | Merah logo + link biru | Merah merek `#E2062C` (warna logo; teks putih 4,89:1) dan `#B30000` untuk teks merah kecil (6,15:1 di latar merah muda), konsisten dengan dashboard admin. Link biru diganti merah merek. | Satu aksen; kontras teks lolos WCAG AA. |
| D4 | Font Figma | Nunito (di-bundle, lisensi OFL) | Bentuk huruf membulat paling dekat dengan desain; tanpa unduhan saat runtime. |
| D5 | Badge "Selesai" solid hijau, "Dibatalkan" pucat | Semua badge status memakai pasangan latar pucat + teks gelap dengan warna semantik prompt (menunggu amber, diambil biru, dalam perjalanan violet, tiba cyan, mengantar teal, selesai hijau, dibatalkan abu) | Figma tidak konsisten; satu gaya untuk tujuh status. |
| D6 | Filter riwayat "Semua Tanggal" + "Urutkan: Terbaru" | Chip status Semua / Aktif / Selesai / Dibatalkan | Prompt meminta filter status; backend tidak punya filter tanggal/urutan (selalu terbaru). |
| D7 | Kartu "Panduan Pertolongan Pertama" di beranda | Diganti kartu laporan aktif ("Lacak") | Tidak ada konten panduan di sistem; kartu aktif lebih berguna saat darurat. |
| D8 | Pin jemput yang bisa diseret | Pin tetap di tengah, peta yang digeser | Pola yang lebih presisi di layar kecil; hasilnya sama (alamat diperbarui lewat `/geocode/reverse` setelah peta berhenti, debounce 700 ms). |
| D9 | Chip kondisi bebas di form | Dipetakan ke field detail v3 (jenis kecelakaan, kategori medis, dst.) dengan nilai yang diterima `StoreReportRequest` | Data harus lolos validasi server. |
| D10 | Keamanan Akun: Verifikasi Dua Langkah, Perangkat yang Terhubung | Hanya "Ubah Kata Sandi" | Backend tidak punya 2FA maupun daftar perangkat. Menampilkan menu yang tidak berfungsi dilarang. |
| D11 | Bantuan: Hubungi Kami (form), Syarat & Ketentuan | FAQ statis, nomor darurat 112/119, kontak admin dari `SUPPORT_PHONE`/`SUPPORT_EMAIL` (disembunyikan bila kosong) | Tidak ada endpoint kontak atau dokumen S&K. |
| D12 | Tidak ada desain Lacak, Chat, Detail, Sukses | Dibuat mengikuti bahasa visual Figma: header/peta penuh, sheet putih sudut besar, tombol pill merah |: |
| D13 | Avatar profil berupa ikon | Inisial nama | Backend pelapor tidak punya foto profil. |

## Perilaku

- Peta awal (sebelum izin lokasi) berpusat di Simpang Lima, Semarang, sesuai data contoh backend.
- Foto laporan dan chat dikecilkan ke sisi terpanjang ≤ 1280 px dan ≤ 300 KB (kualitas JPEG diturunkan bertahap).
- Satu `Idempotency-Key` (UUID v4) per draft form; "Kirim ulang" setelah gangguan jaringan memakai kunci yang sama sehingga tidak ada laporan ganda.
- Gangguan jaringan memunculkan pita "Tidak ada koneksi" di atas semua layar; "Coba lagi" memuat ulang layar data.
- 401 pada permintaan bertoken → sesi lokal dihapus, WebSocket diputus, kembali ke layar masuk.
- Rute/ETA diambil ulang tiap 30 detik dan posisi ambulans dianimasikan (interpolasi posisi + arah terpendek) selama 1,6 detik per pembaruan; animasi dimatikan bila pengguna memilih kurangi animasi.
- Chat hanya bisa dikirim saat laporan aktif; setelah selesai/dibatalkan riwayat tetap terbaca dengan banner "Chat ditutup".

## Batasan verifikasi

- Lingkungan pengembangan ini tidak punya Android SDK dan tidak bisa mengunduh dependensi Gradle,
  jadi `flutter build apk` / `flutter run` ke emulator **belum** dijalankan di sini. Yang sudah
  diverifikasi: `flutter analyze` (nol isu) dan seluruh unit/widget test. Konfigurasi Gradle
  (namespace, minSdk 24, desugaring, plugin google-services kondisional) perlu dicek pada build
  pertama di mesin dengan Android SDK.
- Alur penuh dengan backend sungguhan (register → lapor → lacak → chat → selesai) belum diuji
  end-to-end dari perangkat.

---

# Fase 5: Aplikasi Driver MeDriveR (`apps/medriver`)

Folder `backend/` tidak diubah. Bila prompt fase 5 berbeda dengan kode, yang diikuti adalah kode
(`routes/api.php`, `routes/channels.php`, `config/medrive.php`, resource & service).

## Perbedaan prompt vs kode backend

| # | Prompt | Kode nyata | Keputusan di aplikasi |
|---|---|---|---|
| P1 | Chat di `/reports/{id}/chat`, `/chat/unread-count` | Berprefix grup: `/driver/reports/{id}/chat*`, `/driver/chat/unread-count` | `ChatRepository` diberi `AppRole`; prefix `/reporter` (default, app pelapor tidak berubah) atau `/driver`. |
| P2 | Saat misi aktif, status lewat kanal `report.{id}` | `routes/channels.php` hanya mengizinkan **pelapor pemilik** di `report.{id}` | Driver tidak subscribe `report.{id}`. Detail laporan di-poll ringan tiap 15 detik + saat aplikasi kembali ke depan; rute tiap 30 detik. Kanal `chat.{id}` tetap dipakai (driver peserta). |
| P3 | Gate "Selesai": **semua** pasien punya `diserahkan kepada` | `ReportService::transition` hanya mensyaratkan **minimal satu** pasien diserahterimakan (`422 patient_handover_required`) | Aplikasi memakai aturan prompt yang lebih ketat (minimal 1 pasien dan semua pasien terisi). Jawaban server `patient_handover_required` tetap ditangani dan diarahkan ke Form Pasien. |
| P4 | FCM tawaran = data message | `FcmService` mengirim `notification` + `data`, `android.priority=high` | Background: handler FCM menampilkan alarm full-screen sendiri; notifikasi sistem dari payload `notification` tetap muncul (tidak bisa dicegah dari klien) dan diarahkan ke kanal alarm lewat meta-data `default_notification_channel_id`. Foreground: push tawaran langsung membuka layar Tawaran. |
| P5 | `GET /driver/dispatches/active` sebagai cadangan | Ada, plus `GET /driver/dispatches/{id}` yang mengisi `opened_at` | Layar Tawaran memuat detail lewat `GET /driver/dispatches/{id}`. Tarik cadangan: saat profil pertama termuat, saat resume, dan tiap 20 detik selama standby di depan layar. |
| P6 | Misi aktif setelah aplikasi dibuka ulang | Tidak ada endpoint "laporan aktif driver" | Bila `driver_profile.is_on_duty = true`, laporan aktif dicari di halaman pertama `GET /driver/reports/history` (urut terbaru; satu driver hanya satu laporan aktif). |
| P7 | Alasan tutup shift | Wajib di API (3-255 karakter), tetapi hanya dicatat di log (tidak ada kolom) | Bottom sheet alasan dengan pilihan cepat + "Lainnya" (teks bebas). |
| P8 | `pusher_client` | Sudah diganti `dart_pusher_channels` sejak fase 4 (S1) | Tetap `RealtimeService` yang ada. |
| P9 | Payload `is_mock_location` dari platform channel | geolocator sudah membaca `Location.isMock` per titik | Keduanya dipakai: `Position.isMocked` **atau** channel kecil `com.medrive.driver/mock_location` (MainActivity.kt, lokasi terakhir LocationManager). |

## Perluasan paket bersama (kompatibel dengan app pelapor)

- `medrive_core`:
  - `AppRole` + `appRoleProvider` (default `reporter`). `AuthRepository` dan `ChatRepository` membaca role; perilaku dan pesan app pelapor tidak berubah.
  - Model baru (freezed): `DriverProfile`, `DriverCertification`, `AmbulanceType`, `Ambulance`, `Shift`, `DriverAccount`, `Dispatch`; kelas biasa `DispatchOffer` (data push) dan `PatientInput`. Field tambahan nullable: `Report.reporter`, `Clinic.institution`, getter `AppUser.isDriver`, `Report.requiresDestination`, `Report.allPatientsHandedOver`.
  - `DriverRepository` untuk semua endpoint `/driver/*`.
  - `LocationPingService` (batch, interval adaptif, antrean offline) dengan antarmuka `LocationSource`, `BatteryReader`, `PingQueueStore` agar bisa diuji tanpa plugin.
  - `PushService`: kanal notifikasi bisa diatur, hook `onForegroundMessage`, plugin notifikasi lokal dibuka (`local`), dan notifikasi lokal kini disiapkan **walau Firebase tidak aktif** (alarm tawaran tetap bisa berbunyi). Untuk app pelapor efeknya hanya kanal notifikasinya dibuat lebih awal.
  - Dependensi baru: `clock` (waktu yang bisa dikendalikan di test), dev `fake_async`.
- `medrive_ui`: `StatusStepper`, `ShiftStatusCard`, `DispatchOfferCard`, `priorityLabel`, dan komponen chat bersama (`ChatBubble`, `ChatComposer`, `ChatDayDivider`, `ChatUnreadDivider`, `ChatClosedBanner`, `ChatSkeleton`).
  - Komponen chat sebelumnya kelas privat di `apps/medrive/.../chat_screen.dart`. Kelas itu dipindah ke `medrive_ui` dan layar chat pelapor kini memakainya: tampilan dan perilaku sama, kode duplikat hilang.
- Widget tingkat aplikasi yang butuh plugin atau `ApiClient` (gambar ber-token, pemilih foto + kompresi, pita offline, validator) disalin ke `apps/medriver/lib/widgets/` karena `medrive_ui` sengaja tidak bergantung pada `medrive_core` atau plugin native.

## Location engine

- Sumber lokasi: `Geolocator.getPositionStream` dengan `AndroidSettings.foregroundNotificationConfig` ("MeDriveR aktif: memancarkan lokasi", wake lock, notifikasi ongoing). Stream dijadwal ulang setiap `next_interval_seconds` berubah.
- Pengambilan titik: tiap interval server, atau lebih awal bila berpindah ≥ `distance_filter_m` (50 m). Saat diam dan GPS tidak memberi titik baru, titik terakhir dikirim ulang dengan `recorded_at` = sekarang agar server tahu driver masih aktif (interval bertugas 5 detik berlaku walau diam).
- Kirim: maks `max_batch_points` (10) titik per request **atau** titik tertua berumur `max_batch_age_seconds` (15 dtk). Ketiga angka diambil dari respons server, bukan dihitung sendiri. Pada interval standby 25 detik, satu batch sering hanya berisi 1 titik karena aturan umur 15 detik; ini konsekuensi aturan server, tetap lewat buffer batch.
- Antrean offline: gagal jaringan/5xx/429 → titik masuk antrean (maks 200, FIFO, berkas `location_queue.json` di direktori data aplikasi), dicoba lagi 15 detik kemudian dan saat aplikasi kembali ke depan; antrean dikirim lebih dulu daripada titik baru. Titik > 14 hari dibuang. `400`/`403`/`401` → batch dibuang (tidak akan pernah diterima). `409 no_open_shift` → pelacakan berhenti dan status driver dimuat ulang (mis. shift ditutup admin).
- Izin saat membuka shift: bottom sheet penjelasan → lokasi saat dipakai (wajib), notifikasi, abaikan optimasi baterai, full-screen intent (Android 14+). Tanpa izin lokasi shift tidak dibuka; ada tombol ke pengaturan.

## Keputusan perilaku

- Sakelar Aktif/Nonaktif = shift. Aktif membuka bottom sheet pilih ambulans; Nonaktif membuka bottom sheet alasan. Tutup shift ditolak di aplikasi selama ada misi (backend juga menolak, `report_in_progress`).
- **Keluar** saat shift masih terbuka diarahkan ke Tutup Shift lebih dulu. Alasannya: server tidak pernah menutup shift otomatis, jadi akun yang keluar tetapi shift-nya terbuka tetap menerima broadcast tanpa bisa menjawab.
- Tawaran: alarm = notifikasi lokal kanal `medriver_dispatch_v1` (importance max, nada alarm sistem, getar, `FLAG_INSISTENT` agar berulang, full-screen intent, `timeoutAfter` 3 menit). Bunyi berhenti saat dijawab, diabaikan, atau layar ditutup. "Abaikan" hanya lokal (disimpan di memori sesi). Satu `Idempotency-Key` per layar tawaran.
- Hasil terima: menang → beranda + layar Misi; `409 too_late` → "Kalah cepat: driver lain lebih dulu mengambil laporan ini."; `409 offer_expired`, `already_on_duty`, `no_open_shift` → pesan server lalu kembali ke standby; gangguan jaringan → tetap di layar dan boleh mencoba lagi.
- Misi: satu tombol aksi bertahap (Mulai Perjalanan → Tiba di Lokasi → Antar Pasien hanya untuk jenis `requires_destination` → Selesai). "Selesai" minta konfirmasi. Satu `Idempotency-Key` per status tujuan. Koordinat GPS terakhir ikut dikirim. Layar dijaga menyala (`wakelock_plus`) selama layar Misi terbuka.
- Waktu serah terima otomatis "sekarang" bila "Diserahkan kepada" diisi tanpa memilih jam; jam yang dipilih lebih besar dari jam sekarang dianggap kemarin (backend menolak waktu di masa depan).
- Daftar chat = laporan aktif + laporan lain yang masih punya pesan belum dibaca (dari `unread-count`). Polling cadangan chat juga aktif bila otorisasi kanal `chat.{id}` ditolak walau WebSocket tersambung (memperbaiki HANDOFF poin 3 untuk app driver; app pelapor belum diubah).

## Desain (antislop mode during)

Design read: aplikasi lapangan untuk driver ambulans yang bekerja di bawah tekanan waktu, sering satu tangan dan di kendaraan, memakai bahasa visual MeDrive (merah merek + putih, Nunito, kartu bersudut besar), dial **ENERGY 2 / RHYTHM 2 / MOTION 1**.

| # | Figma / prompt | Aplikasi | Alasan |
|---|---|---|---|
| E1 | Rating "4,9" di side menu & kartu | Dihapus; badge "Terverifikasi" dari `is_verified` | Aturan bisnis terkunci: tanpa rating. |
| E2 | Nopol berbeda di home (B 1234 ABC) dan side menu (H 6709 KW); nama "Andi Pratama" dengan email "dinda.pratiwi" | Semua dari API (`open_shift.ambulance`, `/driver/profile`) | Tidak ada data hardcode. |
| E3 | Label "Username", teks Inggris (Profile, History, Login) | "Email", Profil, Riwayat, Masuk | Login backend memakai email; UI bahasa Indonesia. |
| E4 | Avatar ilustrasi (naga, kepala hijau) di chat & profil | Avatar inisial | Backend tidak menyediakan foto pelapor; foto driver dipakai bila ada. Aset orang tidak dibuat tanpa instruksi. |
| E5 | Profil Figma berisi "Edit profil", "Keamanan akun", "Bantuan" | Profil hanya baca | Prompt: profil driver read-only; data kepegawaian dikelola admin. Tidak ada menu tanpa fungsi. |
| E6 | Beranda standby belum ada di Figma | Pita merah "Info Spot" dipakai ulang sebagai wadah sakelar Aktif/Nonaktif | Satu fokus per layar; identitas Figma (pita merah bersudut) tetap. |
| E7 | Kartu ETA melayang di atas peta | Kartu ETA di atas peta, tidak menumpuk | Pada layar 360 dp kartu melayang menutupi kontrol zoom/kembali ke posisi. |
| E8 | Tawaran belum ada di Figma | Latar merah penuh, jarak besar, kartu putih detail, tombol TERIMA putih tinggi 76 dp | Harus terbaca sekilas dari kursi pengemudi; satu aksi utama. |
| E9 | Tema | Hanya terang | Tile OSM yang dipakai terang; tema gelap tanpa server tile gelap tidak membantu saat malam dan akan bertabrakan dengan peta. Konsisten dengan app pelapor dan dashboard. |
| E10 | Teks prompt memakai em dash ("Kalah cepat — ...", "MeDriveR aktif — ...") | Diganti titik dua | Aturan antislop R-02; dicatat untuk dikonfirmasi pemilik. |

Gerak: hanya transisi sakelar 180 ms dan animasi bawaan Material; mati bila "kurangi animasi" aktif.

## Batasan verifikasi

- Flutter 3.47.8 di sandbox diambil dari image Docker `plugfox/flutter` (server unduhan Flutter diblokir). `flutter analyze` seluruh workspace: nol isu. Test: `medrive_core` 23 (16 lama + 7 `LocationPingService`), `apps/medrive` 7, `apps/medriver` 5 (buka shift sukses & gagal, terima tawaran menang, kalah cepat, abaikan).
- **APK belum pernah dibuild.** Artefak engine Android Flutter (`download.flutter.io` di storage.googleapis.com) diblokir di sandbox ini. Gradle, izin runtime, foreground service, full-screen intent, alarm, dan channel mock location perlu dicoba di perangkat.
- Catatan test: di Dart 3.13 / flutter_test, `await subscription.cancel()` di dalam `testWidgets` membuat test tidak pernah selesai. Karena itu `LocationPingService.stop()` tidak menunggu pembatalan langganan GPS. Ini tidak mengubah perilaku di perangkat.
