<?php

namespace App\Services;

use App\Exceptions\ApiException;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\Response;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\RateLimiter;

/**
 * Proxy Nominatim (reverse + search) dengan cache. Server publik Nominatim membatasi 1 permintaan per detik
 * dan mewajibkan User-Agent aplikasi; batas itu dijaga di sini untuk semua pengguna sekaligus.
 */
class GeocodeService
{
    /**
     * @return array{address: ?string, latitude: float, longitude: float}
     */
    public function reverse(float $latitude, float $longitude): array
    {
        $key = sprintf('geocode:reverse:%.5F,%.5F', $latitude, $longitude);

        $address = Cache::remember($key, (int) config('medrive.geocoding.reverse_cache_seconds'), function () use ($latitude, $longitude): string {
            $response = $this->request('reverse', [
                'lat' => $latitude,
                'lon' => $longitude,
                'zoom' => 18,
                'addressdetails' => 0,
            ]);

            // "Unable to geocode" (mis. titik di laut) disimpan sebagai string kosong agar tidak ditanya ulang.
            return (string) ($response->json('display_name') ?? '');
        });

        return ['address' => $address !== '' ? $address : null, 'latitude' => $latitude, 'longitude' => $longitude];
    }

    /**
     * @return list<array{label: string, latitude: float, longitude: float}>
     */
    public function search(string $query, int $limit): array
    {
        $normalized = mb_strtolower(preg_replace('/\s+/', ' ', trim($query)));
        $key = 'geocode:search:'.md5($normalized.'|'.$limit);

        return Cache::remember($key, (int) config('medrive.geocoding.search_cache_seconds'), function () use ($normalized, $limit): array {
            $response = $this->request('search', array_filter([
                'q' => $normalized,
                'limit' => $limit,
                'countrycodes' => config('medrive.geocoding.country_codes'),
            ]));

            return collect($response->json() ?? [])
                ->map(fn (array $place): array => [
                    'label' => (string) $place['display_name'],
                    'latitude' => (float) $place['lat'],
                    'longitude' => (float) $place['lon'],
                ])
                ->values()
                ->all();
        });
    }

    /**
     * @param  array<string, scalar>  $query
     */
    private function request(string $endpoint, array $query): Response
    {
        $allowed = RateLimiter::attempt('geocode:upstream', (int) config('medrive.geocoding.upstream_per_second'), fn (): bool => true, 1);

        if (! $allowed) {
            throw new ApiException('geocode_busy', 'Layanan alamat sedang sibuk. Coba lagi sebentar lagi.', 429);
        }

        try {
            $response = Http::withHeaders(['User-Agent' => (string) config('medrive.geocoding.user_agent')])
                ->acceptJson()
                ->timeout((int) config('medrive.geocoding.timeout_seconds'))
                ->get(rtrim((string) config('medrive.geocoding.nominatim_base_url'), '/').'/'.$endpoint, [
                    'format' => 'jsonv2',
                    'accept-language' => 'id',
                    ...$query,
                ]);
        } catch (ConnectionException) {
            throw $this->unavailable();
        }

        if ($response->failed()) {
            throw $this->unavailable();
        }

        return $response;
    }

    private function unavailable(): ApiException
    {
        return new ApiException('geocode_unavailable', 'Layanan alamat sedang tidak tersedia. Coba lagi sebentar lagi.', 502);
    }
}
