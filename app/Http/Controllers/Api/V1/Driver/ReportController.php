<?php

namespace App\Http\Controllers\Api\V1\Driver;

use App\Enums\ReportStatus;
use App\Exceptions\ApiException;
use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Api\V1\Driver\UpdateReportStatusRequest;
use App\Http\Resources\ReportDetailResource;
use App\Http\Resources\ReportResource;
use App\Models\Report;
use App\Services\ReportService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReportController extends ApiController
{
    public function history(Request $request): JsonResponse
    {
        $reports = Report::query()
            ->where('driver_id', $request->user()->id)
            ->with(['reportType', 'ambulance:id,plate_number'])
            ->latest()
            ->orderByDesc('id')
            ->paginate(15);

        return $this->paginated($reports, ReportResource::class);
    }

    public function show(Request $request, Report $report): JsonResponse
    {
        if ($report->driver_id !== $request->user()->id) {
            throw ApiException::forbidden('not_your_report', 'Laporan ini tidak Anda tangani.');
        }

        return $this->ok(ReportDetailResource::make(self::loadDetail($report)));
    }

    public function status(UpdateReportStatusRequest $request, Report $report, ReportService $reports): JsonResponse
    {
        $updated = $reports->transition(
            $report,
            $request->user(),
            ReportStatus::from($request->validated('status')),
            $request->filled('latitude') ? (float) $request->validated('latitude') : null,
            $request->filled('longitude') ? (float) $request->validated('longitude') : null,
            $request->validated('note'),
        );

        return $this->ok(ReportDetailResource::make(self::loadDetail($updated)));
    }

    /**
     * Driver melihat kontak pelapor (untuk menelepon) tetapi tidak melihat daftar dispatch driver lain.
     */
    public static function loadDetail(Report $report): Report
    {
        return $report->load([
            'reportType',
            'reporter:id,name,phone,email,account_status',
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
