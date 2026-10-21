<?php

namespace App\Services\Routing;

use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\Http;

/**
 * OSRM route service: route/v1/driving/{lng1},{lat1};{lng2},{lat2}?overview=simplified&geometries=geojson.
 */
class OsrmProvider implements RouteProvider
{
    public function route(float $fromLat, float $fromLng, float $toLat, float $toLng): array
    {
        $url = sprintf(
            '%s/route/v1/driving/%F,%F;%F,%F',
            rtrim((string) config('medrive.routing.osrm_base_url'), '/'),
            $fromLng, $fromLat, $toLng, $toLat,
        );

        try {
            $response = Http::acceptJson()
                ->timeout((int) config('medrive.routing.timeout_seconds'))
                ->get($url, ['overview' => 'simplified', 'geometries' => 'geojson']);
        } catch (ConnectionException $exception) {
            throw new RouteUnavailableException('OSRM tidak bisa dihubungi: '.$exception->getMessage(), previous: $exception);
        }

        $route = $response->json('routes.0');

        if ($response->failed() || $response->json('code') !== 'Ok' || ! is_array($route)) {
            throw new RouteUnavailableException('OSRM gagal: HTTP '.$response->status().' '.$response->json('code'));
        }

        return [
            'distance_km' => round(((float) $route['distance']) / 1000, 2),
            'duration_min' => round(((float) $route['duration']) / 60, 1),
            // GeoJSON memakai [lng, lat]; aplikasi menerima [lat, lng].
            'geometry' => array_map(
                fn (array $point): array => [round((float) $point[1], 6), round((float) $point[0], 6)],
                $route['geometry']['coordinates'] ?? [],
            ),
        ];
    }
}
