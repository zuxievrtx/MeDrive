<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Api\ApiController;
use App\Models\DriverShift;
use App\Services\TrackingService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

/**
 * Posisi awal Peta Live dan polling cadangan: driver_last_locations JOIN shift terbuka, ambulans, profil.
 */
class TrackingController extends ApiController
{
    public function __invoke(Request $request, TrackingService $tracking): JsonResponse
    {
        Gate::authorize('viewAny', DriverShift::class);

        $driverId = $request->integer('driver_id') ?: null;

        return $this->ok([
            'drivers' => $tracking->activeDrivers($driverId),
            'reports' => $driverId ? [] : $tracking->activeReportLocations(),
            'generated_at' => now()->toIso8601String(),
        ]);
    }
}
