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
| `report_status` | Pelapor | `report_id`, `report_code`, `status` | Muat ulang detail laporan. Dikirim untuk setiap perubahan status: `diambil`, `dalam_perjalanan`, `tiba_di_lokasi`, `mengantar_pasien`, `selesai`, `dibatalkan` |
| `chat` | Pelapor atau driver (lawan bicara) | `report_id`, `report_code`, `message_id` | Buka layar chat laporan `report_id`. Judul = nama pengirim, isi = cuplikan teks atau "Mengirim foto" |

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

Foto driver, sertifikat, lampiran laporan, surat kematian, dan foto chat tidak punya URL publik. Field `url`/`photo_url` di respons menunjuk ke `GET /api/v1/media/{type}/{id}` yang memeriksa hak akses. Muat gambar dengan header `Authorization` (mis. `Image.network(url, headers: {...})`). Tambahkan `?download=1` untuk mengunduh.

## 9. Rate limit

| Endpoint | Batas |
|---|---|
| `POST /auth/login`, `POST /auth/register` | 5 / menit per email + IP |
| `POST /driver/location` | 60 / menit per token |
| `POST /reporter/reports` | 10 / menit per token |
| `POST .../reports/{id}/chat` | 30 pesan / menit per token |
| `GET /geocode/*` | 30 / menit per token, ditambah batas server 1 permintaan/detik ke Nominatim (`429 geocode_busy`) |
| Endpoint lain | 60 / menit per token |

Saat 429, tunggu sesuai header `Retry-After` sebelum mencoba lagi.

## 10. Chat pelapor ↔ driver

Room chat adalah laporan itu sendiri. Pesertanya hanya pelapor pemilik laporan dan driver yang mengambilnya; akun lain, termasuk admin, selalu mendapat `403 chat_forbidden`. Admin dashboard tidak punya endpoint, kanal, maupun tampilan chat.

Endpoint identik di kedua aplikasi (`{app}` = `reporter` atau `driver`):

| Endpoint | Fungsi |
|---|---|
| `GET /{app}/reports/{id}/chat?before_id=` | Riwayat, urut lama → baru, 30 pesan per halaman |
| `POST /{app}/reports/{id}/chat` | Kirim pesan teks (JSON) atau foto (multipart) |
| `POST /{app}/reports/{id}/chat/read` | Tandai semua pesan lawan bicara sudah dibaca |
| `GET /{app}/chat/unread-count` | Jumlah belum dibaca untuk badge |
| `GET /media/chat/{messageId}` | Foto chat (hanya dua peserta) |

Kirim teks:

```json
POST /api/v1/reporter/reports/3/chat
{ "type": "text", "body": "Pasien di lantai 2, pintu samping." }
```

Kirim foto (multipart): `type=image`, `image=<file jpg/png>`. Server menolak di atas 1 MB; kompres di aplikasi ke sekitar 300 KB (mis. `flutter_image_compress`, sisi terpanjang 1280 px, kualitas 70).

Pesan (respons `POST`, isi `data` pada riwayat, dan payload event):

```json
{
  "id": 41,
  "report_id": 3,
  "sender_id": 1,
  "sender_name": "Budi Santoso",
  "type": "image",
  "body": null,
  "image_url": "https://<domain>/api/v1/media/chat/41",
  "mime_type": "image/jpeg",
  "size_kb": 286,
  "read_at": null,
  "created_at": "2026-10-21T10:15:03+07:00",
  "is_mine": true
}
```

`is_mine` hanya ada di respons API, tidak di event.

**Riwayat bertahap**: respons `GET` membawa `meta.cursor = { per_page, has_more, next_before_id }` dan `meta.is_open`. Untuk memuat pesan lebih lama saat pengguna menggulir ke atas, panggil lagi dengan `?before_id=<next_before_id>` sampai `has_more = false`.

**Chat tertutup**: kirim hanya bisa selama status laporan `diambil`, `dalam_perjalanan`, `tiba_di_lokasi`, atau `mengantar_pasien`. Di luar itu server membalas `409 chat_closed` ("Chat ditutup karena laporan sudah selesai.", atau pesan sesuai status). Riwayat tetap bisa dibaca setelah laporan selesai. Pesan tidak bisa diedit atau dihapus.

**Realtime**: subscribe kanal privat `private-chat.{reportId}` (otorisasi Bearer seperti bagian 6). Nama event persis seperti di tabel (tanpa awalan titik, karena server memakai `broadcastAs`):

| Event | Payload | Aksi |
|---|---|---|
| `ChatMessageSent` | objek pesan di atas tanpa `is_mine` | Tambahkan ke daftar; abaikan bila `sender_id` = user sendiri (sudah ada dari respons POST) |
| `ChatMessageRead` | `report_id`, `reader_id`, `last_read_id`, `read_at` | Tandai pesan sendiri dengan `id <= last_read_id` sebagai dibaca |

Contoh dengan `pusher_client`:

```dart
final pusher = PusherClient(
  reverbAppKey,
  PusherOptions(
    host: reverbHost,          // REVERB_HOST
    wsPort: reverbPort,        // REVERB_PORT
    encrypted: reverbScheme == 'https',
    cluster: 'mt1',            // diabaikan Reverb, wajib diisi paket
    auth: PusherAuth(
      '$apiBase/api/v1/broadcasting/auth',
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    ),
  ),
  autoConnect: false,
);
await pusher.connect();
final channel = pusher.subscribe('private-chat.$reportId');
channel.bind('ChatMessageSent', (event) => onMessage(jsonDecode(event!.data!)));
channel.bind('ChatMessageRead', (event) => onRead(jsonDecode(event!.data!)));
```

Saat layar chat dibuka atau kembali ke foreground, muat ulang riwayat terbaru lalu panggil `.../chat/read`. Bila WebSocket putus, polling `GET .../chat` tiap 10 detik.

## 11. Rute & ETA

| Endpoint | Untuk |
|---|---|
| `GET /reporter/reports/{id}/route` | Pelapor pemilik laporan: rute ambulans → titik jemput |
| `GET /driver/route` | Driver: posisinya → titik jemput laporan aktif |

Saat status `mengantar_pasien` dan laporan punya koordinat tujuan, rute mengarah ke tujuan antar (`target: "destination"`).

```json
{
  "report_id": 3,
  "distance_km": 3.46,
  "duration_min": 7.2,
  "geometry": [[-6.9932, 110.4203], [-6.995, 110.422]],
  "target": "pickup",
  "from": { "latitude": -6.9932, "longitude": 110.4203, "updated_at": "2026-10-21T10:15:00+07:00" },
  "to": { "latitude": -6.9981, "longitude": 110.4251 },
  "stale": false,
  "computed_at": "2026-10-21T10:15:02+07:00"
}
```

`geometry` sudah dalam urutan `[lat, lng]` dan disederhanakan; gambar langsung sebagai polyline. Server memanggil OSRM paling sering sekali per 30 detik per laporan dan menyimpan hasil 60 detik, jadi polling lebih cepat dari 30 detik tidak memberi rute baru. Gerakan ambulans di antara dua rute tetap dari event `DriverLocationUpdated`.

Bila OSRM gagal tetapi ada rute sebelumnya, respons memakai rute itu dengan `stale: true` (tampilkan ETA sebagai perkiraan). Tanpa rute sebelumnya: `502 route_unavailable`. Error lain: `409 route_unavailable_status` (laporan belum diambil / sudah selesai), `409 driver_location_unavailable`, `409 no_active_report` (driver).

## 12. Geocoding

Aplikasi **wajib** memakai endpoint ini; jangan memanggil Nominatim atau OSRM langsung dari aplikasi (kebijakan penggunaan server publik, kuota, dan cache bersama ada di backend).

- `GET /geocode/reverse?lat=-6.9932&lng=110.4203` → `{ "address": "Jl. Pahlawan, ...", "latitude": ..., "longitude": ... }`. `address` bisa `null` bila tidak ditemukan. Cache 24 jam.
- `GET /geocode/search?q=simpang lima&limit=5` → `[{ "label": "...", "latitude": -6.99, "longitude": 110.42 }]`. Minimal 3 huruf, wilayah Indonesia, cache 10 menit.

Panggil pencarian setelah pengguna berhenti mengetik ±600 ms (debounce). Error: `502 geocode_unavailable`, `429 geocode_busy` (coba lagi 1–2 detik kemudian).

## 13. Profil pelapor dan badge terverifikasi

`PUT /reporter/profile` dengan `{ "name", "phone" }`. Email dan role tidak bisa diubah lewat endpoint ini (field lain diabaikan).

Field `is_verified` (boolean) menandai driver yang punya minimal satu sertifikat masih berlaku hari ini. Tersedia di `GET /driver/profile`, di kartu `driver` pada `GET /reporter/reports/{id}`, dan di `GET /admin/drivers/{id}`. Tampilkan badge "Terverifikasi" bila `true`.

## 14. Membuat ulang dokumentasi Scribe

```bash
APP_LOCALE=en php artisan scribe:generate
```

`APP_LOCALE=en` dipakai agar deskripsi aturan validasi yang dibuat Scribe konsisten (Scribe membentuk kalimatnya dari pesan validasi bahasa Inggris). Pesan error API saat runtime tetap berbahasa Indonesia.
