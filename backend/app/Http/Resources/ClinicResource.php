<?php

namespace App\Http\Resources;

use App\Models\Clinic;
use Illuminate\Http\Request;

/** @mixin Clinic */
class ClinicResource extends ApiResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'code' => $this->code,
            'name' => $this->name,
            'type' => $this->enum($this->type),
            'phone' => $this->phone,
            'address' => $this->address,
            'latitude' => $this->latitude !== null ? (float) $this->latitude : null,
            'longitude' => $this->longitude !== null ? (float) $this->longitude : null,
            'is_active' => (bool) $this->is_active,
            'institution_id' => $this->institution_id,
            'institution' => InstitutionResource::make($this->whenLoaded('institution')),
            'driver_profiles_count' => $this->whenCounted('driverProfiles'),
            'ambulances_count' => $this->whenCounted('ambulances'),
        ];
    }
}
