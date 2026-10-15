<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Enums\ReportStatus;
use App\Http\Controllers\Api\ApiController;
use App\Models\Report;
use App\Services\DispatchService;
use App\Services\EscalationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Data awal panel eskalasi dispatch: laporan menunggu yang sudah melewati ronde pertama atau dialarmkan.
 */
class EscalationController extends ApiController
{
    public function __invoke(Request $request, EscalationService $escalation, DispatchService $dispatch): JsonResponse
    {
        $items = Report::query()
            ->where('status', ReportStatus::Menunggu)
            ->with('reportType:id,name,icon,color,priority')
            ->latest()
            ->limit(50)
            ->get()
            ->map(function (Report $report) use ($escalation, $dispatch): ?array {
                $state = $escalation->stateFor($report);

                if ($state === null || ($state['round'] < 2 && ! $state['alarmed'])) {
                    return null;
                }

                return [
                    'id' => $report->id,
                    'code' => $report->code,
                    'round' => $state['round'],
                    'total_rounds' => $dispatch->totalRounds(),
                    'radius_km' => $dispatch->radiusForRound($state['round']),
                    'is_final' => $state['alarmed'],
                    'address' => $report->shortAddress(),
                    'waiting_minutes' => (int) $report->created_at->diffInMinutes(now()),
                    'url' => route('admin.reports.show', $report),
                    'type' => [
                        'name' => $report->reportType->name,
                        'icon' => $report->reportType->icon,
                        'color' => $report->reportType->color,
                        'priority' => $report->reportType->priority,
                    ],
                ];
            })
            ->filter()
            ->values();

        return $this->ok($items);
    }
}
