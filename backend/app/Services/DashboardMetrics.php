<?php

namespace App\Services;

use App\Enums\AmbulanceStatus;
use App\Enums\ReportStatus;
use App\Models\Ambulance;
use App\Models\DriverCertification;
use App\Models\DriverProfile;
use App\Models\DriverShift;
use App\Models\Report;
use App\Support\Sql;
use Carbon\CarbonImmutable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Collection;

/**
 * Angka ringkasan beranda. Pembanding "kemarin pada jam yang sama" direkonstruksi dari kolom waktu laporan/shift.
 */
class DashboardMetrics
{
    private CarbonImmutable $now;

    private CarbonImmutable $yesterday;

    public function __construct()
    {
        $this->now = CarbonImmutable::now();
        $this->yesterday = $this->now->subDay();
    }

    /**
     * @return array{current: int, previous: int}
     */
    public function reportsToday(): array
    {
        return [
            'current' => Report::query()->whereBetween('created_at', [$this->now->startOfDay(), $this->now])->count(),
            'previous' => Report::query()->whereBetween('created_at', [$this->yesterday->startOfDay(), $this->yesterday])->count(),
        ];
    }

    /**
     * Laporan aktif = sudah diambil dan belum selesai (status diambil sampai mengantar_pasien).
     *
     * @return array{current: int, previous: int, breakdown: array<string, int>}
     */
    public function activeReports(): array
    {
        $breakdown = Report::query()
            ->whereIn('status', ReportStatus::activeValues())
            ->selectRaw('status, COUNT(*) as total')
            ->groupBy('status')
            ->pluck('total', 'status')
            ->map(fn ($total): int => (int) $total);

        $previous = Report::query()
            ->where('taken_at', '<=', $this->yesterday)
            ->where(fn (Builder $query) => $query->whereNull('completed_at')->orWhere('completed_at', '>', $this->yesterday))
            ->count();

        return [
            'current' => (int) $breakdown->sum(),
            'previous' => $previous,
            'breakdown' => collect(ReportStatus::active())
                ->mapWithKeys(fn (ReportStatus $status): array => [$status->label() => $breakdown->get($status->value, 0)])
                ->all(),
        ];
    }

    /**
     * @return array{current: int, previous: int}
     */
    public function pendingReports(): array
    {
        $previous = Report::query()
            ->where('created_at', '<=', $this->yesterday)
            ->where(fn (Builder $query) => $query->whereNull('taken_at')->orWhere('taken_at', '>', $this->yesterday))
            ->where(fn (Builder $query) => $query
                ->where('status', '!=', ReportStatus::Dibatalkan)
                ->orWhere('updated_at', '>', $this->yesterday))
            ->count();

        return [
            'current' => Report::query()->where('status', ReportStatus::Menunggu)->count(),
            'previous' => $previous,
        ];
    }

    /**
     * @return Collection<int, Report>
     */
    public function latestPending(int $limit = 5): Collection
    {
        return Report::query()
            ->where('status', ReportStatus::Menunggu)
            ->with('reportType:id,name,icon,color,priority')
            ->latest()
            ->limit($limit)
            ->get();
    }

    /**
     * @return array{drivers: int, drivers_previous: int, available: int, in_use: int, maintenance: int, inactive: int}
     */
    public function fleet(): array
    {
        $openShiftAmbulanceIds = DriverShift::query()->open()->pluck('ambulance_id');

        $statusCounts = Ambulance::query()
            ->selectRaw('status, COUNT(*) as total')
            ->groupBy('status')
            ->pluck('total', 'status');

        return [
            'drivers' => $openShiftAmbulanceIds->count(),
            'drivers_previous' => DriverShift::query()
                ->where('started_at', '<=', $this->yesterday)
                ->where(fn (Builder $query) => $query->whereNull('ended_at')->orWhere('ended_at', '>', $this->yesterday))
                ->count(),
            'available' => Ambulance::query()
                ->where('status', AmbulanceStatus::Tersedia)
                ->whereNotIn('id', $openShiftAmbulanceIds)
                ->count(),
            'in_use' => $openShiftAmbulanceIds->count(),
            'maintenance' => (int) $statusCounts->get(AmbulanceStatus::Perawatan->value, 0),
            'inactive' => (int) $statusCounts->get(AmbulanceStatus::Nonaktif->value, 0),
        ];
    }

    /**
     * Jumlah laporan per hari, 14 hari terakhir dan 14 hari sebelumnya.
     *
     * @return array{labels: list<string>, current: list<int>, previous: list<int>}
     */
    public function dailyTrend(int $days = 14): array
    {
        $start = $this->now->startOfDay()->subDays($days - 1);
        $previousStart = $start->subDays($days);
        $bucket = Sql::bucket('created_at', 'day');

        $counts = Report::query()
            ->where('created_at', '>=', $previousStart)
            ->selectRaw("{$bucket} as bucket, COUNT(*) as total")
            ->groupBy('bucket')
            ->pluck('total', 'bucket');

        $labels = $current = $previous = [];

        for ($i = 0; $i < $days; $i++) {
            $day = $start->addDays($i);
            $labels[] = $day->translatedFormat('j M');
            $current[] = (int) $counts->get($day->toDateString(), 0);
            $previous[] = (int) $counts->get($day->subDays($days)->toDateString(), 0);
        }

        return compact('labels', 'current', 'previous');
    }

    /**
     * @return Collection<int, Report>
     */
    public function latestReports(int $limit = 8): Collection
    {
        return Report::query()
            ->with('reportType:id,name,icon,color')
            ->latest()
            ->limit($limit)
            ->get();
    }

    /**
     * SIM dan sertifikat yang sudah atau akan kedaluwarsa dalam rentang peringatan.
     *
     * @return Collection<int, array{driver_id: int, driver: string, document: string, expires_at: CarbonImmutable, is_expired: bool}>
     */
    public function expiringDocuments(): Collection
    {
        $limit = $this->now->addDays(config('medrive.expiry_warning_days'))->toDateString();

        $licenses = DriverProfile::query()
            ->with('user:id,name')
            ->whereDate('license_expires_at', '<=', $limit)
            ->get()
            ->map(fn (DriverProfile $profile): array => [
                'driver_id' => $profile->user_id,
                'driver' => $profile->user->name,
                'document' => 'SIM '.$profile->license_class->label(),
                'expires_at' => $profile->license_expires_at->toImmutable(),
                'is_expired' => $profile->license_expires_at->lt(today()),
            ]);

        $certifications = DriverCertification::query()
            ->with('driver:id,name')
            ->whereNotNull('expires_at')
            ->whereDate('expires_at', '<=', $limit)
            ->get()
            ->map(fn (DriverCertification $certification): array => [
                'driver_id' => $certification->driver_id,
                'driver' => $certification->driver->name,
                'document' => 'Sertifikat '.$certification->name,
                'expires_at' => $certification->expires_at->toImmutable(),
                'is_expired' => $certification->expires_at->lt(today()),
            ]);

        return $licenses->concat($certifications)->sortBy('expires_at')->values();
    }
}
