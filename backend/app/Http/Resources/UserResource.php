<?php

namespace App\Http\Resources;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

/** @mixin User */
class UserResource extends ApiResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'initials' => $this->initials(),
            'phone' => $this->phone,
            'email' => $this->email,
            'role' => $this->enum($this->role),
            'account_status' => $this->enum($this->account_status),
            'must_change_password' => (bool) $this->must_change_password,
            'last_login_at' => $this->date($this->last_login_at),
            'created_at' => $this->date($this->created_at),
            'driver_profile' => DriverProfileResource::make($this->whenLoaded('driverProfile')),
            'open_shift' => DriverShiftResource::make($this->whenLoaded('openShift')),
            'last_location' => DriverLocationResource::make($this->whenLoaded('lastLocation')),
            'devices' => DeviceResource::collection($this->whenLoaded('devices')),
            'devices_count' => $this->whenCounted('devices'),
            'reports_made_count' => $this->whenCounted('reportsMade'),
            'devices_last_seen_at' => $this->when(isset($this->devices_max_last_seen_at), fn () => $this->date(Carbon::parse($this->devices_max_last_seen_at))),
        ];
    }
}
