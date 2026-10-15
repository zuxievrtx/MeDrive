<?php

namespace App\Http\Resources;

use App\Models\UserDevice;
use Illuminate\Http\Request;

/** @mixin UserDevice */
class DeviceResource extends ApiResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'platform' => $this->platform,
            'device_model' => $this->device_model,
            'app_version' => $this->app_version,
            'last_seen_at' => $this->date($this->last_seen_at),
        ];
    }
}
