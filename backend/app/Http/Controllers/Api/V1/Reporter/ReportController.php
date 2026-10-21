<?php

namespace App\Http\Controllers\Api\V1\Reporter;

use App\Enums\ReportStatus;
use App\Exceptions\ApiException;
use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Api\V1\Reporter\StoreReportRequest;
use App\Http\Resources\ReportDetailResource;
use App\Http\Resources\ReportResource;
use App\Models\Report;
use App\Services\LocationService;
use App\Services\ReportService;
use App\Services\Routing\RouteService;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

/**
 * Laporan milik pelapor. Pelapor tidak bisa membatalkan laporan.
 *
 * @group Pelapor
 */
class ReportController extends ApiController
{
    public function store(StoreReportRequest $request, ReportService $reports): JsonResponse
    {
        $report = $reports->create(
            $request->user(),
            $request->reportType(),
            $request->safe()->except(['photos', 'death_certificate']),
            $request->file('photos', []),
            $request->file('death_certificate'),
        );

        return $this->created(ReportDetailResource::make($this->loadDetail($report)));
    }

    public function index(Request $request): JsonResponse
    {
        $filters = $request->validate([
            'status' => ['nullable', 'in:'.implode(',', array_column(ReportStatus::cases(), 'value'))],
            'type' => ['nullable', 'string', 'max:30'],
        ]);

        $reports = Report::query()
            ->where('reporter_id', $request->user()->id)
            ->when($filters['status'] ?? null, fn (Builder $query, string $status) => $query->where('status', $status))
            ->when($filters['type'] ?? null, fn (Builder $query, string $code) => $query->whereHas('reportType', fn (Builder $query) => $query->where('code', $code)))
            ->with(['reportType', 'driver:id,name,phone', 'ambulance:id,plate_number'])
            ->latest()
            ->orderByDesc('id')
            ->paginate(15);

        return $this->paginated($reports, ReportResource::class);
    }

    public function show(Request $request, Report $report): JsonResponse
    {
        $this->ensureOwner($request, $report);

        return $this->ok(ReportDetailResource::make($this->loadDetail($report)));
    }

    /**
     * Posisi ambulans live untuk fallback polling (websocket report.{id} adalah jalur utama).
     */
    public function driverLocation(Request $request, Report $report, LocationService $locations): JsonResponse
    {
        $this->ensureOwner($request, $report);

        if (! in_array($report->status, ReportStatus::active(), true) || $report->driver_id === null) {
            throw ApiException::conflict('tracking_unavailable', 'Posisi ambulans hanya tersedia saat laporan sedang ditangani driver.');
        }

        $location = Cache::remember(
            "report:{$report->id}:driver-location",
            (int) config('medrive.location.reporter_poll_cache_seconds'),
            fn (): ?array => $locations->latestForDriver($report->driver_id),
        );

        return $this->ok([
            'report_id' => $report->id,
            'status' => $report->status->value,
            'location' => $location,
            'channel' => 'private-report.'.$report->id,
        ]);
    }

    /**
     * Rute & ETA ambulans
     *
     * Dari posisi terakhir ambulans ke titik jemput (ke tujuan antar saat status mengantar pasien).
     * Bila OSRM gagal dan ada rute lama, respons berisi rute itu dengan stale = true.
     */
    public function route(Request $request, Report $report, RouteService $routes): JsonResponse
    {
        $this->ensureOwner($request, $report);

        return $this->ok(['report_id' => $report->id, ...$routes->forReport($report)]);
    }

    private function ensureOwner(Request $request, Report $report): void
    {
        if ($report->reporter_id !== $request->user()->id) {
            throw ApiException::forbidden('not_your_report', 'Laporan ini bukan milik Anda.');
        }
    }

    private function loadDetail(Report $report): Report
    {
        return $report->load([
            'reportType',
            'driver:id,name,phone',
            'driver.driverProfile:id,user_id,photo_path',
            'ambulance.ambulanceType',
            'accidentDetail',
            'medicalDetail',
            'maternityDetail.destinationClinic',
            'funeralDetail',
            'patients',
            'attachments',
            'statusLogs' => fn ($query) => $query->orderBy('created_at')->orderBy('id'),
        ]);
    }
}
