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
