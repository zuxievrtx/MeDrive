# Deploy Medrive

Medrive butuh empat proses: web (PHP-FPM / Octane), queue worker, Reverb (WebSocket), dan scheduler. Redis tidak wajib: cache, antrean, buffer lokasi, idempotency, dan lock berjalan di MySQL (`CACHE_STORE=database`, `QUEUE_CONNECTION=database`).

## 1. Kebutuhan

- PHP 8.4 dengan ekstensi `pdo_mysql`, `openssl`, `mbstring`, `intl`, `pcntl` (Reverb), `gd` (gambar).
- MySQL 8.0+.
- Node 20+ hanya untuk build aset.
- Opsional: Redis 6+ (lihat bagian 6).

## 2. Langkah pertama kali

```bash
composer install --no-dev --optimize-autoloader
cp .env.example .env            # lalu isi nilai produksi
php artisan key:generate
npm ci && npm run build
php artisan migrate --force
php artisan db:seed --class=MasterDataSeeder --force   # data master v3 (jenis laporan, jenis ambulans, dst.)
php artisan config:cache && php artisan route:cache && php artisan view:cache
```

Nilai `.env` yang wajib diubah untuk produksi:

| Kunci | Keterangan |
|---|---|
| `APP_ENV=production`, `APP_DEBUG=false`, `APP_URL` | URL publik HTTPS |
| `DB_*` | Koneksi MySQL `medrive_db` |
| `SANCTUM_STATEFUL_DOMAINS` | Domain dashboard admin (tanpa skema), mis. `medrive.example.id` |
| `SESSION_DOMAIN`, `SESSION_SECURE_COOKIE=true` | Cookie session dashboard |
| `REVERB_APP_KEY`, `REVERB_APP_SECRET` | String acak; key yang sama dipakai aplikasi Flutter |
| `REVERB_HOST`, `REVERB_PORT=443`, `REVERB_SCHEME=https` | Alamat publik WebSocket (lewat reverse proxy) |
| `FCM_PROJECT_ID`, `FCM_CLIENT_EMAIL`, `FCM_PRIVATE_KEY` | Dari service account Firebase. Kosong = mode log-only |

Setelah mengubah `.env` di produksi, jalankan ulang `php artisan config:cache`, lalu `php artisan queue:restart` dan `php artisan reverb:restart`.

## 3. Supervisor

`/etc/supervisor/conf.d/medrive.conf`:

```ini
[program:medrive-queue]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/medrive/artisan queue:work database --sleep=1 --tries=3 --backoff=10 --max-time=3600
directory=/var/www/medrive
user=www-data
numprocs=2
autostart=true
autorestart=true
stopwaitsecs=3600
redirect_stderr=true
stdout_logfile=/var/www/medrive/storage/logs/queue.log

[program:medrive-reverb]
command=php /var/www/medrive/artisan reverb:start --host=0.0.0.0 --port=8080
directory=/var/www/medrive
user=www-data
autostart=true
autorestart=true
stopwaitsecs=10
minfds=10000
redirect_stderr=true
stdout_logfile=/var/www/medrive/storage/logs/reverb.log

[program:medrive-scheduler]
command=php /var/www/medrive/artisan schedule:work
directory=/var/www/medrive
user=www-data
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/var/www/medrive/storage/logs/scheduler.log
```

```bash
sudo supervisorctl reread && sudo supervisorctl update && sudo supervisorctl status
```

`schedule:work` dipakai (bukan cron per menit) karena flush buffer lokasi berjalan tiap 10 detik. Jadwal yang berjalan:

| Perintah | Interval | Fungsi |
|---|---|---|
| `medrive:flush-locations` | 10 detik | Bulk insert buffer ke `driver_location_logs`, upsert `driver_last_locations`, broadcast |
| `medrive:escalate-dispatches` | 1 menit | Ronde radius berikutnya / alarm akhir untuk laporan menunggu |
| `model:prune` (`DriverLocationLog`) | harian | Hapus log lokasi lebih tua dari 14 hari |

Bila scheduler mati, ping lokasi tetap diterima tetapi tertahan di buffer dan Peta Live tidak bergerak; eskalasi dispatch juga berhenti. Pantau proses ini.

## 4. Reverse proxy (Nginx) untuk Reverb

```nginx
location /app {
    proxy_http_version 1.1;
    proxy_set_header Host $http_host;
    proxy_set_header Scheme $scheme;
    proxy_set_header SERVER_PORT $server_port;
    proxy_set_header REMOTE_ADDR $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
    proxy_pass http://127.0.0.1:8080;
}

location /apps {
    proxy_pass http://127.0.0.1:8080;
}
```

Dengan konfigurasi ini set `REVERB_HOST` ke domain publik, `REVERB_PORT=443`, `REVERB_SCHEME=https`, lalu build ulang aset (`npm run build`) agar `VITE_REVERB_*` ikut berubah. Bila WebSocket tidak tersedia, dashboard dan aplikasi otomatis beralih ke polling 10 detik.

## 5. Berkas privat

Foto driver, sertifikat, dan lampiran laporan disimpan di disk `local` (`storage/app/private`) dan hanya bisa diambil lewat `GET /api/v1/media/{type}/{id}` yang memeriksa hak akses. Jangan menautkan folder ini ke `public/`. Sertakan `storage/app/private` dalam backup.

## 6. Redis (opsional)

Untuk beban tinggi (banyak driver mengirim lokasi), ubah:

```dotenv
CACHE_STORE=redis
QUEUE_CONNECTION=redis
REDIS_HOST=127.0.0.1
```

lalu ganti `queue:work database` menjadi `queue:work redis` di Supervisor. Tidak ada perubahan kode yang diperlukan.

## 7. Dokumentasi API

Dokumentasi Scribe statis ada di `public/docs` (bisa dibuka di `/docs/index.html`). Bila tidak ingin dipublikasikan, blokir path `/docs` di web server. Membuat ulang setelah endpoint berubah (butuh dependensi dev):

```bash
APP_LOCALE=en php artisan scribe:generate
```

## 8. Checklist setelah deploy

- `php artisan about` menampilkan driver cache/queue/broadcast yang benar.
- `supervisorctl status` menunjukkan tiga program RUNNING.
- Login dashboard admin, buka Peta Live: indikator "Realtime terhubung" hijau.
- `php artisan queue:failed` kosong.
- Log `storage/logs/laravel.log` tidak berisi error FCM berulang (atau berisi `[FCM log-only]` bila kredensial memang dikosongkan).
