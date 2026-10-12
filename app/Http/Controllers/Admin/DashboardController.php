<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\DashboardMetrics;
use App\Services\TrackingService;
use Illuminate\View\View;

class DashboardController extends Controller
{
    public function __invoke(DashboardMetrics $metrics, TrackingService $tracking): View
    {
        return view('admin.dashboard', [
            'reportsToday' => $metrics->reportsToday(),
            'activeReports' => $metrics->activeReports(),
            'pendingReports' => $metrics->pendingReports(),
            'latestPending' => $metrics->latestPending(),
            'fleet' => $metrics->fleet(),
            'trend' => $metrics->dailyTrend(),
            'latestReports' => $metrics->latestReports(),
            'expiringDocuments' => $metrics->expiringDocuments(),
            'activeDriverCount' => $tracking->activeDrivers()->count(),
        ]);
    }
}
