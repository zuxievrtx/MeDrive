<?php

namespace App\Http\Requests\Api\V1\Driver;

use App\Http\Requests\Api\V1\ApiFormRequest;

/**
 * Validasi amplop batch saja; setiap titik divalidasi terpisah di LocationService
 * agar satu titik rusak tidak menggagalkan seluruh batch.
 */
class LocationBatchRequest extends ApiFormRequest
{
    /**
     * @return array<string, array<int, string>>
     */
    public function rules(): array
    {
        return [
            'points' => ['required', 'array', 'min:1', 'max:'.(int) config('medrive.location.max_batch_points')],
            'device' => ['nullable', 'array'],
            'device.fcm_token' => ['nullable', 'string', 'max:255'],
            'device.app_version' => ['nullable', 'string', 'max:20'],
            'device.device_model' => ['nullable', 'string', 'max:100'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return ['points' => 'titik lokasi'];
    }
}
