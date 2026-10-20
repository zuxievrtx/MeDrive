# Medrive API v1: panduan integrasi aplikasi Flutter

Referensi lengkap setiap endpoint (parameter, aturan validasi, contoh request) dibuat oleh Scribe di `public/docs/index.html`, ditambah `public/docs/openapi.yaml` dan `public/docs/collection.json` (Postman). Dokumen ini menjelaskan alur yang tidak terlihat dari daftar endpoint: autentikasi, notifikasi, pelacakan lokasi, realtime, dan penanganan error.

Base URL: `https://<domain>/api/v1`. Semua request **wajib** mengirim `Accept: application/json`; tanpa header itu server membalas `400 accept_header_required`.

## 1. Format respons

Sukses:

```json
{
  "success": true,
  "data": { "...": "..." },
  "meta": { "pagination": { "current_page": 1, "last_page": 3, "per_page": 20, "total": 47 } }
}
```

`meta` hanya ada pada daftar ber-halaman. Error:

```json
{
  "success": false,
  "error": {
    "code": "validation_failed",
    "message": "Data tidak valid.",
    "details": { "latitude": ["Latitude wajib diisi."] }
  }
}
```

| HTTP | Arti | Contoh `error.code` |
|---|---|---|
| 400 | Validasi gagal / request salah | `validation_failed`, `accept_header_required` |
| 401 | Token tidak ada / dicabut | `unauthenticated`, `invalid_credentials` |
| 403 | Tidak berhak | `role_forbidden`, `account_inactive`, `password_change_required`, `not_your_report` |
| 404 | Data tidak ditemukan | `not_found` |
| 409 | Konflik keadaan | `too_late`, `shift_already_open`, `ambulance_in_use`, `invalid_transition`, `no_open_shift` |
| 422 | Aturan bisnis | `patient_handover_required`, `destination_required`, `idempotency_key_reused` |
| 429 | Terlalu sering | `too_many_requests` (lihat header `Retry-After`) |

Tampilkan `error.message` apa adanya ke pengguna (sudah berbahasa Indonesia). Gunakan `error.code` untuk logika aplikasi, jangan mencocokkan teks pesan. Untuk 400, tampilkan `details[field][0]` di bawah field terkait.

## 2. Autentikasi

1. `POST /auth/register` (khusus aplikasi Pelapor): role selalu `pelapor`. Driver tidak bisa mendaftar sendiri, akunnya dibuat admin.
2. `POST /auth/login` dengan `email`, `password`, dan `device_name` (opsional, nama perangkat untuk token). Respons berisi `data.token` dan `data.user`. Token Sanctum membawa ability `reporter` atau `driver`; token pelapor tidak bisa memanggil endpoint driver dan sebaliknya (403). Akun admin ditolak (`admin_use_dashboard`).
3. Simpan token di secure storage dan kirim sebagai `Authorization: Bearer <token>`.
4. Bila `data.user.must_change_password = true` (akun driver baru atau setelah reset admin), tampilkan layar ganti password. Semua endpoint fitur membalas `403 password_change_required` sampai `POST /auth/change-password` berhasil. Ganti password mencabut token lain milik akun.
5. `POST /auth/logout` mencabut token yang sedang dipakai. Saat menerima 401, hapus token lokal dan kembali ke layar login.

Rate limit: login dan register 5 kali per menit per email + IP.

## 3. Push notification (FCM)

Setelah login dan setiap kali `FirebaseMessaging.onTokenRefresh` terpicu, kirim `POST /auth/fcm` dengan `fcm_token`, `platform` (`android`/`ios`), `device_model`, `app_version`. Token yang sama tidak membuat baris baru (upsert). Server menghapus token yang dilaporkan FCM sebagai `UNREGISTERED`.

Isi `data` notifikasi:

| `type` | Penerima | Field | Aksi aplikasi |
|---|---|---|---|
| `dispatch` | Driver | `dispatch_id`, `report_id`, `report_code`, `report_type`, `distance_km`, `priority` | Buka layar tawaran, panggil `GET /driver/dispatches/{dispatch_id}` (menandai tawaran dibuka) |
| `report_status` | Pelapor | `report_id`, `report_code`, `status` | Muat ulang detail laporan |

Notifikasi bisa terlambat atau hilang. Aplikasi driver tetap memanggil `GET /driver/dispatches/active` saat dibuka dan saat kembali ke foreground.

## 4. Alur aplikasi Driver

1. `GET /driver/profile`, lalu `GET /driver/ambulances/available` (ambulans tersedia di klinik driver yang jenisnya cocok).
2. `POST /driver/shifts` dengan `ambulance_id`. Satu driver satu shift terbuka; satu ambulans hanya untuk satu shift terbuka.
3. Mulai pelacakan lokasi (bagian 5) selama shift terbuka.
4. Tawaran laporan datang lewat FCM `dispatch`. Broadcast dikirim bertahap: radius 5 km, lalu 10 km, 15 km, kemudian semua driver yang memenuhi syarat. Setiap ronde baru membuat tawaran ronde sebelumnya kedaluwarsa.
5. `POST /driver/dispatches/{id}/accept`. Hanya satu driver yang menang. Yang kalah menerima `409 too_late`; tawaran kedaluwarsa menerima `409 offer_expired`. Tampilkan pesan lalu tutup layar tawaran.
6. Ubah status lewat `POST /driver/reports/{id}/status` dengan `status`: `dalam_perjalanan` → `tiba_di_lokasi` → (`mengantar_pasien` →) `selesai`. Jenis laporan dengan tujuan (ibu hamil, jenazah) wajib melewati `mengantar_pasien`. `selesai` memerlukan minimal satu pasien yang sudah diserahterimakan (`PUT /driver/patients/{id}` dengan `handed_over_to`).
7. Foto penanganan: `POST /driver/reports/{id}/attachments` (multipart, `photos[]`).
8. `POST /driver/shifts/close` dengan `reason` (wajib). Shift tidak bisa ditutup saat masih menangani laporan, dan server tidak pernah menutup shift otomatis.

## 5. Pelacakan lokasi driver (adaptif + batching)

Kirim titik ke `POST /driver/location` hanya selama shift terbuka (tanpa shift: `409 no_open_shift`, hentikan pelacakan).

```json
{
  "points": [
    {
      "latitude": -6.9932,
      "longitude": 110.4203,
      "accuracy_m": 8.5,
      "speed_kmh": 32.4,
      "heading": 270,
      "altitude_m": 12,
      "battery_level": 64,
      "provider": "fused",
      "is_mock_location": false,
      "recorded_at": "2026-10-15T10:12:03.120+07:00"
    }
  ],
  "device": { "fcm_token": "...", "app_version": "1.4.0", "device_model": "SM-A155F" }
}
```

Aturan klien:

- **Batching**: kumpulkan titik, kirim saat sudah 10 titik **atau** titik tertua berumur 15 detik, mana yang lebih dulu. Maksimal 10 titik per request (`max_batch_points`, `max_batch_age_seconds` ada di respons).
- **Interval adaptif**: respons berisi `next_interval_seconds`. Pakai nilai ini untuk jadwal pengambilan titik berikutnya; jangan menghitung sendiri. Nilai default server: 5 detik saat bertugas, 25 detik saat standby, 60 detik saat diam (kecepatan < 2 km/j beberapa titik berturut-turut), dikali dua bila baterai < 20%.
- **Distance filter**: saat standby, titik boleh diambil lebih awal bila sudah berpindah ≥ `distance_filter_m` (50 m).
- `recorded_at` adalah waktu GPS di perangkat (ISO 8601 dengan zona waktu). Titik lebih dari 1 menit di masa depan atau lebih tua dari masa simpan log ditolak.
- Kirim `is_mock_location` jujur dari API platform (Android `Location.isMock`). Admin melihat titik palsu ditandai merah.
- Validasi per titik: titik yang salah ditolak sendiri tanpa menggagalkan batch. Respons `rejected: [{ index, reason }]`; jangan kirim ulang titik yang ditolak.
- Saat offline, simpan titik di antrean lokal dan kirim bertahap (10 per request) setelah online. Rate limit 60 request per menit per token.

Respons:

```json
{
  "success": true,
  "data": {
    "accepted": 9,
    "rejected": [{ "index": 3, "reason": "Heading harus 0 sampai 359." }],
    "next_interval_seconds": 5,
    "distance_filter_m": 50,
    "max_batch_points": 10,
    "max_batch_age_seconds": 15,
    "server_time": "2026-10-15T10:12:20+07:00"
  }
}
```

## 6. Realtime untuk aplikasi Pelapor (posisi ambulans)

Server memakai Laravel Reverb (protokol Pusher). Di Flutter gunakan klien Pusher Channels (mis. `dart_pusher_channels`) dengan:

- host/port/scheme = nilai `REVERB_HOST`, `REVERB_PORT`, `REVERB_SCHEME`, app key = `REVERB_APP_KEY`;
- otorisasi kanal privat ke `POST /api/v1/broadcasting/auth` dengan header `Authorization: Bearer <token>` dan `Accept: application/json`, body `socket_id` + `channel_name`.

Kanal `private-report.{reportId}` hanya bisa disubscribe pemilik laporan selama laporan aktif (sudah diambil sampai mengantar pasien). Event:

| Event | Payload | Aksi |
|---|---|---|
| `DriverLocationUpdated` | `lat`, `lng`, `heading`, `speed_kmh`, `updated_at` | Gerakkan marker ambulans |
| `ReportStatusChanged` | `id`, `code`, `status`, `from_status`, ... | Perbarui status; berhenti subscribe saat `selesai`/`dibatalkan` |

**Interpolasi marker**: posisi datang paling cepat tiap 5 detik. Animasikan marker dari posisi lama ke posisi baru selama ±1 detik (tween lat/lng linear) dan putar ikon ke `heading`, agar gerakan tidak melompat.

**Fallback polling**: bila koneksi WebSocket gagal atau terputus lebih dari 15 detik, panggil `GET /reporter/reports/{id}/driver-location` setiap 10 detik (respons di-cache server 5 detik) sampai WebSocket tersambung lagi. Respons `409 tracking_unavailable` berarti laporan tidak sedang ditangani; hentikan polling.

## 7. Idempotency-Key

Endpoint berikut menerima header `Idempotency-Key` (string unik buatan klien, mis. UUID v4):

- `POST /reporter/reports`
- `POST /driver/dispatches/{id}/accept`
- `POST /driver/reports/{id}/status`

Buat satu key per aksi pengguna dan pakai key yang sama untuk setiap retry aksi itu (timeout, koneksi putus). Dalam 24 jam, request ulang dengan key dan isi yang sama mendapat respons pertama lagi (header `Idempotent-Replayed: true`) tanpa membuat laporan atau log status ganda. Key yang sama dengan isi berbeda ditolak `422 idempotency_key_reused`.

## 8. Berkas privat

Foto driver, sertifikat, lampiran laporan, dan surat kematian tidak punya URL publik. Field `url`/`photo_url` di respons menunjuk ke `GET /api/v1/media/{type}/{id}` yang memeriksa hak akses. Muat gambar dengan header `Authorization` (mis. `Image.network(url, headers: {...})`). Tambahkan `?download=1` untuk mengunduh.

## 9. Rate limit

| Endpoint | Batas |
|---|---|
| `POST /auth/login`, `POST /auth/register` | 5 / menit per email + IP |
| `POST /driver/location` | 60 / menit per token |
| `POST /reporter/reports` | 10 / menit per token |
| Endpoint lain | 60 / menit per token |

Saat 429, tunggu sesuai header `Retry-After` sebelum mencoba lagi.

## 10. Membuat ulang dokumentasi Scribe

```bash
APP_LOCALE=en php artisan scribe:generate
```

`APP_LOCALE=en` dipakai agar deskripsi aturan validasi yang dibuat Scribe konsisten (Scribe membentuk kalimatnya dari pesan validasi bahasa Inggris). Pesan error API saat runtime tetap berbahasa Indonesia.
