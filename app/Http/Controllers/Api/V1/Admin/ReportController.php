<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Admin\CancelReportRequest;
use App\Http\Resources\ReportDetailResource;
use App\Http\Resources\ReportResource;
use App\Models\Report;
use App\Services\AdminLogger;
use App\Services\EscalationService;
use App\Services\ReportQuery;
use App\Services\ReportService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Symfony\Component\HttpFoundation\StreamedResponse;

/**
 * Monitoring laporan. Admin tidak membuat laporan dan tidak menugaskan driver; hanya membatalkan laporan menunggu.
 */
class ReportController extends ApiController
{
    public function index(Request $request): JsonResponse
    {
        Gate::authorize('viewAny', Report::class);

        $reports = ReportQuery::filtered($request->validate(ReportQuery::rules()))
            ->with(['reportType', 'reporter:id,name,phone', 'driver:id,name,phone', 'ambulance:id,plate_number'])
            ->latest()
            ->orderByDesc('id')
            ->paginate(20);

        return $this->paginated($reports, ReportResource::class);
    }

    public function show(Request $request, Report $report, EscalationService $escalation): JsonResponse
    {
        Gate::authorize('view', $report);

        $report->load([
            'reportType.ambulanceTypes:id,name',
            'reporter.devices',
            'driver.driverProfile.clinic',
            'driver.lastLocation',
            'ambulance.ambulanceType',
            'ambulance.clinic',
            'accidentDetail',
            'medicalDetail',
            'maternityDetail.destinationClinic',
            'funeralDetail',
            'patients',
            'attachments',
            'statusLogs' => fn ($query) => $query->with('changer:id,name,role')->orderBy('created_at')->orderBy('id'),
            'dispatches' => fn ($query) => $query->with('driver:id,name', 'shift.ambulance:id,plate_number')->orderBy('distance_km'),
        ]);

        return $this->ok([
            ...ReportDetailResource::make($report)->resolve($request),
            'dispatch_state' => $escalation->stateFor($report),
        ]);
    }

    public function cancel(CancelReportRequest $request, Report $report, ReportService $reports, AdminLogger $logger): JsonResponse
    {
        $cancelled = $reports->cancelByAdmin($report, $request->user(), $request->validated('reason'), $logger);

        return $this->ok(ReportResource::make($cancelled->load('reportType')));
    }

    public function export(Request $request): StreamedResponse
    {
        Gate::authorize('export', Report::class);

        $query = ReportQuery::filtered($request->validate(ReportQuery::rules()))
            ->with(['reportType:id,name', 'reporter:id,name,phone', 'driver:id,name', 'ambulance:id,plate_number,clinic_id', 'ambulance.clinic:id,name'])
            ->latest()
            ->orderByDesc('id');

        return response()->streamDownload(function () use ($query): void {
            $output = fopen('php://output', 'w');
            // BOM agar Excel membaca UTF-8 dengan benar.
            fwrite($output, "\xEF\xBB\xBF");
            fputcsv($output, ['Kode', 'Jenis', 'Status', 'Pelapor', 'Telepon pelapor', 'Driver', 'Nopol', 'Klinik armada', 'Alamat', 'Dibuat', 'Diambil', 'Tiba', 'Selesai', 'Respons (menit)']);

            foreach ($query->lazy(500) as $report) {
                fputcsv($output, [
                    $report->code,
                    $report->reportType->name,
                    $report->status->label(),
                    $report->reporter->name,
                    $report->reporter->phone,
                    $report->driver?->name,
                    $report->ambulance?->plate_number,
                    $report->ambulance?->clinic?->name,
                    $report->address,
                    $report->created_at?->format('Y-m-d H:i:s'),
                    $report->taken_at?->format('Y-m-d H:i:s'),
                    $report->arrived_at?->format('Y-m-d H:i:s'),
                    $report->completed_at?->format('Y-m-d H:i:s'),
                    $report->response_time_minutes,
                ]);
            }

            fclose($output);
        }, 'laporan-medrive-'.now()->format('Ymd-His').'.csv', ['Content-Type' => 'text/csv; charset=UTF-8']);
    }
}
