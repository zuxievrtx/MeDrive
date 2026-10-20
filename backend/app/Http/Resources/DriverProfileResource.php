<?php

namespace App\Http\Resources;

use App\Models\DriverProfile;
use Illuminate\Http\Request;

/** @mixin DriverProfile */
class DriverProfileResource extends ApiResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $warningLimit = today()->addDays(config('medrive.expiry_warning_days'));

        return [
            'clinic_id' => $this->clinic_id,
            'clinic' => ClinicResource::make($this->whenLoaded('clinic')),
            'employee_number' => $this->employee_number,
            'license_number' => $this->license_number,
            'license_class' => $this->enum($this->license_class),
            'license_expires_at' => $this->day($this->license_expires_at),
            'license_expiry_state' => match (true) {
                $this->license_expires_at->lt(today()) => 'expired',
                $this->license_expires_at->lte($warningLimit) => 'expiring',
                default => 'valid',
            },
            'photo_url' => $this->photo_path ? route('api.v1.media', ['type' => 'driver-photo', 'id' => $this->user_id]) : null,
            'is_on_duty' => (bool) $this->is_on_duty,
            'created_by' => $this->whenLoaded('creator', fn (): ?array => $this->creator ? ['id' => $this->creator->id, 'name' => $this->creator->name] : null),
            'created_at' => $this->date($this->created_at),
        ];
    }
}
