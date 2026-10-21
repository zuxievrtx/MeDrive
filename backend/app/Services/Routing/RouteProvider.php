<?php

namespace App\Services\Routing;

/**
 * Penyedia rute jalan. Endpoint hanya bergantung pada kontrak ini, jadi OSRM bisa diganti
 * (mis. Google Directions) cukup dengan binding baru di AppServiceProvider.
 */
interface RouteProvider
{
    /**
     * @return array{distance_km: float, duration_min: float, geometry: list<array{0: float, 1: float}>}
     *
     * @throws RouteUnavailableException
     */
    public function route(float $fromLat, float $fromLng, float $toLat, float $toLng): array;
}
