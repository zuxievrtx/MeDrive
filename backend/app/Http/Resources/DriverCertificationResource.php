<?php

namespace App\Http\Resources;

use App\Models\DriverCertification;
use Illuminate\Http\Request;

/** @mixin DriverCertification */
class DriverCertificationResource extends ApiResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'driver_id' => $this->driver_id,
            'name' => $this->name,
            'certificate_number' => $this->certificate_number,
            'issuer' => $this->issuer,
            'issued_at' => $this->day($this->issued_at),
            'expires_at' => $this->day($this->expires_at),
            'expiry_state' => match (true) {
                $this->expires_at === null => 'lifetime',
                $this->expires_at->lt(today()) => 'expired',
                $this->expires_at->lte(today()->addDays(config('medrive.expiry_warning_days'))) => 'expiring',
                default => 'valid',
            },
            'file_url' => $this->file_path ? route('api.v1.media', ['type' => 'certification', 'id' => $this->id]) : null,
        ];
    }
}
