<?php

namespace App\Services\Routing;

use App\Enums\ReportStatus;
use App\Exceptions\ApiException;
use App\Models\Report;
use App\Services\LocationService;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;

/**
 * Rute + ETA ambulans → tujuan laporan dengan cache dan pembatasan panggilan upstream.
 *
 * Lapisan cache:
 * - per koordinat (dibulatkan 4 desimal ≈ 11 m, beserta arah) selama cache_seconds;
 * - per laporan: maksimal satu panggilan upstream dalam upstream_interval_seconds, selebihnya
 *   memakai rute terakhir laporan itu. Rute terakhir juga jadi cadangan stale saat OSRM gagal.
 */
class RouteService
{
    public function __construct(private RouteProvider $provider, private LocationService $locations) {}

    /**
     * @return array<string, mixed>
     */
    public function forReport(Report $report): array
    {
        if (! in_array($report->status, ReportStatus::active(), true) || $report->driver_id === null) {
            throw ApiException::conflict('route_unavailable_status', 'Rute hanya tersedia saat laporan sedang ditangani driver.');
        }

        $position = $this->locations->latestForDriver($report->driver_id);

        if ($position === null) {
            throw ApiException::conflict('driver_location_unavailable', 'Posisi ambulans belum tersedia. Coba lagi beberapa detik lagi.');
        }

        [$target, $toLat, $toLng] = $this->target($report);

        return $this->resolve($report->id, (float) $position['lat'], (float) $position['lng'], $toLat, $toLng) + [
            'target' => $target,
            'from' => ['latitude' => (float) $position['lat'], 'longitude' => (float) $position['lng'], 'updated_at' => $position['updated_at']],
            'to' => ['latitude' => $toLat, 'longitude' => $toLng],
        ];
    }

    /**
     * Tujuan rute: titik jemput, atau tujuan antar saat status mengantar pasien dan koordinat tujuan ada.
     *
     * @return array{0: string, 1: float, 2: float}
     */
    private function target(Report $report): array
    {
        if ($report->status === ReportStatus::MengantarPasien && $report->destination_lat !== null && $report->destination_lng !== null) {
            return ['destination', (float) $report->destination_lat, (float) $report->destination_lng];
        }

        return ['pickup', (float) $report->latitude, (float) $report->longitude];
    }

    /**
     * @return array{distance_km: float, duration_min: float, geometry: list<array{0: float, 1: float}>, stale: bool, computed_at: string}
     */
    private function resolve(int $reportId, float $fromLat, float $fromLng, float $toLat, float $toLng): array
    {
        $key = sprintf('route:%.4F,%.4F>%.4F,%.4F', $fromLat, $fromLng, $toLat, $toLng);
        $lastKey = "route:last:{$reportId}";

        if ($cached = Cache::get($key)) {
            return $cached + ['stale' => false];
        }

        $last = Cache::get($lastKey);
        $mayCallUpstream = Cache::add("route:throttle:{$reportId}", true, (int) config('medrive.routing.upstream_interval_seconds'));

        if (! $mayCallUpstream) {
            return $last ? $last + ['stale' => false] : throw $this->unavailable();
        }

        try {
            $route = $this->provider->route($fromLat, $fromLng, $toLat, $toLng) + ['computed_at' => now()->toIso8601String()];
        } catch (RouteUnavailableException $exception) {
            Log::warning('Rute gagal dihitung', ['report_id' => $reportId, 'error' => $exception->getMessage()]);

            if ($last) {
                return $last + ['stale' => true];
            }

            throw $this->unavailable();
        }

        Cache::put($key, $route, (int) config('medrive.routing.cache_seconds'));
        Cache::put($lastKey, $route, (int) config('medrive.routing.stale_cache_seconds'));

        return $route + ['stale' => false];
    }

    private function unavailable(): ApiException
    {
        return new ApiException('route_unavailable', 'Rute belum bisa dihitung saat ini. Coba lagi sebentar lagi.', 502);
    }
}
