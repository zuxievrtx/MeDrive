<?php

namespace App\Http\Controllers\Api\V1\Driver;

use App\Enums\ReportStatus;
use App\Exceptions\ApiException;
use App\Http\Controllers\Api\ApiController;
use App\Models\Report;
use App\Services\Routing\RouteService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * @group Driver
 */
class RouteController extends ApiController
{
    /**
     * Rute ke TKP
     *
     * Dari posisi terakhir driver ke titik jemput laporan aktif (ke tujuan antar saat status mengantar pasien).
     * Di-cache 60 detik; OSRM dipanggil paling sering sekali per 30 detik per laporan.
     */
    public function __invoke(Request $request, RouteService $routes): JsonResponse
    {
        $report = Report::query()
            ->where('driver_id', $request->user()->id)
            ->whereIn('status', ReportStatus::activeValues())
            ->first();

        if (! $report) {
            throw ApiException::conflict('no_active_report', 'Anda sedang tidak menangani laporan aktif.');
        }

        return $this->ok(['report_id' => $report->id, ...$routes->forReport($report)]);
    }
}
