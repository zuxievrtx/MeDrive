<?php

namespace App\Http\Controllers\Api\V1\Driver;

use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Api\V1\Driver\CloseShiftRequest;
use App\Http\Requests\Api\V1\Driver\OpenShiftRequest;
use App\Http\Resources\DriverShiftResource;
use App\Services\ShiftService;
use Illuminate\Http\JsonResponse;

class ShiftController extends ApiController
{
    public function __construct(private ShiftService $shifts) {}

    public function open(OpenShiftRequest $request): JsonResponse
    {
        return $this->created(DriverShiftResource::make($this->shifts->open($request->user(), $request->integer('ambulance_id'))));
    }

    public function close(CloseShiftRequest $request): JsonResponse
    {
        return $this->ok(DriverShiftResource::make($this->shifts->close($request->user(), $request->validated('reason'))->load('ambulance')));
    }
}
