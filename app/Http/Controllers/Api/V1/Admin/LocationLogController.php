<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Exceptions\ApiException;
use App\Http\Controllers\Api\ApiController;
use App\Models\DriverShift;
use App\Models\User;
use App\Services\LocationHistoryService;
use Carbon\CarbonImmutable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class LocationLogController extends ApiController
{
    public function __construct(private LocationHistoryService $history) {}

    /**
     * Rute untuk peta + ringkasan (jarak, kecepatan, baterai, jumlah GPS palsu).
     */
    public function route(Request $request): JsonResponse
    {
        Gate::authorize('viewAny', DriverShift::class);

        ['filters' => $filters, 'from' => $from, 'to' => $to] = $this->resolve($request);
        $driver = User::query()->drivers()->with('openShift')->findOrFail($filters['driver_id']);

        return $this->ok([
            ...$this->history->route($driver->id, $from, $to, $filters),
            'range' => ['from' => $from->toIso8601String(), 'to' => $to->toIso8601String()],
            'driver' => ['id' => $driver->id, 'name' => $driver->name],
            'is_live' => $driver->openShift !== null && $to->greaterThanOrEqualTo(now()->subMinutes(5)),
        ]);
    }

    /**
     * Tabel ping (paginated) pada rentang yang sama.
     */
    public function pings(Request $request): JsonResponse
    {
        Gate::authorize('viewAny', DriverShift::class);

        ['filters' => $filters, 'from' => $from, 'to' => $to] = $this->resolve($request);

        $pings = $this->history->query((int) $filters['driver_id'], $from, $to, $filters)
            ->orderByDesc('recorded_at')
            ->paginate(20, ['id', 'latitude', 'longitude', 'accuracy_m', 'speed_kmh', 'heading', 'battery_level', 'provider', 'is_mock_location', 'recorded_at', 'report_id']);

        return $this->ok(
            $pings->getCollection()->map(fn ($ping): array => [
                'id' => $ping->id,
                'latitude' => (float) $ping->latitude,
                'longitude' => (float) $ping->longitude,
                'accuracy_m' => $ping->accuracy_m !== null ? (float) $ping->accuracy_m : null,
                'speed_kmh' => $ping->speed_kmh !== null ? (float) $ping->speed_kmh : null,
                'heading' => $ping->heading,
                'battery_level' => $ping->battery_level,
                'provider' => $ping->provider,
                'is_mock_location' => $ping->is_mock_location,
                'report_id' => $ping->report_id,
                'recorded_at' => $ping->recorded_at->toIso8601String(),
            ])->values(),
            meta: [
                'pagination' => [
                    'current_page' => $pings->currentPage(),
                    'last_page' => $pings->lastPage(),
                    'per_page' => $pings->perPage(),
                    'total' => $pings->total(),
                ],
            ],
        );
    }

    /**
     * @return array{filters: array<string, mixed>, from: CarbonImmutable, to: CarbonImmutable}
     */
    private function resolve(Request $request): array
    {
        $resolved = $this->history->resolve($request);

        if (! isset($resolved['filters']['driver_id'])) {
            throw ApiException::badRequest('driver_required', 'Pilih driver terlebih dahulu.');
        }

        return $resolved;
    }
}
