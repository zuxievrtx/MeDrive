<?php

namespace App\Http\Requests\Api\V1;

class RegisterDeviceRequest extends ApiFormRequest
{
    /**
     * @return array<string, array<int, string>>
     */
    public function rules(): array
    {
        return [
            'fcm_token' => ['required', 'string', 'max:255'],
            'platform' => ['required', 'in:android,ios,web'],
            'device_model' => ['nullable', 'string', 'max:100'],
            'app_version' => ['nullable', 'string', 'max:20'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return ['fcm_token' => 'token FCM', 'platform' => 'platform', 'device_model' => 'model perangkat', 'app_version' => 'versi aplikasi'];
    }
}
