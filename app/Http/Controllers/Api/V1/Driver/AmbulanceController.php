<?php

namespace App\Http\Controllers\Api\V1\Driver;

use App\Enums\AmbulanceStatus;
use App\Http\Controllers\Api\ApiController;
use App\Http\Resources\AmbulanceResource;
use App\Models\Ambulance;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Ambulans yang bisa dipilih saat membuka shift: milik klinik driver, tersedia, dan tidak sedang dipakai.
 */
class AmbulanceController extends ApiController
{
    public function __invoke(Request $request): JsonResponse
    {
        $clinicId = $request->user()->driverProfile()->value('clinic_id');

        $ambulances = Ambulance::query()
            ->where('clinic_id', $clinicId)
            ->where('status', AmbulanceStatus::Tersedia)
            ->whereDoesntHave('openShift')
            ->with('ambulanceType')
            ->orderBy('plate_number')
            ->get();

        return $this->ok(AmbulanceResource::collection($ambulances)->resolve($request));
    }
}
