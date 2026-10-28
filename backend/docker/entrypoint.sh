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