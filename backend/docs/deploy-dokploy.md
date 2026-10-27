# Panduan Deploy Backend MeDrive ke Dokploy (Docker)

Panduan ini adalah versi yang lebih mudah dari dokumen dosen *"Laravel + Docker Compose for
Dokploy: Student Guide"*, **sudah disesuaikan dengan backend MeDrive**. Ikuti langkahnya
berurutan dari atas ke bawah. Kamu cukup menyalin isi file yang disediakan.

---

## Bagian 0: Pahami dulu gambaran besarnya

### Apa yang sebenarnya terjadi?

1. **Kamu** menambahkan beberapa file Docker ke folder `backend/`, mengujinya di laptop, lalu push ke GitHub.
2. **Kamu** mengirim isi file `.env` (berisi password dan kunci rahasia) ke dosen lewat pesan pribadi.
3. **Dosen** membuat project di Dokploy, menghubungkannya ke repo kamu, menempelkan `.env`, dan memasang domain.
4. **Dokploy** membangun image Docker, menjalankan container, dan membuka website kamu di domain itu.

Kamu **tidak perlu** punya akses ke Dokploy.

### Pembagian tugas

| Tugas | Kamu | Dosen |
|---|---|---|
| Membuat file Docker (Langkah 1–2) | ✅ | |
| Membuat isi `.env` dan mengirimnya secara pribadi (Langkah 3–4) | ✅ | |
| Menguji di laptop dan push ke GitHub (Langkah 5–6) | ✅ | |
| Membuat project Dokploy, menempel `.env`, memasang domain, menekan Deploy | | ✅ |
| Memperbaiki kode kalau deploy gagal | ✅ | |

### Apa bedanya dengan PDF dosen?

PDF dosen dibuat untuk proyek Laravel umum. MeDrive punya beberapa kebutuhan khusus, jadi ada
perbedaan berikut. **Ikuti panduan ini, bukan PDF, untuk poin-poin di bawah:**

| Poin | PDF dosen | Panduan ini (MeDrive) | Alasan |
|---|---|---|---|
| Versi PHP | `php:8.3-fpm-alpine` | **`php:8.4-fpm-alpine`** | MeDrive memakai Laravel 13. Paket Symfony di `composer.lock` mewajibkan PHP ≥ 8.4.1. Dengan PHP 8.3, `composer install` pasti gagal. |
| Letak file | Root repo | **Folder `backend/`** | Repo MeDrive berisi `backend/` (Laravel) dan `frontend/` (Flutter). |
| Compose path di Dokploy | `./docker-compose.yml` | **`./backend/docker-compose.yml`** | Harus disampaikan ke dosen. |
| Proses yang berjalan | PHP-FPM + Nginx | PHP-FPM + Nginx + **queue worker** + **scheduler** | Scheduler wajib: buffer lokasi driver diproses tiap 10 detik dan eskalasi dispatch tiap menit. Queue mengirim notifikasi FCM. |
| Cache, session, queue | `file`, `file`, `sync` | **`database`** | Sama dengan pengaturan yang dipakai saat MeDrive dikembangkan dan diuji. Tabelnya sudah ada di migration. |
| Bahasa | `APP_LOCALE=en` | **`APP_LOCALE=id`** | Pesan error API MeDrive berbahasa Indonesia. |
| `.gitattributes` | Harus dibuat | **Sudah ada** di `backend/` (`eol=lf` untuk semua file) | Tidak perlu dibuat lagi. |
| Data awal | Opsional | **Wajib seed** | Tanpa `MasterDataSeeder`, jenis laporan dan jenis ambulans kosong. Akun admin hanya ada di `DemoDataSeeder`. |
| Realtime (WebSocket Reverb) | Tidak dibahas | **Dimatikan dulu** (`BROADCAST_CONNECTION=log`); opsional dinyalakan di Bagian 9 | Reverb butuh domain kedua dari dosen. Tanpa Reverb, dashboard dan aplikasi tetap jalan dengan polling tiap 10 detik. |

---

## Bagian 1: Persiapan di laptop

1. **Pasang Docker Desktop** (Windows/macOS) atau Docker Engine (Linux), lalu jalankan.
   Pastikan perintah `docker --version` dan `docker compose version` di terminal menampilkan versi.
2. **Pasang Git**, lalu clone repo MeDrive (kalau belum ada di laptop).
3. Buka terminal, lalu **masuk ke folder `backend/`**. Semua perintah di panduan ini dijalankan dari folder `backend/`.
4. Pastikan file `.env` **tidak** ikut ke Git. `backend/.gitignore` sudah berisi `.env`, jadi jangan diubah.

---

## Langkah 1: Buat file-file Docker

Tambahkan **tujuh file baru** di dalam `backend/`, dengan struktur seperti ini:

```
backend/
├── app/ ...                   (kode yang sudah ada, tidak diubah)
├── Dockerfile                 BARU
├── docker-compose.yml         BARU (dipakai Dokploy)
├── docker-compose.local.yml   BARU (hanya untuk uji di laptop)
├── .dockerignore              BARU
├── .gitattributes             SUDAH ADA, jangan diubah
└── docker/                    FOLDER BARU
    ├── nginx.conf
    ├── supervisord.conf
    └── entrypoint.sh
```

### 1.1 `backend/.dockerignore`

Fungsinya: mencegah file rahasia dan file sampah ikut masuk image. Build juga jadi lebih cepat.

```
.git
.github
node_modules
vendor
.env
.env.*
!.env.example
composer.local.json
composer.local.lock
storage/logs/*
storage/framework/cache/data/*
storage/framework/sessions/*
storage/framework/views/*
bootstrap/cache/*.php
public/hot
tests
Dockerfile
docker-compose*.yml
```

### 1.2 `backend/Dockerfile`

Fungsinya: resep membangun satu container berisi PHP-FPM + Nginx. Perhatikan baris pertama: **PHP 8.4**.

```dockerfile
FROM php:8.4-fpm-alpine

# Web server, pengelola proses, su-exec (menjalankan perintah sebagai www-data), Node (build aset)
RUN apk add --no-cache nginx supervisor su-exec nodejs npm

# Ekstensi PHP yang dibutuhkan MeDrive (pcntl untuk Reverb dan queue worker)
COPY --from=ghcr.io/mlocati/php-extension-installer:latest /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions pdo_mysql bcmath gd zip intl exif pcntl opcache

# Setelan PHP produksi + batas upload
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
 && printf "upload_max_filesize=20M\npost_max_size=20M\n" > "$PHP_INI_DIR/conf.d/uploads.ini"

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www/html

# 1) Dependensi PHP (di-cache selama composer.json/lock tidak berubah)
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --no-progress --prefer-dist --no-scripts --no-autoloader

# 2) Kode aplikasi
COPY . .
RUN composer dump-autoload --optimize --no-dev --no-scripts

# 3) Aset dashboard admin (Vite)
RUN npm ci && npm run build && rm -rf node_modules

# 4) File konfigurasi dan skrip startup
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/supervisord.conf /etc/supervisord.conf
COPY docker/entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
```

### 1.3 `backend/docker/entrypoint.sh`

Fungsinya: dijalankan setiap kali container menyala. Skrip ini:

1. berhenti dengan pesan jelas kalau `APP_KEY` kosong;
2. memperbaiki izin folder;
3. membuat link storage;
4. menjalankan migration.

```sh
#!/bin/sh
set -e
cd /var/www/html

if [ -z "$APP_KEY" ]; then
  echo "ERROR: APP_KEY kosong. Buat kuncinya (Langkah 3) lalu isi di .env." >&2
  exit 1
fi

# storage/ adalah volume, jadi pastikan foldernya ada dan dimiliki www-data
mkdir -p storage/app/public storage/app/private storage/framework/cache/data \
  storage/framework/sessions storage/framework/views storage/logs bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
chmod -R ug+rwX storage bootstrap/cache

artisan() { su-exec www-data php artisan "$@"; }

artisan storage:link --force || true

if [ "${RUN_MIGRATIONS:-true}" = "true" ]; then
  artisan migrate --force
fi

exec "$@"
```

### 1.4 `backend/docker/supervisord.conf`

Fungsinya: menjaga **empat proses** tetap hidup dan mengirim log-nya ke tab Logs Dokploy:

- **php-fpm:** menjalankan kode PHP.
- **nginx:** web server.
- **queue:** mengirim notifikasi FCM dan job lain.
- **scheduler:** memproses lokasi driver tiap 10 detik dan eskalasi dispatch tiap menit.

```ini
[supervisord]
nodaemon=true
user=root
logfile=/dev/null
logfile_maxbytes=0
pidfile=/run/supervisord.pid

[program:php-fpm]
command=php-fpm -F
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

[program:nginx]
command=nginx -g "daemon off;"
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

[program:queue]
command=su-exec www-data php /var/www/html/artisan queue:work --sleep=3 --tries=3
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

[program:scheduler]
command=su-exec www-data php /var/www/html/artisan schedule:work
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
```

### 1.5 `backend/docker/nginx.conf`

Fungsinya: Nginx melayani folder `public/` dan meneruskan file PHP ke PHP-FPM di container yang sama.
Isinya sama persis dengan PDF.

```nginx
user www-data;
worker_processes auto;
error_log /dev/stderr warn;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    access_log /dev/stdout;
    sendfile on;
    keepalive_timeout 65;
    client_max_body_size 20M;
    gzip on;
    gzip_types text/css application/javascript application/json image/svg+xml;

    server {
        listen 80;
        server_name _;
        root /var/www/html/public;
        index index.php;

        location / {
            try_files $uri $uri/ /index.php?$query_string;
        }

        location ~ \.php$ {
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
            fastcgi_param DOCUMENT_ROOT $realpath_root;
        }

        location ~ /\.(?!well-known).* {
            deny all;
        }
    }
}
```

### 1.6 `backend/docker-compose.yml`

Fungsinya: mendefinisikan dua service, yaitu `app` (Laravel) dan `db` (MySQL 8). Isinya sama dengan PDF.

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    restart: unless-stopped
    env_file:
      - .env
    expose:
      - "80"
    volumes:
      - app_storage:/var/www/html/storage
    depends_on:
      db:
        condition: service_healthy

  db:
    image: mysql:8.0
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: ${DB_DATABASE}
      MYSQL_USER: ${DB_USERNAME}
      MYSQL_PASSWORD: ${DB_PASSWORD}
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql
    healthcheck:
      test: ["CMD-SHELL", "mysqladmin ping -h 127.0.0.1 -u root -p$$MYSQL_ROOT_PASSWORD --silent"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 30s

volumes:
  app_storage:
  db_data:
```

**Jangan** menambahkan `ports:`, `container_name:`, `networks:`, atau `labels:` Traefik. Semua itu
diurus Dokploy. Bila ditambahkan, deploy bisa bentrok dengan project mahasiswa lain.

### 1.7 `backend/docker-compose.local.yml`

Fungsinya: **hanya untuk uji di laptop**. File ini membuka port 8080 supaya website bisa dibuka di
browser. Dokploy tidak membaca file ini.

```yaml
services:
  app:
    ports:
      - "8080:80"
```

---

## Langkah 2: Satu perubahan kode (trust proxy)

Dokploy melayani website lewat HTTPS (Traefik), lalu meneruskannya ke container sebagai HTTP biasa.
Laravel harus "percaya" pada proxy itu. Kalau tidak, link yang dibuat jadi `http://`, CSS tidak muncul,
dan login dashboard admin bisa gagal.

Buka `backend/bootstrap/app.php`. Blok `->withMiddleware(function (Middleware $middleware): void {`
**sudah ada**, jadi cukup tambahkan **satu baris** di dalamnya, misalnya tepat di bawah
`$middleware->statefulApi();`:

```php
        $middleware->trustProxies(at: '*');
```

Jangan membuat blok `withMiddleware` kedua.

---

## Langkah 3: Buat tiga kunci rahasia

Jalankan perintah di bawah di terminal mana saja yang punya Docker. Perintah ini memakai image PHP 8.4,
jadi kamu tidak perlu memasang PHP.

**a. `APP_KEY`.** Salin seluruh hasilnya, termasuk awalan `base64:`.

```
docker run --rm php:8.4-cli php -r "echo 'base64:'.base64_encode(random_bytes(32)).PHP_EOL;"
```

**b. `DB_PASSWORD` dan `DB_ROOT_PASSWORD`.** Jalankan **dua kali**, karena kedua password harus berbeda.

```
docker run --rm php:8.4-cli php -r "echo bin2hex(random_bytes(16)).PHP_EOL;"
```

Pakai hasil heksadesimal ini apa adanya. Jangan memakai karakter seperti `$`, `#`, atau `"` di password
karena merusak pembacaan file `.env`.

Catat ketiga hasilnya. Kita pakai di langkah berikutnya.

---

## Langkah 4: Siapkan file `.env` untuk Dokploy

Buat file bernama **`.env.dokploy.txt`** di **luar** folder repo (misalnya di Desktop), supaya tidak
ikut ter-push. Salin template di bawah, lalu ganti setiap nilai yang bertanda `GANTI_`.

```
# ===== Aplikasi =====
APP_NAME=Medrive
APP_ENV=production
APP_DEBUG=false
APP_KEY=GANTI_hasil_langkah_3a
APP_URL=https://GANTI.domain-dari-dosen
APP_TIMEZONE=Asia/Jakarta
APP_LOCALE=id
APP_FALLBACK_LOCALE=en
APP_FAKER_LOCALE=id_ID

# ===== Log (muncul di tab Logs Dokploy) =====
LOG_CHANNEL=stderr
LOG_LEVEL=error

# ===== Database (DB_HOST wajib "db") =====
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=medrive_db
DB_USERNAME=medrive
DB_PASSWORD=GANTI_hasil_langkah_3b_pertama
DB_ROOT_PASSWORD=GANTI_hasil_langkah_3b_kedua

# ===== Session, cache, queue (tabelnya ada di migration) =====
SESSION_DRIVER=database
SESSION_LIFETIME=120
SESSION_SECURE_COOKIE=true
CACHE_STORE=database
QUEUE_CONNECTION=database
FILESYSTEM_DISK=local

# ===== Realtime: dimatikan dulu (lihat Bagian 9 untuk menyalakan Reverb) =====
BROADCAST_CONNECTION=log

# ===== Mail (log = tidak ada email terkirim) =====
MAIL_MAILER=log
MAIL_FROM_ADDRESS="noreply@medrive.test"
MAIL_FROM_NAME="Medrive"

# ===== Layanan peta (server publik, cukup untuk tugas kuliah) =====
OSRM_BASE_URL=https://router.project-osrm.org
NOMINATIM_BASE_URL=https://nominatim.openstreetmap.org
NOMINATIM_USER_AGENT="MedriveBackend/1.0 (+https://GANTI.domain-dari-dosen)"
NOMINATIM_COUNTRY_CODES=id
NOMINATIM_UPSTREAM_PER_SECOND=1
CORS_ALLOWED_ORIGINS=https://GANTI.domain-dari-dosen

# ===== Notifikasi FCM (kosong = mode log, aman) =====
FCM_PROJECT_ID=
FCM_CLIENT_EMAIL=
FCM_PRIVATE_KEY=

# ===== Startup container =====
RUN_MIGRATIONS=true
```

### Siapa mengisi apa?

| Variabel | Yang mengisi | Aturan |
|---|---|---|
| `APP_KEY` | Kamu | Hasil Langkah 3a, diawali `base64:` |
| `DB_PASSWORD`, `DB_ROOT_PASSWORD` | Kamu | Dua string heksadesimal **berbeda** dari Langkah 3b |
| `APP_URL`, `CORS_ALLOWED_ORIGINS`, `NOMINATIM_USER_AGENT` | Kamu, dikoreksi dosen | Domain lengkap dengan `https://`, tanpa garis miring di akhir. Kalau belum tahu domainnya, tanyakan ke dosen atau isi tebakan dulu; dosen bisa mengoreksinya di Dokploy. |
| `DB_HOST` | Tidak diubah | Harus tetap `db` (nama service di `docker-compose.yml`) |
| `APP_DEBUG` | Tidak diubah | Tetap `false`; nilai `true` akan menampilkan rahasia di halaman error |

**Jangan pernah** meng-commit file ini ke Git. Kirim ke dosen lewat pesan pribadi atau email.

---

## Langkah 5: Uji di laptop

Langkah ini meniru Dokploy di laptopmu. Kalau berhasil di sini, hampir pasti berhasil di Dokploy.
Semua perintah dijalankan dari folder `backend/`.

1. **Siapkan `.env` lokal.** Salin `.env.dokploy.txt` menjadi `backend/.env`. Khusus uji lokal, ubah tiga baris ini:
   - `APP_URL=http://localhost:8080`
   - `CORS_ALLOWED_ORIGINS=http://localhost:8080`
   - `SESSION_SECURE_COOKIE=false`

   File `.env` di laptop memang tidak akan ikut ter-push karena sudah ada di `.gitignore`.
2. **Bangun dan jalankan:**
   ```
   docker compose -f docker-compose.yml -f docker-compose.local.yml up --build
   ```
   Build pertama bisa makan waktu 5–10 menit.
3. **Tunggu** sampai log menampilkan migration selesai dan php-fpm/nginx berjalan.
4. **Isi data awal (sekali saja).** Buka **terminal kedua** di folder `backend/`, lalu jalankan:
   ```
   docker compose -f docker-compose.yml -f docker-compose.local.yml exec app su-exec www-data php artisan db:seed --force
   ```
   Perintah ini mengisi data master (jenis laporan, jenis ambulans) dan data demo (termasuk akun admin).
   **Jalankan hanya sekali.** Kalau dijalankan dua kali akan muncul error `Duplicate entry`, karena seeder memakai ID tetap.
5. **Cek hasilnya di browser:**
   - `http://localhost:8080/up` harus menampilkan halaman sehat.
   - `http://localhost:8080/admin/login` harus tampil dengan CSS. Masuk dengan akun demo `admin@medrive.test`, password `password`.
   - `http://localhost:8080/docs/index.html` adalah dokumentasi API.
6. **Hentikan** dengan `Ctrl+C`. Untuk menghapus database uji dan mulai dari nol, jalankan:
   ```
   docker compose -f docker-compose.yml -f docker-compose.local.yml down -v
   ```
7. **Kembalikan** `APP_URL`, `CORS_ALLOWED_ORIGINS`, dan `SESSION_SECURE_COOKIE=true` di file `.env.dokploy.txt` yang akan dikirim ke dosen.

---

## Langkah 6: Push ke GitHub

Dari root repo (folder `MeDrive/`):

```
git status
```

Pastikan **tidak ada** file `.env` di daftar. Lalu:

```
git add backend/Dockerfile backend/docker-compose.yml backend/docker-compose.local.yml backend/.dockerignore backend/docker backend/bootstrap/app.php
git commit -m "Tambah file deploy Docker untuk Dokploy"
git push origin <nama-branch>
```

Setelah itu, buka repo di GitHub dan periksa:

- [ ] `backend/docker/entrypoint.sh` ada di repo.
- [ ] **Tidak ada** file `.env` di repo.
- [ ] Repo bisa dibaca dosen: dibuat public, atau dosen diundang sebagai collaborator.

---

## Langkah 7: Kirim ke dosen (dalam satu pesan)

Contoh isi pesan:

> Selamat siang, Pak/Bu. Berikut data deploy backend saya:
>
> - **Repository:** https://github.com/…/MeDrive
> - **Branch:** `<nama-branch>`
> - **Compose path:** `./backend/docker-compose.yml` (backend ada di subfolder `backend/`)
> - **Nama / NIM:** …
> - **Nama aplikasi untuk domain:** medrive
> - **Service & port untuk domain:** service `app`, port `80`
> - **Perlu seed data:** ya, sekali saja setelah deploy pertama berhasil:
>   `su-exec www-data php artisan db:seed --force` (di terminal container `app`)
> - **Isi `.env`:** (saya kirim di pesan pribadi berikutnya / terlampir)
>
> Terima kasih.

Yang dikerjakan dosen di Dokploy (sekadar agar kamu paham):

1. Membuat project, lalu menambah service tipe **Compose** (bukan Stack).
2. Di **General**: memilih repo + branch, lalu mengisi Compose path `./backend/docker-compose.yml`.
3. Di **Environment**: menempelkan isi `.env` kamu dan mengoreksi `APP_URL`.
4. Di **Advanced**: menyalakan **Isolated Deployments**.
5. Di **Domains**: memasang domain ke service `app` port `80` dengan HTTPS (Let's Encrypt).
6. Menekan **Deploy**, lalu melihat log.
7. Menjalankan seed sekali di terminal container `app`.

---

## Langkah 8: Setelah deploy berhasil

1. Buka `https://domain-kamu/up`. Halaman ini harus tampil.
2. Buka `https://domain-kamu/admin/login`, masuk dengan `admin@medrive.test` / `password`.
   **Segera ganti password admin**, karena itu password data demo.
3. Aplikasi Flutter pelapor diarahkan ke server ini dengan:
   ```
   --dart-define=API_BASE_URL=https://domain-kamu
   ```
   Selama Reverb belum dinyalakan, aplikasi otomatis memakai polling tiap 10 detik.

---

## Bagian 9 (opsional): Menyalakan realtime Reverb

Lakukan hanya kalau dosen bersedia menambah **domain kedua** untuk WebSocket. Tanpa ini semua fitur
tetap jalan, hanya pembaruannya tiap 10 detik, bukan instan.

1. **Tambah proses Reverb.** Tambahkan blok ini di akhir `backend/docker/supervisord.conf`:
   ```ini
   [program:reverb]
   command=su-exec www-data php /var/www/html/artisan reverb:start --host=0.0.0.0 --port=8080
   autorestart=true
   stdout_logfile=/dev/stdout
   stdout_logfile_maxbytes=0
   stderr_logfile=/dev/stderr
   stderr_logfile_maxbytes=0
   ```
2. **Buka port 8080 di dalam Docker.** Di `backend/docker-compose.yml`, bagian `expose:` service `app` menjadi:
   ```yaml
       expose:
         - "80"
         - "8080"
   ```
3. **Ganti `BROADCAST_CONNECTION=log`** di `.env` dengan blok ini:
   ```
   BROADCAST_CONNECTION=reverb
   REVERB_APP_ID=medrive
   REVERB_APP_KEY=GANTI_hex_acak_langkah_3b
   REVERB_APP_SECRET=GANTI_hex_acak_langkah_3b_lagi
   REVERB_SERVER_HOST=0.0.0.0
   REVERB_SERVER_PORT=8080
   REVERB_HOST=GANTI.domain-websocket-dari-dosen
   REVERB_PORT=443
   REVERB_SCHEME=https
   ```
4. **Minta dosen** menambah domain kedua (misalnya `ws-medrive.…`) ke service `app` **port `8080`**, dengan HTTPS.
5. **Arahkan aplikasi Flutter** dengan:
   ```
   --dart-define=WS_URL=wss://domain-websocket:443 --dart-define=WS_KEY=<REVERB_APP_KEY>
   ```

Catatan: dashboard admin tetap memakai polling walau Reverb menyala. Kunci Reverb untuk browser
(`VITE_REVERB_*`) ditanam saat `npm run build`, sedangkan `.env` tidak ikut saat build image.
Ini tidak merusak apa pun; dashboard hanya diperbarui tiap 10 detik.

---

## Bagian 10: Kalau ada masalah

Lihat gejalanya di terminal laptop (saat uji lokal) atau minta dosen mengirim **baris error pertama**
dari tab Logs.

| Gejala | Kemungkinan penyebab | Solusi |
|---|---|---|
| Build gagal dengan pesan `requires php >=8.4.1` atau `Your requirements could not be resolved` | Dockerfile masih `php:8.3` | Ganti baris pertama menjadi `FROM php:8.4-fpm-alpine` |
| Log: `APP_KEY kosong` dan container terus restart | `APP_KEY` belum diisi di `.env` | Isi dengan hasil Langkah 3a, lengkap dengan `base64:` |
| `getaddrinfo for db failed` / `Connection refused` | `DB_HOST` bukan `db`, atau Isolated Deployments mati | Set `DB_HOST=db`; minta dosen menyalakan Isolated Deployments |
| `Access denied for user` setelah mengganti password DB | MySQL hanya membuat user saat volume pertama kali dibuat | Kembalikan password lama, atau dosen menghapus volume `db_data` (data hilang) lalu deploy ulang |
| `exec /entrypoint.sh: no such file or directory` | Line ending Windows (CRLF) di `entrypoint.sh` | Jalankan `git add --renormalize .`, commit, push |
| `502 Bad Gateway` | Port domain salah, atau PHP-FPM crash | Domain harus ke service `app` port `80`; baca log error PHP |
| Halaman tanpa CSS / peringatan *Mixed Content* | Trust proxy belum ditambahkan, atau `APP_URL` masih `http://` | Kerjakan Langkah 2 dan pakai `APP_URL=https://…` |
| Login dashboard admin kembali ke halaman login terus | Cookie session tidak cocok dengan domain | Pastikan `APP_URL` sama persis dengan domain yang dibuka, dan Langkah 2 sudah dikerjakan |
| `Vite manifest not found` | `npm run build` gagal | Lihat log build bagian npm |
| `Duplicate entry` saat seed | Seed dijalankan lebih dari sekali | Abaikan; data sudah ada. Untuk mulai bersih: `down -v` (lokal) atau hapus volume `db_data` (Dokploy) |
| Error 500 tanpa detail | `APP_DEBUG=false` menyembunyikan error | Baca tab Logs (`LOG_CHANNEL=stderr`). Jangan menyalakan `APP_DEBUG=true` di server publik |
| Jenis laporan kosong di aplikasi / dashboard | Seed belum dijalankan | Jalankan `db:seed --force` sekali |
| `Class not found` setelah deploy | `composer.lock` tidak ikut ter-commit atau usang | Commit `backend/composer.lock` terbaru, push |

---

## Checklist akhir

- [ ] Tujuh file baru ada di `backend/`, dan Dockerfile memakai **PHP 8.4**.
- [ ] `bootstrap/app.php` berisi `trustProxies(at: '*')`.
- [ ] Uji lokal berhasil: `/up`, `/admin/login` dengan CSS, login admin.
- [ ] `.env` **tidak** ada di GitHub.
- [ ] Pesan ke dosen sudah memuat repo, branch, **compose path `./backend/docker-compose.yml`**, dan permintaan seed sekali.
- [ ] Isi `.env.dokploy.txt` dikirim lewat pesan pribadi.
- [ ] Setelah online, password admin demo sudah diganti.
