<?php

namespace App\Services;

use App\Enums\ReportStatus;
use App\Models\DriverShift;
use App\Models\Report;
use Illuminate\Support\Collection;

/**
 * Data posisi driver aktif untuk Peta Live, mini peta dashboard, dan polling cadangan.
 * Sumbernya driver_last_locations (bukan driver_location_logs) sesuai arsitektur realtime.
 */
class TrackingService
{
    /**
     * @return Collection<int, array<string, mixed>>
     */
    public function activeDrivers(?int $driverId = null): Collection
    {
        $shifts = DriverShift::query()
            ->open()
            ->when($driverId, fn ($query) => $query->where('driver_id', $driverId))
            ->with([
                'driver:id,name,phone',
                'driver.driverProfile:id,user_id,clinic_id,is_on_duty',
                'driver.driverProfile.clinic:id,name',
                'driver.lastLocation',
                'ambulance:id,ambulance_type_id,plate_number',
                'ambulance.ambulanceType:id,code,name',
            ])
            ->get();

        $activeReports = Report::query()
            ->whereIn('driver_id', $shifts->pluck('driver_id'))
            ->whereIn('status', ReportStatus::activeValues())
            ->get(['id', 'code', 'status', 'driver_id'])
            ->keyBy('driver_id');

        return $shifts->map(function (DriverShift $shift) use ($activeReports): array {
            $driver = $shift->driver;
            $location = $driver->lastLocation;
            $report = $activeReports->get($driver->id);

            return [
                'driver_id' => $driver->id,
                'shift_id' => $shift->id,
                'name' => $driver->name,
                'phone' => $driver->phone,
                'clinic_id' => $driver->driverProfile?->clinic_id,
                'clinic_name' => $driver->driverProfile?->clinic?->name,
                'plate_number' => $shift->ambulance->plate_number,
                'ambulance_type_id' => $shift->ambulance->ambulance_type_id,
                'ambulance_type' => $shift->ambulance->ambulanceType->name,
                'icon' => $shift->ambulance->ambulanceType->mapIcon(),
                'lat' => $location ? (float) $location->latitude : null,
                'lng' => $location ? (float) $location->longitude : null,
                'speed_kmh' => $location?->speed_kmh !== null ? (float) $location->speed_kmh : null,
                'heading' => $location?->heading,
                'accuracy_m' => $location?->accuracy_m !== null ? (float) $location->accuracy_m : null,
                'battery_level' => $location?->battery_level,
                'is_mock_location' => (bool) $location?->is_mock_location,
                'is_on_duty' => (bool) $driver->driverProfile?->is_on_duty,
                'report_code' => $report?->code,
                'report_status' => $report?->status->value,
                'report_status_label' => $report?->status->label(),
                'recorded_at' => $location?->recorded_at?->toIso8601String(),
                'started_at' => $shift->started_at->toIso8601String(),
                'history_url' => route('admin.location-logs.index', ['driver_id' => $driver->id]),
                'detail_url' => route('admin.drivers.show', $driver->id),
            ];
        })->values();
    }

    /**
     * Lokasi laporan yang sedang dituju ambulans (status diambil / dalam perjalanan).
     *
     * @return Collection<int, array<string, mixed>>
     */
    public function activeReportLocations(): Collection
    {
        return Report::query()
            ->whereIn('status', [ReportStatus::Diambil, ReportStatus::DalamPerjalanan])
            ->with('reportType:id,name,color,icon')
            ->get(['id', 'code', 'status', 'report_type_id', 'latitude', 'longitude', 'address'])
            ->map(fn (Report $report): array => [
                'id' => $report->id,
                'code' => $report->code,
                'type' => $report->reportType->name,
                'color' => $report->reportType->color,
                'status' => $report->status->value,
                'status_label' => $report->status->label(),
                'lat' => (float) $report->latitude,
                'lng' => (float) $report->longitude,
                'address' => $report->shortAddress(),
                'url' => route('admin.reports.show', $report),
            ]);
    }
}
