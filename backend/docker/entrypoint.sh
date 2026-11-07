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

# Fix Nginx client body temporary directory permissions
mkdir -p /var/lib/nginx/tmp/client_body

chmod 755 /var/lib/nginx
chmod 711 /var/lib/nginx/tmp

chown www-data:www-data /var/lib/nginx/tmp/client_body
chmod 700 /var/lib/nginx/tmp/client_body

artisan() { su-exec www-data php artisan "$@"; }

artisan storage:link --force || true

if [ "${RUN_MIGRATIONS:-true}" = "true" ]; then
  artisan migrate --force
fi

exec "$@"
