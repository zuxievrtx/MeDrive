<?php

namespace App\Http\Controllers\Api\V1\Driver;

use App\Http\Controllers\Api\ApiController;
use App\Http\Resources\DriverCertificationResource;
use App\Http\Resources\UserResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Data kepegawaian driver: klinik dan instansi, SIM, sertifikat beserta masa berlaku.
 */
class ProfileController extends ApiController
{
    public function __invoke(Request $request): JsonResponse
    {
        $driver = $request->user()->load([
            'driverProfile.clinic.institution',
            'openShift.ambulance.ambulanceType',
            'certifications' => fn ($query) => $query->orderByDesc('issued_at'),
        ]);

        return $this->ok([
            ...UserResource::make($driver)->resolve($request),
            'certifications' => DriverCertificationResource::collection($driver->certifications)->resolve($request),
        ]);
    }
}
