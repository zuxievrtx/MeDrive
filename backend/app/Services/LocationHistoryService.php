<?php

namespace App\Services;

use App\Models\DriverLocationLog;
use App\Models\Report;
use App\Support\Geo;
use Carbon\CarbonImmutable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Validation\Validator;

/**
 * Riwayat rute dari driver_location_logs. Setiap query diawali driver_id + rentang recorded_at
 * agar memakai index idx_dlog_driver_time. Tidak dipakai untuk tampilan real-time.
 */
class LocationHistoryService
{
    private const MAP_POINT_LIMIT = 3000;

    private const ACCURACY_LIMIT_M = 50;

    /**
     * @return array{filters: array<string, mixed>, from: CarbonImmutable, to: CarbonImmutable}
     */
    public function resolve(Request $request): array
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

        $filters = array_filter($validator->validate(), fn ($value) => $value !== null && $value !== '');

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

        return ['filters' => $filters, 'from' => $from, 'to' => $to];
    }

    /**
     * @param  array<string, mixed>  $filters
     * @return Builder<DriverLocationLog>
     */
    public function query(int $driverId, CarbonImmutable $from, CarbonImmutable $to, array $filters): Builder
    {
        return DriverLocationLog::query()
            ->where('driver_id', $driverId)
            ->whereBetween('recorded_at', [$from, $to])
            ->when($filters['report_id'] ?? null, fn (Builder $query, int $reportId) => $query->where('report_id', $reportId))
            ->when($filters['accurate_only'] ?? false, fn (Builder $query) => $query->where(fn (Builder $query) => $query
                ->whereNull('accuracy_m')
                ->orWhere('accuracy_m', '<=', self::ACCURACY_LIMIT_M)));
    }

    /**
     * Titik rute untuk peta + ringkasan. Jarak dihitung haversine sambil men-stream baris (lazy);
     * titik peta disampel agar respons tetap ringan.
     *
     * @param  array<string, mixed>  $filters
     * @return array{summary: array<string, mixed>, points: list<array<string, mixed>>}
     */
    public function route(int $driverId, CarbonImmutable $from, CarbonImmutable $to, array $filters): array
    {
        $query = $this->query($driverId, $from, $to, $filters);

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

        $rows = (clone $query)
            ->orderBy('recorded_at')
            ->select(['latitude', 'longitude', 'speed_kmh', 'heading', 'battery_level', 'accuracy_m', 'is_mock_location', 'recorded_at'])
            ->toBase()
            ->lazy(2000);

        foreach ($rows as $row) {
            $lat = (float) $row->latitude;
            $lng = (float) $row->longitude;

            if ($previous) {
                $distanceKm += Geo::distanceKm($previous[0], $previous[1], $lat, $lng);
            }

            $previous = [$lat, $lng];
            $lastBattery = $row->battery_level ?? $lastBattery;

            if ($index % $step === 0 || $index === $total - 1 || $row->is_mock_location) {
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

        return [
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
        ];
    }
}
