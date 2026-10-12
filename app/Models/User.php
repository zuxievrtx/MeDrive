<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $fillable = ['name', 'phone', 'email', 'password', 'role', 'fcm_token'];

    protected $hidden = ['password', 'fcm_token'];

    protected function casts(): array
    {
        return ['password' => 'hashed'];
    }

    /** users (driver) 1 — 1 driver_profiles */
    public function driverProfile(): HasOne
    {
        return $this->hasOne(DriverProfile::class);
    }

    /** users (pelapor) 1 — 0..n reports */
    public function reportsMade(): HasMany
    {
        return $this->hasMany(Report::class, 'reporter_id');
    }

    /** users (driver) 1 — 0..n reports */
    public function reportsTaken(): HasMany
    {
        return $this->hasMany(Report::class, 'driver_id');
    }

    public function isDriver(): bool
    {
        return $this->role === 'driver';
    }
}
