<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\DriverLocationLog;
use App\Models\DriverShift;
use App\Models\Report;
use App\Models\User;
use Carbon\CarbonImmutable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Validation\Validator;
use Illuminate\View\View;

/**
 * Riwayat rute dari driver_location_logs. Setiap query diawali driver_id + rentang recorded_at
 * agar memakai index idx_dlog_driver_time.
 */
class LocationLogController extends Controller
{
    private const MAP_POINT_LIMIT = 3000;

    private const ACCURACY_LIMIT_M = 50;

    public function index(Request $request): View
    {
        Gate::authorize('viewAny', DriverShift::class);

        [$filters, $from, $to] = $this->resolveFilters($request);
        $driver = isset($filters['driver_id']) ? User::query()->with('openShift')->find($filters['driver_id']) : null;

        $pings = $driver
            ? $this->baseQuery($driver->id, $from, $to, $filters)
                ->orderByDesc('recorded_at')
                ->paginate(20, ['id', 'latitude', 'longitude', 'accuracy_m', 'speed_kmh', 'heading', 'battery_level', 'provider', 'is_mock_location', 'recorded_at', 'report_id'])
                ->withQueryString()
            : null;

        $mockCount = $driver
            ? $this->baseQuery($driver->id, $from, $to, $filters)->where('is_mock_location', true)->count()
            : 0;

        return view('admin.location-logs.index', [
            'drivers' => User::query()->where('role', UserRole::Driver)->orderBy('name')->get(['id', 'name']),
            'driver' => $driver,
            'report' => isset($filters['report_id']) ? Report::query()->find($filters['report_id'], ['id', 'code']) : null,
            'filters' => $filters,
            'from' => $from,
            'to' => $to,
            'pings' => $pings,
            'mockCount' => $mockCount,
            'isLive' => $driver?->openShift !== null && $to->greaterThanOrEqualTo(now()->subMinutes(5)),
            'retentionDays' => config('medrive.location_log_retention_days'),
        ]);
    }

    /**
     * Titik rute untuk peta + ringkasan. Jarak dihitung haversine di PHP sambil men-stream baris (lazy),
     * titik untuk peta diambil sampel agar tetap ringan.
     */
    public function data(Request $request): JsonResponse
    {
        Gate::authorize('viewAny', DriverShift::class);

        [$filters, $from, $to] = $this->resolveFilters($request);
        abort_unless(isset($filters['driver_id']), 422, 'Pilih driver terlebih dahulu.');

        $query = $this->baseQuery($filters['driver_id'], $from, $to, $filters);

        $stats = (clone $query)
            ->selectRaw('COUNT(*) as total, MAX(speed_kmh) as max_speed, AVG(speed_kmh) as avg_speed, SUM(CASE WHEN is_mock_location = 1 THEN 1 ELSE 0 END) as mock_total')
            ->toBase()
            ->first();

        $total = (int) $stats->total;
        $step = max(1, (int) ceil($total / self::MAP_POINT_LIMIT));

        $points = [];
        $distanceKm = 0.0;
        $previous = null;
        $lastBattery = null;
        $index = 0;

        foreach ((clone $query)->orderBy('recorded_at')->select(['latitude', 'longitude', 'speed_kmh', 'heading', 'battery_level', 'accuracy_m', 'is_mock_location', 'recorded_at'])->toBase()->lazy(2000) as $row) {
            $lat = (float) $row->latitude;
            $lng = (float) $row->longitude;

            if ($previous) {
                $distanceKm += $this->haversineKm($previous[0], $previous[1], $lat, $lng);
            }

            $previous = [$lat, $lng];
            $lastBattery = $row->battery_level ?? $lastBattery;
            $isLast = $index === $total - 1;

            if ($index % $step === 0 || $isLast || $row->is_mock_location) {
                $points[] = [
                    'lat' => $lat,
                    'lng' => $lng,
                    'speed_kmh' => $row->speed_kmh !== null ? (float) $row->speed_kmh : null,
                    'heading' => $row->heading !== null ? (int) $row->heading : null,
                    'battery_level' => $row->battery_level !== null ? (int) $row->battery_level : null,
                    'accuracy_m' => $row->accuracy_m !== null ? (float) $row->accuracy_m : null,
                    'mock' => (bool) $row->is_mock_location,
                    'recorded_at' => CarbonImmutable::parse($row->recorded_at)->toIso8601String(),
                ];
            }

            $index++;
        }

        return response()->json([
            'summary' => [
                'points' => $total,
                'distance_km' => round($distanceKm, 2),
                'max_speed_kmh' => $stats->max_speed !== null ? round((float) $stats->max_speed, 1) : null,
                'avg_speed_kmh' => $stats->avg_speed !== null ? round((float) $stats->avg_speed, 1) : null,
                'last_battery' => $lastBattery !== null ? (int) $lastBattery : null,
                'mock_points' => (int) $stats->mock_total,
                'sampled' => $step > 1,
            ],
            'points' => $points,
        ]);
    }

    /**
     * @return array{0: array<string, mixed>, 1: CarbonImmutable, 2: CarbonImmutable}
     */
    private function resolveFilters(Request $request): array
    {
        $retention = (int) config('medrive.location_log_retention_days');

        $validator = validator($request->query(), [
            'driver_id' => ['nullable', 'integer'],
            'report_id' => ['nullable', 'integer'],
            'from' => ['nullable', 'date'],
            'to' => ['nullable', 'date'],
            'accurate_only' => ['nullable', 'boolean'],
        ], attributes: ['from' => 'waktu mulai', 'to' => 'waktu selesai']);

        $validator->after(function (Validator $validator) use ($request, $retention): void {
            if ($validator->errors()->isNotEmpty() || ! $request->filled('from') || ! $request->filled('to')) {
                return;
            }

            $from = CarbonImmutable::parse($request->query('from'));
            $to = CarbonImmutable::parse($request->query('to'));

            if ($to->lessThan($from)) {
                $validator->errors()->add('to', 'Waktu selesai harus setelah waktu mulai.');
            } elseif ($from->diffInDays($to) > $retention) {
                $validator->errors()->add('from', "Rentang maksimal {$retention} hari sesuai masa simpan log lokasi.");
            }
        });

        $filters = $validator->validate();
        $filters = array_filter($filters, fn ($value) => $value !== null && $value !== '');

        // Laporan tanpa rentang waktu: pakai jendela waktu laporan tersebut.
        if (isset($filters['report_id']) && ! isset($filters['from'])) {
            $report = Report::query()->find($filters['report_id']);
            if ($report) {
                $filters['from'] = ($report->taken_at ?? $report->created_at)->toDateTimeString();
                $filters['to'] = ($report->completed_at ?? now())->toDateTimeString();
            }
        }

        $to = isset($filters['to']) ? CarbonImmutable::parse($filters['to']) : CarbonImmutable::now();
        $from = isset($filters['from']) ? CarbonImmutable::parse($filters['from']) : $to->subHour();

        $oldestAllowed = CarbonImmutable::now()->subDays($retention);
        if ($from->lessThan($oldestAllowed) && ! isset($filters['report_id'])) {
            $from = $oldestAllowed;
        }

        return [$filters, $from, $to];
    }

    /**
     * @param  array<string, mixed>  $filters
     * @return Builder<DriverLocationLog>
     */
    private function baseQuery(int $driverId, CarbonImmutable $from, CarbonImmutable $to, array $filters): Builder
    {
        return DriverLocationLog::query()
            ->where('driver_id', $driverId)
            ->whereBetween('recorded_at', [$from, $to])
            ->when($filters['report_id'] ?? null, fn (Builder $query, int $reportId) => $query->where('report_id', $reportId))
            ->when($filters['accurate_only'] ?? false, fn (Builder $query) => $query->where(fn (Builder $query) => $query
                ->whereNull('accuracy_m')
                ->orWhere('accuracy_m', '<=', self::ACCURACY_LIMIT_M)));
    }

    private function haversineKm(float $lat1, float $lng1, float $lat2, float $lng2): float
    {
        $earthRadiusKm = 6371.0;
        $dLat = deg2rad($lat2 - $lat1);
        $dLng = deg2rad($lng2 - $lng1);
        $a = sin($dLat / 2) ** 2 + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($dLng / 2) ** 2;

        return 2 * $earthRadiusKm * asin(min(1.0, sqrt($a)));
    }
}
