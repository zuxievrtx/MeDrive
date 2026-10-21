# Asumsi dan Keputusan: Medrive (dashboard admin + API v1)

Dokumen ini mencatat asumsi, keputusan teknis, dan **perbedaan antara prompt dengan kondisi repo**. Bagian A–D berasal dari pembuatan dashboard admin (fase 1) dan sudah diperbarui; bagian E–H berasal dari pembangunan backend API (fase 2); bagian I berasal dari fase 3 (chat, terverifikasi, rute/ETA, geocoding).

## A. Perbedaan prompt vs repo (perlu diketahui)

1. **File `medrive_db_v3.sql` dan `medrive_erd_v3.dbml` tidak ada di repo.** Acuan skema adalah 23 migration di `database/migrations/2026_10_12_0000xx_*` serta `MasterDataSeeder`/`DemoDataSeeder` yang menyatakan diri "dibuat otomatis dari medrive_db_v3.sql". Kecocokan "persis dengan medrive_db_v3.sql" tidak bisa diverifikasi langsung; yang dijaga adalah migration tersebut tidak diubah.
2. **Tabel v3 tidak diubah.** Tambahan hanya whitelist prompt fase 2: `users.remember_token`, tabel `personal_access_tokens`, `jobs`, `failed_jobs`, `job_batches`, `cache`, `cache_locks`, serta `driver_last_locations.battery_level` (`TINYINT UNSIGNED NULL`) dan `driver_last_locations.is_mock_location` (`BOOLEAN NOT NULL DEFAULT FALSE`). Semuanya migration terpisah bertanggal `2026_10_15_*`. Fase 3 menambah satu tabel whitelist: `chat_messages` (`2026_10_21_181605_create_chat_messages_table`), sesuai DDL prompt termasuk CHECK `chk_chat_type`.
3. **Model lama `DriverProfile` dan `Report` mengikuti skema versi lama** (kolom `plate_number`, `is_active`, `last_lat`, dst.) dan ditulis ulang mengikuti v3 di fase 1.
4. **`ambulance_types` tidak punya kolom ikon.** Ikon marker per jenis ambulans dipetakan dari kode jenis di `config/medrive.php` (`ambulance_type_icons`).
5. **Migration `driver_shifts`**: ekspresi kolom generated `IF(...)` hanya ada di MySQL; ada cabang `CASE WHEN` setara untuk SQLite. Test suite kini berjalan di MySQL (`medrive_db_test`), jadi cabang SQLite hanya cadangan.
6. **Path endpoint mobile memakai prefix grup.** Prompt menulis endpoint pelapor sebagai `/clinics`, `/reports`, dan endpoint driver sebagai `/profile`, `/shifts`, dst., sekaligus meminta grup route `reporter` dan `driver`. Path final: `/api/v1/reporter/...` dan `/api/v1/driver/...`, sehingga `GET /reports/{id}` milik pelapor dan driver tidak bertabrakan. Endpoint auth tetap di `/api/v1/auth/*` dan `GET /api/v1/me`.
7. **Pest v5 vs lingkungan lokal.** `composer.lock` mengunci Pest 5 (butuh PHP 8.4). Lingkungan pengerjaan hanya punya PHP 8.3, sehingga test dijalankan dengan set dependensi lokal (Pest 4, file `composer.local.*` yang tidak di-commit). Kode test sama untuk keduanya. `laravel/sanctum` dan `knuckleswtf/scribe` ditambahkan ke `composer.json`/`composer.lock` dengan `--no-install`; diff lock murni penambahan paket.
8. **Test lama dashboard dihapus dan dipindahkan.** `tests/Feature/Admin/{DriverManagement,MasterData,ShiftAndReportActions,MonitoringData}Test.php` menguji controller web yang kini sudah tidak ada. Skenarionya dipindahkan ke `tests/Feature/Api/AdminApiTest.php` (endpoint API yang menggantikan), dan `PageRenderingTest` ditulis ulang untuk kerangka halaman.

## B. Lingkungan dan dependensi

- Repo menargetkan PHP 8.4 (lihat A.7).
- Dependensi PHP baru: `laravel/sanctum` (require) dan `knuckleswtf/scribe` (require-dev). Keduanya diminta prompt fase 2.
- Dependensi frontend (fase 1, sesuai stack prompt): `alpinejs`, `@alpinejs/focus`, `chart.js`, `leaflet`, `@fortawesome/fontawesome-free`, `@fontsource-variable/inter`. Inter di-host sendiri sehingga build tidak butuh internet.
- `CACHE_STORE=database` dan `QUEUE_CONNECTION=database` (Redis opsional, cukup ubah `.env`). Cache dipakai untuk buffer lokasi, idempotency, throttle broadcast, state ronde dispatch, dan rate limiter.
- `composer dev` kini juga menjalankan `reverb:start` dan `schedule:work`, karena pipeline lokasi (flush 10 detik) dan eskalasi dispatch bergantung pada scheduler.
- Timezone `Asia/Jakarta` (bisa diubah lewat `APP_TIMEZONE`), locale `id`. Pesan validasi Indonesia ada di `lang/id`.
- Disk `local` diset `serve => false`; berkas privat hanya lewat `GET /api/v1/media/{type}/{id}`.

## C. Keputusan perilaku dashboard admin

- **Login admin** tetap form session web (`/admin/login`). Halaman lain hanya kerangka Blade; Alpine memuat dan mengirim data ke `/api/v1/admin/*` dengan cookie yang sama (Sanctum stateful) dan header `X-CSRF-TOKEN`. Controller web lama dihapus setelah halamannya berjalan di atas API.
- **Wajib ganti password**: admin dengan `must_change_password = TRUE` diarahkan ke halaman ganti password; API admin membalas `403 password_change_required` sampai diganti.
- **Kredensial driver baru / reset password** dikirim satu kali di respons API, disimpan sementara di `sessionStorage` tab tersebut, ditampilkan sekali di detail driver, lalu dihapus. Server tidak menyimpan password asli.
- **Nonaktifkan driver** ditolak bila masih punya shift terbuka. **Ambulans yang sedang dipakai** tidak bisa diubah statusnya atau dipindah klinik. **Hapus ambulans/instansi/klinik** yang punya riwayat (FK RESTRICT) dijawab 409 dengan saran menonaktifkan.
- **Akhiri shift oleh admin** tidak mengubah status laporan yang sedang ditangani; UPDATE bersyarat `ended_at IS NULL` mencegah dobel (shift yang sudah tertutup: `409 shift_already_closed`).
- **Batalkan laporan** memakai UPDATE atomik `WHERE status = 'menunggu' AND taken_at IS NULL`; bila driver mengambil lebih dulu, pembatalan gagal dengan `409 report_not_cancellable`.
- **Jenis laporan aktif** wajib dilayani minimal satu jenis ambulans. Kode, `is_emergency`, dan `requires_destination` tidak bisa diubah karena dipakai aplikasi mobile.
- **Pembanding dashboard** = kemarin pada jam yang sama. **Statistik** membandingkan dengan periode sebelumnya yang sama panjang; granularitas otomatis. Daftar tahun di filter statistik kini dari API (`available_years`).
- **Log Lokasi** default 1 jam terakhir, maksimal 14 hari; dibuka dari detail laporan memakai jendela waktu laporan. Mode realtime aktif bila driver masih shift dan rentang berakhir dalam 5 menit terakhir.
- **Export CSV** (laporan dan statistik) berupa CSV UTF-8 dengan BOM. Route export berada di luar middleware `api.json` karena dibuka sebagai unduhan biasa oleh browser (tetap butuh session admin).
- **Rate limit admin** 300 permintaan/menit (bukan 60) karena satu halaman memuat beberapa panel sekaligus dan mem-polling saat WebSocket putus.

## D. Desain (antislop, mode during)

Arah desain dari prompt (palet merah, Inter, sidebar gelap, konten terang). Design read: *konsol operasional dispatch untuk admin pusat, padat dan utilitarian, merah brand sebagai satu-satunya aksen*; dial **ENERGY 1 / RHYTHM 2 / MOTION 1**.

- Merah brand hanya untuk navigasi, tombol utama, sinyal "menunggu", dan alarm eskalasi. Warna status semantik; warna jenis laporan dari `report_types.color` dengan warna teks dipilih otomatis agar kontras.
- Hanya tema terang (prompt menetapkan konten `#F8F7F5`).
- **Panel eskalasi dispatch** (fase 2) memakai kartu yang sama dengan panel lain; header berubah merah solid hanya saat ada alarm akhir. Suara: satu nada untuk eskalasi ronde, tiga nada untuk alarm akhir (Web Audio, tanpa berkas audio). Titik merah di lonceng topbar menandai alarm aktif.
- Gerak hanya transisi hover, pulse lokasi laporan aktif, dan titik berkedip laporan menunggu > 10 menit; semuanya mati dengan `prefers-reduced-motion`.
- Setiap daftar, peta, dan grafik punya state loading (skeleton), kosong, dan error (dengan tombol muat ulang).

## E. API v1: kontrak dan keamanan

- **Format respons** `{success, data, meta.pagination}` / `{success:false, error:{code, message, details}}` untuk semua endpoint, termasuk error framework (404 model, 401, 403, 429, 500) lewat satu renderer.
- **Validasi gagal = HTTP 400** `validation_failed` sesuai Bagian 4 prompt (bukan 422 bawaan Laravel). 422 dipakai untuk aturan bisnis.
- **Header `Accept: application/json` wajib**; tanpa itu `400 accept_header_required`. Pengecualian: unduhan berkas (`/media`) dan export CSV.
- **Token mobile** membawa ability `reporter` atau `driver`; grup route memeriksa ability dan role sekaligus. Login mobile menolak admin (`admin_use_dashboard`) dan akun nonaktif.
- **Gate `must_change_password`** membalas 403 (bukan 409) dengan `details.must_change_password = true`; pengecualian `me`, `change-password`, `logout`, `fcm`.
- **Idempotency-Key** berlaku untuk `POST /reporter/reports`, `POST /driver/reports/{id}/status`, dan juga `POST /driver/dispatches/{id}/accept` (ambil laporan adalah transisi `menunggu → diambil`; retry jaringan setelah menang tidak boleh berubah jadi error). Kunci disimpan 24 jam per pengguna; isi berbeda dengan kunci sama ditolak `422 idempotency_key_reused`.
- **Rate limit** dikunci per token (`personal_access_tokens.id`), atau per user untuk session dashboard, atau per IP bila belum masuk.
- **Kanal broadcast**: `admin` (laporan baru, status, eskalasi), `admin.tracking` (posisi driver), `report.{id}` (pemilik laporan, hanya saat status aktif). Aplikasi mobile mengotorisasi kanal lewat `POST /api/v1/broadcasting/auth` dengan Bearer token. Kanal admin lama `admin.reports` diganti `admin` sesuai prompt.
- **Event broadcast** memakai `ShouldBroadcastNow` + `ShouldDispatchAfterCommit`: dikirim langsung (tanpa menunggu worker) tetapi hanya setelah transaksi DB berhasil.
- **Reverb mati tidak menggagalkan request.** Driver broadcast `reverb` dibungkus `App\Broadcasting\ResilientPusherBroadcaster`: kegagalan kirim dicatat sebagai warning lalu request tetap berhasil (laporan, ambil laporan, flush lokasi). Dashboard dan aplikasi beralih ke polling 10 detik. Ditemukan saat uji browser: tanpa ini `POST /reporter/reports` membalas 500 ketika Reverb tidak berjalan.
- **Dokumentasi**: Scribe statis di `public/docs` (+ OpenAPI, Postman) dan panduan Flutter di `docs/api.md`. Scribe dijalankan dengan `APP_LOCALE=en` agar deskripsi aturan validasinya konsisten; pesan runtime tetap Indonesia. Config Scribe mengembalikan array kosong bila paket dev tidak terpasang (produksi `--no-dev`).

## F. Mesin dispatch dan eskalasi

- **Kandidat** = driver dengan shift terbuka, akun aktif, tidak `is_on_duty`, jenis ambulans shift diizinkan untuk jenis laporan. Jarak dihitung haversine dari `driver_last_locations` yang tercatat sejak shift dimulai; driver yang belum pernah mengirim lokasi pada shift itu memakai koordinat klinik ambulansnya (asumsi: driver baru membuka shift di klinik).
- **State ronde** (ronde ke-n, waktu mulai, sudah alarm) disimpan di cache, bukan kolom baru, karena v3 tidak punya kolomnya dan whitelist tidak mengizinkannya. Bila cache hilang, job eskalasi melanjutkan dari ronde 2 bila laporan sudah pernah dibroadcast (atau ronde 1 bila belum); UNIQUE `(report_id, driver_id)` mencegah driver yang sama menerima tawaran dua kali.
- **Ronde tanpa kandidat langsung naik** ke radius berikutnya pada request yang sama (tidak menunggu job). Setiap ronde setelah ronde pertama, termasuk ronde tanpa penerima, memicu `DispatchEscalated` ke admin; bila ronde terakhir tetap tanpa pengambil, alarm akhir dikirim (`is_final`).
- **Tawaran ronde lama** yang belum dijawab menjadi `kedaluwarsa` saat ronde baru dikirim, dan tidak bisa diambil lagi (`409 offer_expired`). Driver itu tidak menerima ulang laporan yang sama.
- **Pengambilan atomik**: klaim driver dulu (`UPDATE driver_profiles SET is_on_duty = TRUE WHERE is_on_duty = FALSE`), lalu `UPDATE reports ... WHERE status = 'menunggu'` dalam satu transaksi. Yang kalah mendapat `409 too_late` dan dispatch-nya `kalah_cepat`; tawaran lain yang tidak dijawab sampai laporan diambil atau dibatalkan ditandai `diabaikan` oleh job eskalasi berikutnya. `ambulance_id` diambil dari shift terbuka driver.
- **`GET /driver/dispatches/{id}`** ditambahkan (tidak ada di prompt) untuk mengisi `opened_at` saat driver membuka tawaran.
- **Laporan menunggu lebih dari 24 jam** tidak diproses job eskalasi lagi (`escalation_lookback_hours`) agar job tetap ringan.
- **FCM** HTTP v1 lewat job antrean, token akses OAuth dibuat dari service account (JWT RS256 dengan `openssl_sign`, tanpa paket tambahan) dan di-cache. Tanpa kredensial: mode log-only. Token perangkat `UNREGISTERED` dihapus.
- **Kode laporan** `MDR-YYMMDD-NNNN`: nomor berikutnya diambil dari MAX hari itu di dalam transaksi, dengan retry pada pelanggaran UNIQUE.
- **Uji balapan** menjalankan dua `accept` berurutan terhadap laporan yang sama (PHP test tidak menjalankan request paralel); keamanan race dijamin oleh UPDATE bersyarat di atas, bukan oleh urutan.

## G. Pipeline lokasi

- Interval: bertugas 5 detik, standby 25 detik, diam 60 detik (kecepatan < 2 km/j pada 2 titik terakhir), baterai < 20% dikali 2. Driver **bertugas selalu 5 detik** meskipun diam (mis. menunggu di lokasi), agar rute laporan tetap rapat; aturan "diam" hanya untuk standby.
- Buffer di cache dengan `Cache::lock`; flush tiap 10 detik melakukan satu bulk INSERT, upsert snapshot maksimal sekali per 15 detik per driver, dan broadcast maksimal sekali per 5 detik per driver (penjaga `Cache::add`).
- **Alasan tutup shift** wajib di API tetapi `driver_shifts` v3 tidak punya kolomnya (dan bukan whitelist); alasan dicatat ke log aplikasi bersama `end_reason = selesai_shift`.
- Prune memakai kolom `received_at` (ber-index) dengan `MassPrunable`, terjadwal 01.30 setiap hari.
- Peta Live, detail laporan, dan posisi untuk pelapor hanya membaca `driver_last_locations` + event; `driver_location_logs` hanya dibaca halaman Log Lokasi (riwayat).

## H. Hal yang sengaja tidak dibangun

Sesuai Bagian 19 prompt: registrasi driver mandiri, laporan dibuat admin, penugasan manual oleh admin, lepas laporan saat ambulans rusak, pembatalan oleh pelapor, dan penutupan shift otomatis. Endpoint `POST /api/v1/auth/register` selalu membuat role `pelapor`.

## I. Fase 3: chat, terverifikasi, rute/ETA, geocoding

### Perbedaan prompt vs repo

1. **Repo kini monorepo (`backend/` Laravel, `frontend/` Flutter).** Fase 1–2 dikerjakan saat repo masih berisi Laravel di root; isinya sudah dipindah ke `backend/` di `main`. Fase 3 dibangun di atas `main` itu dan hanya mengubah `backend/`; `frontend/` tidak disentuh.
2. **Path endpoint mengikuti prefix grup fase 2** (A.6): `GET /reports/{id}/chat` menjadi `/api/v1/reporter/reports/{id}/chat` dan `/api/v1/driver/reports/{id}/chat`; `/chat/unread-count` ada di kedua prefix; `PUT /profile` menjadi `PUT /api/v1/reporter/profile`; `GET /reports/{id}/route` menjadi `/api/v1/reporter/reports/{id}/route`; `GET /reports/{id}` (kartu driver) adalah `/api/v1/reporter/reports/{id}`. Geocoding dan media tetap di `/api/v1/geocode/*` dan `/api/v1/media/chat/{id}`.
3. **Push status ke pelapor sudah ada sejak fase 2** (ambil laporan, setiap transisi driver, pembatalan admin). Fase 3 hanya menambah test yang membuktikannya; payload memuat `report_id` dan `status` (ditambah `type` dan `report_code`).
4. **`/api/v1/broadcasting/auth` dengan Bearer token** sudah ada sejak fase 2; kanal `chat.{report}` ditambahkan di `routes/channels.php`.

### Chat

- Peserta = pelapor pemilik laporan dan driver di `reports.driver_id`, dengan akun aktif. Semua pihak lain mendapat `403 chat_forbidden`. Admin tidak punya rute chat (grup reporter/driver menolak role admin), kanal `chat.{report}` menolak admin, dan media chat menolak admin walaupun media lain boleh dibuka admin.
- Isi chat tidak masuk log: mode log-only FCM menyamarkan judul dan isi notifikasi chat, dan job `SendFcmNotification` memakai `ShouldBeEncrypted` sehingga cuplikan pesan terenkripsi di tabel `jobs`/`failed_jobs`. Admin activity log tidak mencatat apa pun dari chat (chat bukan aksi admin).
- Chat hanya bisa dikirim saat status `diambil`…`mengantar_pasien`. Pesan 409 `chat_closed` disesuaikan status: "Chat ditutup karena laporan sudah selesai." (selesai), "...sudah dibatalkan." (dibatalkan), "Chat dibuka setelah driver mengambil laporan." (menunggu). Riwayat dan tandai-baca tetap boleh setelah laporan ditutup.
- Riwayat memakai kursor `before_id` (bukan nomor halaman), sehingga pesan baru yang masuk saat menggulir tidak menggeser halaman. Metadata ada di `meta.cursor`, bukan `meta.pagination`.
- `ChatMessageRead` membawa `last_read_id` agar aplikasi pengirim bisa menandai semua pesannya sampai id itu tanpa daftar id.
- Foto chat disimpan di disk privat `local` (`storage/app/private/chat/{report_id}/`), maksimal 1 MB, jpg/png.

### Badge terverifikasi

- Sertifikat dihitung berlaku bila `expires_at` kosong atau `expires_at >= hari ini`. Prompt menulis `expires_at > NOW()`; karena kolomnya `DATE`, perbandingan dengan waktu sekarang akan menganggap sertifikat kedaluwarsa sejak pukul 00.01 di hari terakhirnya, sementara dashboard admin menyebut sertifikat kedaluwarsa hanya bila `expires_at < hari ini`. Aturan dashboard yang dipakai agar badge dan dashboard tidak bertentangan.

### Rute & ETA

- Kontrak `RouteProvider` + `OsrmProvider` (binding di `AppServiceProvider`). Posisi awal dari cache posisi terbaru / `driver_last_locations` (tidak pernah dari `driver_location_logs`).
- Cache per koordinat (4 desimal + arah) 60 detik; per laporan maksimal satu panggilan OSRM per 30 detik. Bila jendela 30 detik belum lewat dan koordinat berubah, rute terakhir laporan itu yang dikirim. Bila OSRM gagal: rute terakhir dengan `stale: true`, atau `502 route_unavailable` bila belum ada.
- Saat status `mengantar_pasien` dan laporan punya koordinat tujuan, rute mengarah ke tujuan antar (`target: destination`), karena titik jemput sudah dilewati. Di status lain rute ke titik jemput sesuai prompt.

### Geocoding

- Proxy Nominatim dengan header `User-Agent` dari `NOMINATIM_USER_AGENT`, `accept-language=id`, pencarian dibatasi `countrycodes=id`.
- Selain rate limit 30/menit per token, ada batas global 1 panggilan upstream per detik (kebijakan server publik Nominatim) yang membalas `429 geocode_busy`. Bisa dinaikkan lewat `NOMINATIM_UPSTREAM_PER_SECOND` bila memakai Nominatim sendiri. Respons gagal tidak di-cache.
- **CORS dipersempit**: sebelumnya bawaan Laravel mengizinkan semua origin (`*`). Kini hanya origin di `CORS_ALLOWED_ORIGINS` (default `APP_URL`), sehingga proxy rute/geocode tidak bisa dipakai situs lain lewat browser. Aplikasi Android/iOS tidak terpengaruh CORS; bila nanti ada Flutter Web, tambahkan origin-nya.

### Tidak dibangun

Fitur rating dalam bentuk apa pun (tabel, endpoint, maupun UI). UI admin tidak diubah; `is_verified` hanya ditambahkan di JSON `GET /api/v1/admin/drivers/{id}`.
