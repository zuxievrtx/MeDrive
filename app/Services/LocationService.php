<?php

namespace App\Services;

use App\Enums\ReportStatus;
use App\Events\DriverLocationUpdated;
use App\Events\ReportDriverLocationUpdated;
use App\Exceptions\ApiException;
use App\Models\DriverLastLocation;
use App\Models\DriverLocationLog;
use App\Models\DriverProfile;
use App\Models\DriverShift;
use App\Models\Report;
use App\Models\User;
use Carbon\CarbonImmutable;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Cache;
use Throwable;

/**
 * Pipeline lokasi tiga lapis: ping batch masuk buffer, flush massal tiap 10 detik ke log + snapshot,
 * lalu broadcast yang dibatasi per driver. Interval ping ditentukan server (next_interval_seconds).
 */
class LocationService
{
    private const PROVIDERS = ['gps', 'network', 'fused'];

    public function __construct(private LocationBuffer $buffer) {}

    /**
     * Terima batch titik dari aplikasi driver. Titik tidak valid ditolak satu per satu tanpa menggagalkan batch.
     *
     * @param  list<mixed>  $points
     * @return array{accepted: int, rejected: list<array{index: int, reason: string}>, next_interval_seconds: int, distance_filter_m: int, max_batch_points: int, max_batch_age_seconds: int, server_time: string}
     */
    public function ingest(User $driver, array $points): array
    {
        $shift = DriverShift::query()->open()->where('driver_id', $driver->id)->first(['id', 'driver_id', 'ambulance_id']);

        if (! $shift) {
            throw ApiException::conflict('no_open_shift', 'Lokasi hanya dikirim selama shift terbuka. Hentikan pelacakan di aplikasi.');
        }

        $activeReportId = Report::query()
            ->where('driver_id', $driver->id)
            ->whereIn('status', ReportStatus::activeValues())
            ->value('id');

        $receivedAt = now()->format('Y-m-d H:i:s.v');
        $accepted = [];
        $rejected = [];

        foreach (array_values($points) as $index => $point) {
            $error = is_array($point) ? $this->validatePoint($point) : 'Format titik tidak valid.';

            if ($error !== null) {
                $rejected[] = ['index' => $index, 'reason' => $error];

                continue;
            }

            $accepted[] = [
                'driver_id' => $driver->id,
                'shift_id' => $shift->id,
                'report_id' => $activeReportId,
                'latitude' => round((float) $point['latitude'], 7),
                'longitude' => round((float) $point['longitude'], 7),
                'accuracy_m' => $this->nullableFloat($point['accuracy_m'] ?? null, 1),
                'altitude_m' => $this->nullableFloat($point['altitude_m'] ?? null, 1),
                'speed_kmh' => $this->nullableFloat($point['speed_kmh'] ?? null, 1),
                'heading' => isset($point['heading']) ? (int) $point['heading'] : null,
                'battery_level' => isset($point['battery_level']) ? (int) $point['battery_level'] : null,
                'provider' => $point['provider'] ?? null,
                'is_mock_location' => filter_var($point['is_mock_location'] ?? false, FILTER_VALIDATE_BOOL),
                'recorded_at' => CarbonImmutable::parse($point['recorded_at'])->setTimezone(config('app.timezone'))->format('Y-m-d H:i:s.v'),
                'received_at' => $receivedAt,
            ];
        }

        usort($accepted, fn (array $a, array $b): int => strcmp($a['recorded_at'], $b['recorded_at']));
        $this->buffer->push($accepted);

        $isOnDuty = (bool) DriverProfile::query()->where('user_id', $driver->id)->value('is_on_duty');

        return [
            'accepted' => count($accepted),
            'rejected' => $rejected,
            'next_interval_seconds' => $this->nextInterval($driver->id, $isOnDuty, $accepted),
            'distance_filter_m' => (int) config('medrive.location.distance_filter_m'),
            'max_batch_points' => (int) config('medrive.location.max_batch_points'),
            'max_batch_age_seconds' => (int) config('medrive.location.max_batch_age_seconds'),
            'server_time' => now()->toIso8601String(),
        ];
    }

    /**
     * Interval ping berikutnya: bertugas 5 dtk, standby 25 dtk, diam 60 dtk, dikali 2 saat baterai < 20%.
     *
     * @param  list<array<string, mixed>>  $points
     */
    public function nextInterval(int $driverId, bool $isOnDuty, array $points = []): int
    {
        $config = config('medrive.location');
        $needed = (int) $config['stationary_consecutive_points'];

        $speeds = [...Cache::get("location:speeds:{$driverId}", []), ...array_column($points, 'speed_kmh')];
        $speeds = array_slice(array_values(array_filter($speeds, fn ($speed) => $speed !== null)), -$needed);
        Cache::put("location:speeds:{$driverId}", $speeds, 600);

        $battery = $points !== [] ? end($points)['battery_level'] : null;
        $battery ??= Cache::get("location:battery:{$driverId}");
        Cache::put("location:battery:{$driverId}", $battery, 600);

        $isStationary = count($speeds) >= $needed
            && collect($speeds)->every(fn ($speed): bool => (float) $speed < (float) $config['stationary_speed_kmh']);

        $interval = match (true) {
            $isOnDuty => $config['interval_seconds']['on_duty'],
            $isStationary => $config['interval_seconds']['stationary'],
            default => $config['interval_seconds']['standby'],
        };

        if ($battery !== null && $battery < $config['low_battery_percent']) {
            $interval *= $config['low_battery_multiplier'];
        }

        return (int) $interval;
    }

    /**
     * Kosongkan buffer: satu bulk INSERT ke log, upsert snapshot (maks 1x per 15 dtk per driver),
     * lalu broadcast (maks 1x per 5 dtk per driver) ke admin.tracking dan report.{id}.
     *
     * @return array{logs: int, snapshots: int, broadcasts: int}
     */
    public function flush(): array
    {
        $entries = $this->buffer->drain();

        if ($entries === []) {
            return ['logs' => 0, 'snapshots' => 0, 'broadcasts' => 0];
        }

        try {
            foreach (array_chunk($entries, 500) as $chunk) {
                DriverLocationLog::query()->insert($chunk);
            }
        } catch (Throwable $exception) {
            // Jangan sampai titik hilang: kembalikan ke buffer untuk flush berikutnya.
            $this->buffer->push($entries);

            throw $exception;
        }

        $latest = collect($entries)->groupBy('driver_id')->map(fn (Collection $points): array => $points->sortBy('recorded_at')->last());

        $snapshots = [];
        $broadcastDrivers = [];

        foreach ($latest as $driverId => $point) {
            Cache::put("location:latest:{$driverId}", $point, now()->addDay());

            if (Cache::add("location:snapshot-guard:{$driverId}", true, (int) config('medrive.location.snapshot_min_seconds'))) {
                $snapshots[] = [
                    'driver_id' => $driverId,
                    'shift_id' => $point['shift_id'],
                    'latitude' => $point['latitude'],
                    'longitude' => $point['longitude'],
                    'accuracy_m' => $point['accuracy_m'],
                    'speed_kmh' => $point['speed_kmh'],
                    'heading' => $point['heading'],
                    'battery_level' => $point['battery_level'],
                    'is_mock_location' => $point['is_mock_location'],
                    'recorded_at' => $point['recorded_at'],
                    'updated_at' => now(),
                ];
            }

            if (Cache::add("location:broadcast-guard:{$driverId}", true, (int) config('medrive.location.broadcast_min_seconds'))) {
                $broadcastDrivers[] = $driverId;
            }
        }

        if ($snapshots !== []) {
            DriverLastLocation::query()->upsert($snapshots, ['driver_id'], [
                'shift_id', 'latitude', 'longitude', 'accuracy_m', 'speed_kmh', 'heading',
                'battery_level', 'is_mock_location', 'recorded_at', 'updated_at',
            ]);
        }

        $this->broadcast($latest->only($broadcastDrivers));

        return ['logs' => count($entries), 'snapshots' => count($snapshots), 'broadcasts' => count($broadcastDrivers)];
    }

    /**
     * Posisi terbaru driver untuk fallback polling pelapor: titik terakhir dari flush, atau snapshot.
     *
     * @return array{lat: float, lng: float, heading: ?int, speed_kmh: ?float, updated_at: string}|null
     */
    public function latestForDriver(int $driverId): ?array
    {
        $point = Cache::get("location:latest:{$driverId}");

        if ($point) {
            return $this->publicPoint($point);
        }

        $snapshot = DriverLastLocation::query()->find($driverId);

        return $snapshot ? [
            'lat' => (float) $snapshot->latitude,
            'lng' => (float) $snapshot->longitude,
            'heading' => $snapshot->heading,
            'speed_kmh' => $snapshot->speed_kmh !== null ? (float) $snapshot->speed_kmh : null,
            'updated_at' => $snapshot->recorded_at->toIso8601String(),
        ] : null;
    }

    /**
     * @param  Collection<int|string, array<string, mixed>>  $points
     */
    private function broadcast(Collection $points): void
    {
        if ($points->isEmpty()) {
            return;
        }

        $driverIds = $points->keys()->map(fn ($id): int => (int) $id)->all();

        $shifts = DriverShift::query()
            ->open()
            ->whereIn('driver_id', $driverIds)
            ->with(['driver:id,name', 'driver.driverProfile:id,user_id,is_on_duty', 'ambulance:id,ambulance_type_id,plate_number', 'ambulance.ambulanceType:id,name'])
            ->get()
            ->keyBy('driver_id');

        $reports = Report::query()
            ->whereIn('driver_id', $driverIds)
            ->whereIn('status', ReportStatus::activeValues())
            ->get(['id', 'code', 'status', 'driver_id'])
            ->keyBy('driver_id');

        foreach ($points as $driverId => $point) {
            $shift = $shifts->get($driverId);
            $report = $reports->get($driverId);

            DriverLocationUpdated::dispatch([
                'driver_id' => (int) $driverId,
                'name' => $shift?->driver->name ?? '',
                'plate_number' => $shift?->ambulance->plate_number,
                'ambulance_type' => $shift?->ambulance->ambulanceType->name,
                'lat' => (float) $point['latitude'],
                'lng' => (float) $point['longitude'],
                'speed_kmh' => $point['speed_kmh'],
                'heading' => $point['heading'],
                'battery_level' => $point['battery_level'],
                'accuracy_m' => $point['accuracy_m'],
                'is_mock_location' => (bool) $point['is_mock_location'],
                'is_on_duty' => (bool) $shift?->driver->driverProfile?->is_on_duty,
                'report_code' => $report?->code,
                'report_status' => $report?->status->value,
                'recorded_at' => CarbonImmutable::parse($point['recorded_at'])->toIso8601String(),
            ]);

            if ($report) {
                ReportDriverLocationUpdated::dispatch($report->id, $this->publicPoint($point));
            }
        }
    }

    /**
     * @param  array<string, mixed>  $point
     * @return array{lat: float, lng: float, heading: ?int, speed_kmh: ?float, updated_at: string}
     */
    private function publicPoint(array $point): array
    {
        return [
            'lat' => (float) $point['latitude'],
            'lng' => (float) $point['longitude'],
            'heading' => $point['heading'],
            'speed_kmh' => $point['speed_kmh'] !== null ? (float) $point['speed_kmh'] : null,
            'updated_at' => CarbonImmutable::parse($point['recorded_at'])->toIso8601String(),
        ];
    }

    /**
     * @param  array<string, mixed>  $point
     */
    private function validatePoint(array $point): ?string
    {
        $latitude = $point['latitude'] ?? null;
        $longitude = $point['longitude'] ?? null;

        return match (true) {
            ! is_numeric($latitude) || $latitude < -90 || $latitude > 90 => 'Latitude harus antara -90 dan 90.',
            ! is_numeric($longitude) || $longitude < -180 || $longitude > 180 => 'Longitude harus antara -180 dan 180.',
            isset($point['heading']) && (! is_numeric($point['heading']) || $point['heading'] < 0 || $point['heading'] >= 360) => 'Heading harus 0 sampai 359.',
            isset($point['battery_level']) && (! is_numeric($point['battery_level']) || $point['battery_level'] < 0 || $point['battery_level'] > 100) => 'Baterai harus 0 sampai 100.',
            isset($point['speed_kmh']) && (! is_numeric($point['speed_kmh']) || $point['speed_kmh'] < 0 || $point['speed_kmh'] > 999) => 'Kecepatan tidak valid.',
            isset($point['accuracy_m']) && (! is_numeric($point['accuracy_m']) || $point['accuracy_m'] < 0 || $point['accuracy_m'] > 99999) => 'Akurasi tidak valid.',
            isset($point['altitude_m']) && (! is_numeric($point['altitude_m']) || abs((float) $point['altitude_m']) > 999999) => 'Ketinggian tidak valid.',
            isset($point['provider']) && ! in_array($point['provider'], self::PROVIDERS, true) => 'Provider harus gps, network, atau fused.',
            ! $this->isValidTimestamp($point['recorded_at'] ?? null) => 'Waktu titik (recorded_at) tidak valid atau di luar rentang yang diterima.',
            default => null,
        };
    }

    private function isValidTimestamp(mixed $value): bool
    {
        if (! is_string($value) || $value === '') {
            return false;
        }

        try {
            $time = CarbonImmutable::parse($value);
        } catch (Throwable) {
            return false;
        }

        return $time->lessThanOrEqualTo(now()->addMinute())
            && $time->greaterThan(now()->subDays((int) config('medrive.location_log_retention_days')));
    }

    private function nullableFloat(mixed $value, int $precision): ?float
    {
        return $value === null || $value === '' ? null : round((float) $value, $precision);
    }
}
