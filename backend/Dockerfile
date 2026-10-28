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