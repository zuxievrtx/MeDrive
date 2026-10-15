<?php

namespace App\Http\Resources;

use App\Models\DriverShift;
use Illuminate\Http\Request;

/** @mixin DriverShift */
class DriverShiftResource extends ApiResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'driver_id' => $this->driver_id,
            'started_at' => $this->date($this->started_at),
            'ended_at' => $this->date($this->ended_at),
            'end_reason' => $this->enum($this->end_reason),
            'is_open' => $this->isOpen(),
            'ambulance' => AmbulanceResource::make($this->whenLoaded('ambulance')),
            'driver' => $this->whenLoaded('driver', fn (): array => ['id' => $this->driver->id, 'name' => $this->driver->name]),
        ];
    }
}
