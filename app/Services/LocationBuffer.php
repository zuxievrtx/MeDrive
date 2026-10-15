<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;

/**
 * Buffer ping lokasi di cache (database secara default, otomatis redis bila CACHE_STORE=redis)
 * sebelum di-flush massal ke driver_location_logs oleh scheduler tiap 10 detik.
 */
class LocationBuffer
{
    private const KEY = 'location:buffer';

    private const LOCK_SECONDS = 10;

    /**
     * @param  list<array<string, mixed>>  $entries
     */
    public function push(array $entries): void
    {
        if ($entries === []) {
            return;
        }

        Cache::lock(self::KEY.':lock', self::LOCK_SECONDS)->block(5, function () use ($entries): void {
            Cache::forever(self::KEY, [...Cache::get(self::KEY, []), ...$entries]);
        });
    }

    /**
     * Ambil seluruh isi buffer dan kosongkan secara atomik.
     *
     * @return list<array<string, mixed>>
     */
    public function drain(): array
    {
        return Cache::lock(self::KEY.':lock', self::LOCK_SECONDS)->block(5, function (): array {
            $entries = Cache::get(self::KEY, []);
            Cache::forget(self::KEY);

            return $entries;
        });
    }

    public function size(): int
    {
        return count(Cache::get(self::KEY, []));
    }
}
