# Asumsi dan Keputusan: Dashboard Admin Medrive

Dokumen ini mencatat asumsi, keputusan teknis, dan **perbedaan antara prompt dengan kondisi repo** selama pembuatan dashboard admin.

## A. Perbedaan prompt vs repo (perlu diketahui)

1. **File `medrive_db_v3.sql` dan `medrive_erd_v3.dbml` tidak ada di repo.** Acuan skema yang dipakai adalah 23 migration di `database/migrations/2026_10_12_0000xx_*` serta `MasterDataSeeder`/`DemoDataSeeder` yang menyatakan diri "dibuat otomatis dari medrive_db_v3.sql". Migration tersebut sudah memuat nama tabel, kolom, ENUM, FK, UNIQUE, dan CHECK v3, jadi tidak ada tabel/kolom yang ditambah atau diubah.
2. **Tidak ada REST API mobile di repo** (tidak ada `routes/api.php`, tidak ada controller API, Sanctum tidak terpasang). "Jangan mengubah API mobile" terpenuhi karena tidak ada yang disentuh. Model lama `User` memakai trait `Laravel\Sanctum\HasApiTokens` padahal paket Sanctum tidak ada di `composer.json` (akan fatal saat model dimuat), sehingga trait itu dihapus. Bila API mobile dibuat nanti dengan Sanctum, trait bisa ditambahkan kembali setelah `composer require laravel/sanctum`.
3. **Model lama `DriverProfile` dan `Report` mengikuti skema versi lama** (kolom `plate_number`, `is_active`, `last_lat`, `victim_count`, `photo_path` di laporan, dst. yang tidak ada di v3). Keduanya ditulis ulang mengikuti v3.
4. **`driver_last_locations` tidak punya kolom `battery_level`.** Karena Peta Live dilarang membaca `driver_location_logs`, baterai di Peta Live hanya muncul dari payload event `DriverLocationUpdated` (ditampilkan "menunggu ping" sampai event pertama datang). Halaman Log Lokasi tetap menampilkan baterai dari log.
5. **`ambulance_types` tidak punya kolom ikon.** Ikon marker per jenis ambulans dipetakan dari kode jenis di `config/medrive.php` (`ambulance_type_icons`).
6. **Pipeline lokasi (Redis buffer) belum ada di repo.** Event `App\Events\DriverLocationUpdated` sudah dibuat (kanal privat `admin.tracking`, payload sesuai prompt). Endpoint penerima ping lokasi dari aplikasi driver perlu memanggil `DriverLocationUpdated::dispatch([...])` setiap ping diterima.
7. **Event `ReportCreated`** dipicu otomatis lewat `$dispatchesEvents` di model `Report` (event Eloquent `created`), jadi endpoint pembuatan laporan di API mobile nanti tidak perlu kode tambahan selama memakai Eloquent (bukan `DB::table()->insert`).
8. **Migration `driver_shifts`**: ekspresi kolom generated `IF(...)` hanya ada di MySQL. Untuk SQLite (test suite) dipakai `CASE WHEN` yang setara; di MySQL tetap persis `IF(...)` seperti v3. Ini bukan perubahan skema.

## B. Lingkungan dan dependensi

- Repo menargetkan PHP 8.4 (lock file Symfony 8 butuh PHP >= 8.4.1). Lingkungan pengerjaan hanya punya PHP 8.3, sehingga verifikasi lokal memakai set dependensi sementara yang tidak di-commit; `composer.json` dan `composer.lock` tidak diubah.
- Dependensi frontend yang ditambahkan (sesuai stack di prompt): `alpinejs`, `@alpinejs/focus` (focus trap modal), `chart.js`, `leaflet`, `@fortawesome/fontawesome-free`, `@fontsource-variable/inter`.
  - **Inter di-host sendiri** lewat `@fontsource-variable/inter` menggantikan plugin font Bunny (yang mengunduh dari `fonts.bunny.net` saat build). Build jadi tidak butuh internet dan dashboard tidak bergantung pada CDN font.
  - **Font Awesome (solid)** dipakai karena nilai `report_types.icon` di data v3 (`car-crash`, `heart-pulse`, `baby`, `bed`) adalah nama ikon Font Awesome. Admin bisa mengetik nama ikon FA lain di form jenis laporan.
- `.env.example`: `DB_CONNECTION=mysql` ke `medrive_db`, `BROADCAST_CONNECTION=reverb` + variabel `REVERB_*`/`VITE_REVERB_*`, dan `CACHE_STORE=file` karena tabel `cache` tidak ada di skema v3 (rate limiter login butuh cache). Di produksi bisa pakai `redis`.
- Timezone aplikasi diset `Asia/Jakarta` (bisa diubah lewat `APP_TIMEZONE`) karena data contoh dan jam di topbar memakai WIB. Locale `id` untuk format tanggal.
- Event broadcast memakai `ShouldBroadcastNow` agar tidak butuh tabel `jobs` (tidak ada di skema v3).
- Disk `local` diset `serve => false`: berkas privat (foto driver, sertifikat, lampiran laporan) tidak bisa dibuka lewat URL `/storage/...`, hanya lewat route admin ber-otorisasi.

## C. Keputusan perilaku

- **Login admin**: ditolak dengan pesan berbeda untuk role bukan admin dan admin nonaktif. Rate limit 5 percobaan per menit per email+IP. Tidak ada "ingat saya" karena `users` v3 tidak punya `remember_token`, jadi kolom tambahan tidak diperlukan.
- **Wajib ganti password**: admin dengan `must_change_password = TRUE` dialihkan ke halaman ganti password sebelum halaman lain bisa dibuka.
- **Kredensial driver baru** disimpan sementara di session dalam bentuk terenkripsi (`Crypt`), ditampilkan sekali di halaman detail driver, lalu hilang. Halaman itu dikirim dengan `Cache-Control: no-store`.
- **Form tambah driver** punya seksi ke-4 opsional untuk sertifikat (DoD menyebut sertifikat ikut dalam satu transaksi). Satu transaksi DB untuk users + driver_profiles + driver_certifications; bila gagal, berkas yang sudah tersimpan ikut dihapus.
- **Validasi nomor polisi**: format huruf wilayah + angka + huruf akhir (mis. `H 1234 AB`), disimpan huruf besar dengan spasi dirapikan.
- **Nonaktifkan driver** ditolak bila masih punya shift terbuka (diarahkan ke tab Shift).
- **Ambulans yang sedang dipakai shift terbuka** tidak bisa diubah statusnya dari tersedia atau dipindah klinik; akhiri shift dulu.
- **Hapus ambulans** ditolak bila punya riwayat shift *atau* sudah tercatat di laporan (keduanya FK RESTRICT).
- **Akhiri shift oleh admin** tidak mengubah status laporan yang sedang ditangani dan tidak mengubah `driver_profiles.is_on_duty`; modal memberi peringatan bila driver sedang bertugas. UPDATE bersyarat `ended_at IS NULL` mencegah dobel.
- **Batalkan laporan** memakai UPDATE atomik `WHERE status = 'menunggu' AND taken_at IS NULL`, sehingga bila driver menekan "ambil" di saat yang sama, pembatalan otomatis gagal dengan pesan jelas. Baris `report_dispatches` laporan tersebut tidak diubah (alur respons dispatch milik aplikasi driver).
- **Jenis laporan aktif** wajib dilayani minimal satu jenis ambulans (kalau tidak, broadcast tidak punya penerima). Kode, `is_emergency`, dan `requires_destination` tidak bisa diubah karena dipakai aplikasi mobile.
- **Pembanding dashboard** = "kemarin pada jam yang sama", direkonstruksi dari kolom waktu (`created_at`, `taken_at`, `completed_at`, `started_at`/`ended_at`). Untuk laporan menunggu yang dibatalkan, waktu batal didekati dengan `updated_at`.
- **"Ambulans siaga"** di kartu dashboard = ambulans berstatus tersedia yang tidak sedang dipakai shift terbuka; perawatan dan nonaktif ditampilkan terpisah.
- **Laporan aktif di Peta Live** = status diambil dan dalam perjalanan (sesuai prompt), dengan efek pulse.
- **Marker berputar**: badan ikon tetap tegak agar terbaca; segitiga penunjuk arah yang diputar sesuai `heading`.
- **Log Lokasi**: default 1 jam terakhir, maksimal 14 hari. Dibuka dari detail laporan, rentang otomatis = waktu diambil sampai selesai (atau sekarang). Jarak haversine dihitung sambil men-stream baris (lazy); titik peta disampel bila lebih dari 3000 titik. Semua query diawali `driver_id` + rentang `recorded_at` (index `idx_dlog_driver_time`). Mode realtime aktif bila driver punya shift terbuka dan rentang berakhir dalam 5 menit terakhir; fallback polling memakai `driver_last_locations`.
- **Statistik**: granularitas rentang kustom otomatis (<= 2 hari per jam, <= 92 hari per hari, selebihnya per bulan). Periode pembanding = periode sebelumnya yang sama panjang (bulan ini vs bulan lalu, tahun vs tahun lalu). Cache 60 detik untuk rentang yang berakhir "sekarang", 5 menit untuk rentang historis.
- **Export** berupa CSV UTF-8 dengan BOM (terbuka benar di Excel); tidak menambah dependensi spreadsheet.
- **Format aksi log**: `driver.created/updated/activated/deactivated`, `certification.created/updated/deleted`, `shift.ended`, `ambulance.created/updated/status_changed/deleted`, `ambulance_type.updated`, `institution.*`, `clinic.*`, `report_type.updated`, `report.cancelled`, `reporter.activated/deactivated`, `admin.password_changed`. `subject_type` = nama tabel, sesuai data contoh.
- Root `/` tetap halaman welcome bawaan agar test bawaan repo tidak berubah; dashboard ada di `/admin`.

## D. Desain (antislop, mode during)

Arah desain dari prompt (palet merah, Inter, sidebar gelap, konten terang). Design read: *konsol operasional dispatch untuk admin pusat, padat dan utilitarian, merah brand sebagai satu-satunya aksen*; dial **ENERGY 1 / RHYTHM 2 / MOTION 1**.

- **Warna**: merah brand hanya untuk navigasi, tombol utama, dan sinyal "menunggu". Warna status laporan semantik sesuai prompt; warna jenis laporan diambil dari `report_types.color`, dengan warna teks putih/gelap dipilih otomatis agar kontras WCAG.
- **Tema**: hanya terang, karena prompt menetapkan area konten terang (`#F8F7F5`); tidak ada toggle gelap.
- **Fokus per layar**: dashboard menjadikan kartu "Laporan menunggu driver" satu-satunya blok merah solid.
- **Gerak**: hanya transisi hover/dropdown, pulse untuk lokasi laporan aktif, dan titik berkedip untuk laporan menunggu > 10 menit. Semuanya mati bila pengguna memilih `prefers-reduced-motion`.
- **Aset**: tidak ada logo buatan; wordmark "Medrive" berupa teks + ikon ambulans. Avatar fallback memakai inisial.
- **Status UI**: setiap daftar, peta, dan grafik punya state kosong, loading (skeleton), dan error.
