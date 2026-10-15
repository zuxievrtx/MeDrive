<?php

namespace App\Http\Controllers\Api\V1\Driver;

use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Api\V1\Driver\LocationBatchRequest;
use App\Models\UserDevice;
use App\Services\LocationService;
use Illuminate\Http\JsonResponse;

/**
 * Ping lokasi batch. Respons memuat next_interval_seconds yang wajib dipatuhi aplikasi.
 */
class LocationController extends ApiController
{
    public function __invoke(LocationBatchRequest $request, LocationService $locations): JsonResponse
    {
        $result = $locations->ingest($request->user(), $request->input('points', []));

        if ($token = $request->input('device.fcm_token')) {
            UserDevice::query()->where('user_id', $request->user()->id)->where('fcm_token', $token)->update(array_filter([
                'last_seen_at' => now(),
                'app_version' => $request->input('device.app_version'),
                'device_model' => $request->input('device.device_model'),
            ]));
        }

        return $this->ok($result);
    }
}
