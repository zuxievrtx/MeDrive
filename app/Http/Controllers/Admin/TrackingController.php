<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AmbulanceType;
use App\Models\Clinic;
use App\Models\DriverShift;
use App\Services\TrackingService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\View\View;

class TrackingController extends Controller
{
    public function index(): View
    {
        Gate::authorize('viewAny', DriverShift::class);

        return view('admin.tracking.index', [
            'clinics' => Clinic::query()->orderBy('name')->get(['id', 'name']),
            'ambulanceTypes' => AmbulanceType::query()->orderBy('name')->get(['id', 'name']),
        ]);
    }

    /**
     * Data awal dan polling cadangan: driver_last_locations JOIN shift terbuka, ambulans, profil driver.
     */
    public function data(Request $request, TrackingService $tracking): JsonResponse
    {
        Gate::authorize('viewAny', DriverShift::class);

        $driverId = $request->integer('driver_id') ?: null;

        return response()->json([
            'drivers' => $tracking->activeDrivers($driverId),
            'reports' => $driverId ? [] : $tracking->activeReportLocations(),
            'generated_at' => now()->toIso8601String(),
        ]);
    }
}
