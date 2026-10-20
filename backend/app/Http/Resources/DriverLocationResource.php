<?php

namespace App\Http\Resources;

use App\Models\DriverLastLocation;
use Illuminate\Http\Request;

/** @mixin DriverLastLocation */
class DriverLocationResource extends ApiResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'latitude' => (float) $this->latitude,
            'longitude' => (float) $this->longitude,
            'accuracy_m' => $this->accuracy_m !== null ? (float) $this->accuracy_m : null,
            'speed_kmh' => $this->speed_kmh !== null ? (float) $this->speed_kmh : null,
            'heading' => $this->heading,
            'battery_level' => $this->battery_level,
            'is_mock_location' => (bool) $this->is_mock_location,
            'shift_id' => $this->shift_id,
            'recorded_at' => $this->date($this->recorded_at),
        ];
    }
}
