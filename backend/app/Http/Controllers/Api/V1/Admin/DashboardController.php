<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Api\ApiController;
use App\Http\Resources\ReportResource;
use App\Models\Report;
use App\Services\DashboardMetrics;
use App\Services\EscalationService;
use App\Services\TrackingService;
use App\Support\Delta;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

/**
 * @group Admin
 */
class DashboardController extends ApiController
{
    public function __invoke(Request $request, DashboardMetrics $metrics, TrackingService $tracking, EscalationService $escalation): JsonResponse
    {
        Gate::authorize('viewAny', Report::class);

        $today = $metrics->reportsToday();
        $active = $metrics->activeReports();
        $pending = $metrics->pendingReports();
        $fleet = $metrics->fleet();

        return $this->ok([
            'cards' => [
                'reports_today' => Delta::compare($today['current'], $today['previous']),
                'active_reports' => [...Delta::compare($active['current'], $active['previous']), 'breakdown' => $active['breakdown']],
                'pending_reports' => Delta::compare($pending['current'], $pending['previous']),
                'fleet' => [...$fleet, 'drivers_delta' => Delta::percent($fleet['drivers'], $fleet['drivers_previous'])],
            ],
            'latest_pending' => ReportResource::collection($metrics->latestPending())->resolve($request),
            'latest_reports' => ReportResource::collection($metrics->latestReports())->resolve($request),
            'trend' => $metrics->dailyTrend(),
            'expiring_documents' => $metrics->expiringDocuments()->map(fn (array $document): array => [
                ...$document,
                'expires_at' => $document['expires_at']->toDateString(),
                'days_left' => (int) today()->diffInDays($document['expires_at'], false),
            ])->values(),
            'active_driver_count' => $tracking->activeDrivers()->count(),
            'alarmed_reports' => $escalation->alarmedReports()->count(),
        ]);
    }
}
