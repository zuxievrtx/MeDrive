<?php

namespace App\Services;

use App\Enums\DispatchResponse;
use App\Enums\ReportStatus;
use App\Models\Clinic;
use App\Models\Institution;
use App\Models\Report;
use App\Models\ReportDispatch;
use App\Models\ReportType;
use App\Models\User;
use App\Support\Delta;
use App\Support\Sql;
use Carbon\CarbonImmutable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Cache;
use InvalidArgumentException;

/**
 * Statistik laporan. Semua agregasi dilakukan di database (GROUP BY); PHP hanya menata hasil ke bucket.
 */
class StatisticsService
{
    public const RANGES = [
        'today' => 'Hari ini',
        '7d' => '7 hari',
        '30d' => '30 hari',
        'this_month' => 'Bulan ini',
        'this_year' => 'Tahun ini',
        'year' => 'Pilih tahun',
        'custom' => 'Rentang kustom',
    ];

    private CarbonImmutable $from;

    private CarbonImmutable $to;

    private CarbonImmutable $previousFrom;

    private CarbonImmutable $previousTo;

    private string $granularity;

    private string $label;

    /**
     * @param  array{range?: string, year?: int|string, from?: string, to?: string}  $params
     */
    public function forRange(array $params): static
    {
        $now = CarbonImmutable::now();
        $range = $params['range'] ?? '7d';

        [$this->from, $this->to, $this->granularity, $this->label] = match ($range) {
            'today' => [$now->startOfDay(), $now, 'hour', 'Hari ini'],
            '7d' => [$now->subDays(6)->startOfDay(), $now, 'day', '7 hari terakhir'],
            '30d' => [$now->subDays(29)->startOfDay(), $now, 'day', '30 hari terakhir'],
            'this_month' => [$now->startOfMonth(), $now, 'day', 'Bulan '.$now->translatedFormat('F Y')],
            'this_year' => [$now->startOfYear(), $now, 'month', 'Tahun '.$now->year],
            'year' => $this->yearRange((int) ($params['year'] ?? $now->year)),
            'custom' => $this->customRange($params['from'] ?? null, $params['to'] ?? null),
            default => throw new InvalidArgumentException('Rentang tidak dikenal.'),
        };

        [$this->previousFrom, $this->previousTo] = match ($range) {
            'this_month' => [$this->from->subMonthNoOverflow(), $this->to->subMonthNoOverflow()],
            'this_year', 'year' => [$this->from->subYear(), $this->to->subYear()],
            default => [$this->from->subSeconds($this->from->diffInSeconds($this->to) + 1), $this->from->subSecond()],
        };

        return $this;
    }

    /**
     * @return array<string, mixed>
     */
    public function payload(): array
    {
        $cacheKey = 'statistics:'.md5(implode('|', [$this->from, $this->to, $this->granularity]));

        // Rentang yang berakhir "sekarang" di-cache singkat agar angka tetap segar.
        $ttl = $this->to->greaterThan(now()->subMinute()) ? 60 : 300;

        return Cache::remember($cacheKey, $ttl, fn (): array => $this->build());
    }

    /**
     * @return array<string, mixed>
     */
    public function build(): array
    {
        $buckets = $this->buckets($this->from);
        $previousBuckets = $this->buckets($this->previousFrom, count($buckets));
        $types = ReportType::query()->orderBy('sort_order')->get(['id', 'name', 'color']);

        $current = $this->countPerBucket($this->from, $this->to);
        $previous = $this->countPerBucket($this->previousFrom, $this->previousTo);

        return [
            'range' => [
                'label' => $this->label,
                'from' => $this->from->toIso8601String(),
                'to' => $this->to->toIso8601String(),
                'previous_from' => $this->previousFrom->toIso8601String(),
                'previous_to' => $this->previousTo->toIso8601String(),
                'granularity' => $this->granularity,
            ],
            'labels' => array_values($buckets),
            'summary' => $this->summary(),
            'series' => [
                'current' => array_map(fn (string $key): int => (int) ($current[$key] ?? 0), array_keys($buckets)),
                'previous' => array_map(fn (string $key): int => (int) ($previous[$key] ?? 0), array_keys($previousBuckets)),
            ],
            'by_type' => $this->byType($types),
            'by_type_series' => $this->byTypeSeries($types, $buckets),
            'response_times' => $this->responseTimes($buckets),
            'top_drivers' => $this->topDrivers(),
            'by_clinic' => $this->byClinic(),
            'by_institution' => $this->byInstitution(),
            'by_hour' => $this->byHour(),
            'by_status' => $this->byStatus(),
        ];
    }

    /**
     * Bucket waktu => label tampilan, berurutan dari awal rentang.
     *
     * @return array<string, string>
     */
    public function buckets(CarbonImmutable $start, ?int $count = null): array
    {
        $buckets = [];
        $cursor = match ($this->granularity) {
            'hour' => $start->startOfHour(),
            'day' => $start->startOfDay(),
            'month' => $start->startOfMonth(),
        };

        while ($count === null ? $cursor->lessThanOrEqualTo($this->to) : count($buckets) < $count) {
            [$key, $label] = match ($this->granularity) {
                'hour' => [$cursor->format('Y-m-d H:00'), $cursor->format('H:00')],
                'day' => [$cursor->format('Y-m-d'), $cursor->translatedFormat('j M')],
                'month' => [$cursor->format('Y-m'), $cursor->translatedFormat('M Y')],
            };
            $buckets[$key] = $label;
            $cursor = match ($this->granularity) {
                'hour' => $cursor->addHour(),
                'day' => $cursor->addDay(),
                'month' => $cursor->addMonthNoOverflow(),
            };
        }

        return $buckets;
    }

    /**
     * @return array{0: CarbonImmutable, 1: CarbonImmutable, 2: string, 3: string}
     */
    private function yearRange(int $year): array
    {
        $start = CarbonImmutable::create($year)->startOfYear();
        $end = $year === now()->year ? CarbonImmutable::now() : $start->endOfYear();

        return [$start, $end, 'month', "Tahun {$year}"];
    }

    /**
     * @return array{0: CarbonImmutable, 1: CarbonImmutable, 2: string, 3: string}
     */
    private function customRange(?string $from, ?string $to): array
    {
        if (! $from || ! $to) {
            throw new InvalidArgumentException('Rentang kustom membutuhkan tanggal mulai dan selesai.');
        }

        $start = CarbonImmutable::parse($from)->startOfDay();
        $end = CarbonImmutable::parse($to)->endOfDay();
        $days = $start->diffInDays($end);

        $granularity = match (true) {
            $days <= 2 => 'hour',
            $days <= 92 => 'day',
            default => 'month',
        };

        return [$start, $end, $granularity, $start->translatedFormat('j M Y').' sampai '.$end->translatedFormat('j M Y')];
    }

    /**
     * @return Builder<Report>
     */
    private function inRange(?CarbonImmutable $from = null, ?CarbonImmutable $to = null): Builder
    {
        return Report::query()->whereBetween('reports.created_at', [$from ?? $this->from, $to ?? $this->to]);
    }

    /**
     * @return array<string, int>
     */
    private function countPerBucket(CarbonImmutable $from, CarbonImmutable $to): array
    {
        $bucket = Sql::bucket('created_at', $this->granularity);

        return $this->inRange($from, $to)
            ->selectRaw("{$bucket} as bucket, COUNT(*) as total")
            ->groupBy('bucket')
            ->pluck('total', 'bucket')
            ->all();
    }

    /**
     * @return array<string, array{value: int|float, previous: int|float, delta: float|null}>
     */
    private function summary(): array
    {
        $aggregate = function (CarbonImmutable $from, CarbonImmutable $to): object {
            $duration = Sql::secondsBetween('created_at', 'completed_at');
            $response = Sql::secondsBetween('created_at', 'taken_at');

            return $this->inRange($from, $to)
                ->selectRaw('COUNT(*) as total')
                ->selectRaw('SUM(CASE WHEN status = ? THEN 1 ELSE 0 END) as completed', [ReportStatus::Selesai->value])
                ->selectRaw('SUM(CASE WHEN status = ? THEN 1 ELSE 0 END) as cancelled', [ReportStatus::Dibatalkan->value])
                ->selectRaw("AVG(CASE WHEN completed_at IS NOT NULL THEN {$duration} END) as avg_duration")
                ->selectRaw("AVG(CASE WHEN taken_at IS NOT NULL THEN {$response} END) as avg_response")
                ->toBase()
                ->first();
        };

        $now = $aggregate($this->from, $this->to);
        $before = $aggregate($this->previousFrom, $this->previousTo);
        $minutes = fn ($seconds): float => $seconds === null ? 0.0 : round((float) $seconds / 60, 1);

        return [
            'total' => Delta::compare((int) $now->total, (int) $before->total),
            'completed' => Delta::compare((int) $now->completed, (int) $before->completed),
            'cancelled' => Delta::compare((int) $now->cancelled, (int) $before->cancelled),
            'avg_duration_minutes' => Delta::compare($minutes($now->avg_duration), $minutes($before->avg_duration)),
            'avg_response_minutes' => Delta::compare($minutes($now->avg_response), $minutes($before->avg_response)),
        ];
    }

    /**
     * @param  Collection<int, ReportType>  $types
     * @return list<array{id: int, name: string, color: string, total: int}>
     */
    private function byType(Collection $types): array
    {
        $counts = $this->inRange()
            ->selectRaw('report_type_id, COUNT(*) as total')
            ->groupBy('report_type_id')
            ->pluck('total', 'report_type_id');

        return $types->map(fn (ReportType $type): array => [
            'id' => $type->id,
            'name' => $type->name,
            'color' => $type->color ?? '#78716c',
            'total' => (int) ($counts[$type->id] ?? 0),
        ])->values()->all();
    }

    /**
     * @param  Collection<int, ReportType>  $types
     * @param  array<string, string>  $buckets
     * @return list<array{name: string, color: string, data: list<int>}>
     */
    private function byTypeSeries(Collection $types, array $buckets): array
    {
        $bucket = Sql::bucket('created_at', $this->granularity);

        $rows = $this->inRange()
            ->selectRaw("{$bucket} as bucket, report_type_id, COUNT(*) as total")
            ->groupBy('bucket', 'report_type_id')
            ->toBase()
            ->get()
            ->groupBy('report_type_id');

        return $types->map(function (ReportType $type) use ($rows, $buckets): array {
            $totals = ($rows[$type->id] ?? collect())->pluck('total', 'bucket');

            return [
                'name' => $type->name,
                'color' => $type->color ?? '#78716c',
                'data' => array_map(fn (string $key): int => (int) ($totals[$key] ?? 0), array_keys($buckets)),
            ];
        })->values()->all();
    }

    /**
     * Rata-rata (taken_at - created_at) dan (arrived_at - taken_at) dalam menit per bucket.
     *
     * @param  array<string, string>  $buckets
     * @return array{taken: list<float|null>, arrived: list<float|null>}
     */
    private function responseTimes(array $buckets): array
    {
        $bucket = Sql::bucket('created_at', $this->granularity);
        $taken = Sql::secondsBetween('created_at', 'taken_at');
        $arrived = Sql::secondsBetween('taken_at', 'arrived_at');

        $rows = $this->inRange()
            ->whereNotNull('taken_at')
            ->selectRaw("{$bucket} as bucket, AVG({$taken}) as avg_taken, AVG(CASE WHEN arrived_at IS NOT NULL THEN {$arrived} END) as avg_arrived")
            ->groupBy('bucket')
            ->toBase()
            ->get()
            ->keyBy('bucket');

        $toMinutes = fn ($seconds): ?float => $seconds === null ? null : round((float) $seconds / 60, 1);

        return [
            'taken' => array_map(fn (string $key): ?float => $toMinutes($rows[$key]->avg_taken ?? null), array_keys($buckets)),
            'arrived' => array_map(fn (string $key): ?float => $toMinutes($rows[$key]->avg_arrived ?? null), array_keys($buckets)),
        ];
    }

    /**
     * 10 driver dengan laporan terbanyak + rasio menang broadcast (diambil vs kalah cepat/diabaikan).
     *
     * @return list<array{driver_id: int, name: string, reports: int, won: int, lost: int, win_ratio: float|null}>
     */
    private function topDrivers(): array
    {
        $counts = $this->inRange()
            ->whereNotNull('driver_id')
            ->selectRaw('driver_id, COUNT(*) as total')
            ->groupBy('driver_id')
            ->orderByDesc('total')
            ->limit(10)
            ->pluck('total', 'driver_id');

        if ($counts->isEmpty()) {
            return [];
        }

        $names = User::query()->whereIn('id', $counts->keys())->pluck('name', 'id');

        $dispatches = ReportDispatch::query()
            ->whereIn('driver_id', $counts->keys())
            ->whereBetween('sent_at', [$this->from, $this->to])
            ->selectRaw('driver_id')
            ->selectRaw('SUM(CASE WHEN response = ? THEN 1 ELSE 0 END) as won', [DispatchResponse::Diambil->value])
            ->selectRaw('SUM(CASE WHEN response IN (?, ?) THEN 1 ELSE 0 END) as lost', [DispatchResponse::KalahCepat->value, DispatchResponse::Diabaikan->value])
            ->groupBy('driver_id')
            ->toBase()
            ->get()
            ->keyBy('driver_id');

        return $counts->map(function ($total, $driverId) use ($names, $dispatches): array {
            $won = (int) ($dispatches[$driverId]->won ?? 0);
            $lost = (int) ($dispatches[$driverId]->lost ?? 0);

            return [
                'driver_id' => (int) $driverId,
                'name' => $names[$driverId] ?? 'Driver #'.$driverId,
                'reports' => (int) $total,
                'won' => $won,
                'lost' => $lost,
                'win_ratio' => ($won + $lost) > 0 ? round($won / ($won + $lost) * 100, 1) : null,
            ];
        })->values()->all();
    }

    /**
     * @return list<array{name: string, total: int}>
     */
    private function byClinic(): array
    {
        $counts = $this->inRange()
            ->join('ambulances', 'ambulances.id', '=', 'reports.ambulance_id')
            ->selectRaw('ambulances.clinic_id, COUNT(*) as total')
            ->groupBy('ambulances.clinic_id')
            ->orderByDesc('total')
            ->pluck('total', 'clinic_id');

        $names = Clinic::query()->whereIn('id', $counts->keys())->pluck('name', 'id');

        return $counts->map(fn ($total, $id): array => ['name' => $names[$id] ?? '-', 'total' => (int) $total])->values()->all();
    }

    /**
     * @return list<array{name: string, total: int}>
     */
    private function byInstitution(): array
    {
        $counts = $this->inRange()
            ->join('ambulances', 'ambulances.id', '=', 'reports.ambulance_id')
            ->join('clinics', 'clinics.id', '=', 'ambulances.clinic_id')
            ->selectRaw('clinics.institution_id, COUNT(*) as total')
            ->groupBy('clinics.institution_id')
            ->orderByDesc('total')
            ->pluck('total', 'institution_id');

        $names = Institution::query()->whereIn('id', $counts->keys())->pluck('name', 'id');

        return $counts->map(fn ($total, $id): array => ['name' => $names[$id] ?? '-', 'total' => (int) $total])->values()->all();
    }

    /**
     * @return list<int>
     */
    private function byHour(): array
    {
        $hour = Sql::hourOf('created_at');

        $counts = $this->inRange()
            ->selectRaw("{$hour} as hour_of_day, COUNT(*) as total")
            ->groupBy('hour_of_day')
            ->pluck('total', 'hour_of_day');

        return array_map(fn (int $hour): int => (int) ($counts[$hour] ?? 0), range(0, 23));
    }

    /**
     * @return list<array{status: string, label: string, total: int}>
     */
    private function byStatus(): array
    {
        $counts = $this->inRange()
            ->selectRaw('status, COUNT(*) as total')
            ->groupBy('status')
            ->pluck('total', 'status');

        return collect(ReportStatus::cases())
            ->map(fn (ReportStatus $status): array => [
                'status' => $status->value,
                'label' => $status->label(),
                'total' => (int) ($counts[$status->value] ?? 0),
            ])
            ->values()
            ->all();
    }
}
