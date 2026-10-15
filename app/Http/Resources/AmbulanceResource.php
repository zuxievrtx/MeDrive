<?php

namespace App\Http\Resources;

use App\Models\Ambulance;
use Illuminate\Http\Request;

/** @mixin Ambulance */
class AmbulanceResource extends ApiResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'plate_number' => $this->plate_number,
            'vehicle_name' => $this->vehicle_name,
            'year' => $this->year,
            'status' => $this->enum($this->status),
            'notes' => $this->notes,
            'clinic_id' => $this->clinic_id,
            'ambulance_type_id' => $this->ambulance_type_id,
            'clinic' => ClinicResource::make($this->whenLoaded('clinic')),
            'ambulance_type' => AmbulanceTypeResource::make($this->whenLoaded('ambulanceType')),
            'in_use' => $this->when($this->relationLoaded('openShift'), fn (): bool => $this->openShift !== null),
            'used_by' => $this->when(
                $this->relationLoaded('openShift') && $this->openShift?->relationLoaded('driver'),
                fn (): ?array => $this->openShift ? ['id' => $this->openShift->driver->id, 'name' => $this->openShift->driver->name] : null,
            ),
        ];
    }
}
