<?php

namespace App\Http\Controllers\Api\V1\Driver;

use App\Enums\DispatchResponse;
use App\Enums\ReportStatus;
use App\Exceptions\ApiException;
use App\Http\Controllers\Api\ApiController;
use App\Http\Resources\ReportDetailResource;
use App\Http\Resources\ReportDispatchResource;
use App\Models\ReportDispatch;
use App\Services\DispatchService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Tawaran broadcast untuk driver. Push FCM adalah jalur utama; endpoint ini cadangan pull.
 */
class DispatchController extends ApiController
{
    public function __construct(private DispatchService $dispatch) {}

    public function active(Request $request): JsonResponse
    {
        $dispatches = ReportDispatch::query()
            ->where('driver_id', $request->user()->id)
            ->where('response', DispatchResponse::Menunggu)
            ->whereHas('report', fn ($query) => $query->where('status', ReportStatus::Menunggu))
            ->with(['report.reportType'])
            ->orderBy('distance_km')
            ->get();

        return $this->ok(ReportDispatchResource::collection($dispatches)->resolve($request));
    }

    public function show(Request $request, ReportDispatch $dispatch): JsonResponse
    {
        $this->ensureOwner($request, $dispatch);
        $this->dispatch->markOpened($dispatch);

        $dispatch->load(['report.reportType', 'report.accidentDetail', 'report.medicalDetail', 'report.maternityDetail.destinationClinic', 'report.funeralDetail', 'report.patients', 'report.attachments']);

        return $this->ok(ReportDispatchResource::make($dispatch));
    }

    public function accept(Request $request, ReportDispatch $dispatch): JsonResponse
    {
        $this->ensureOwner($request, $dispatch);

        $report = $this->dispatch->accept($dispatch, $request->user());

        return $this->ok(ReportDetailResource::make(ReportController::loadDetail($report)));
    }

    private function ensureOwner(Request $request, ReportDispatch $dispatch): void
    {
        if ($dispatch->driver_id !== $request->user()->id) {
            throw ApiException::forbidden('not_your_dispatch', 'Tawaran ini bukan untuk akun Anda.');
        }
    }
}
