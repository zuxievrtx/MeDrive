<?php

namespace App\Models;

use App\Enums\AccountStatus;
use App\Enums\UserRole;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'phone',
        'email',
        'password',
        'role',
        'account_status',
        'must_change_password',
        'last_login_at',
    ];

    protected $hidden = ['password', 'remember_token'];

    protected function casts(): array
    {
        return [
            'password' => 'hashed',
            'role' => UserRole::class,
            'account_status' => AccountStatus::class,
            'must_change_password' => 'boolean',
            'last_login_at' => 'datetime',
        ];
    }

    public function isAdmin(): bool
    {
        return $this->role === UserRole::Admin;
    }

    public function isDriver(): bool
    {
        return $this->role === UserRole::Driver;
    }

    public function isActive(): bool
    {
        return $this->account_status === AccountStatus::Aktif;
    }

    public function initials(): string
    {
        return collect(preg_split('/\s+/', trim($this->name)))
            ->filter()
            ->take(2)
            ->map(fn (string $part): string => mb_strtoupper(mb_substr($part, 0, 1)))
            ->implode('');
    }

    /**
     * @param  Builder<User>  $query
     */
    public function scopeDrivers(Builder $query): void
    {
        $query->where('role', UserRole::Driver);
    }

    /**
     * @param  Builder<User>  $query
     */
    public function scopeReporters(Builder $query): void
    {
        $query->where('role', UserRole::Pelapor);
    }

    /**
     * @return HasOne<DriverProfile, $this>
     */
    public function driverProfile(): HasOne
    {
        return $this->hasOne(DriverProfile::class);
    }

    /**
     * @return HasMany<UserDevice, $this>
     */
    public function devices(): HasMany
    {
        return $this->hasMany(UserDevice::class);
    }

    /**
     * @return HasMany<DriverCertification, $this>
     */
    public function certifications(): HasMany
    {
        return $this->hasMany(DriverCertification::class, 'driver_id');
    }

    /**
     * @return HasMany<DriverShift, $this>
     */
    public function shifts(): HasMany
    {
        return $this->hasMany(DriverShift::class, 'driver_id');
    }

    /**
     * Shift yang masih terbuka (driver berstatus "Aktif").
     *
     * @return HasOne<DriverShift, $this>
     */
    public function openShift(): HasOne
    {
        return $this->hasOne(DriverShift::class, 'driver_id')->whereNull('ended_at');
    }

    /**
     * @return HasOne<DriverLastLocation, $this>
     */
    public function lastLocation(): HasOne
    {
        return $this->hasOne(DriverLastLocation::class, 'driver_id');
    }

    /**
     * @return HasMany<Report, $this>
     */
    public function reportsMade(): HasMany
    {
        return $this->hasMany(Report::class, 'reporter_id');
    }

    /**
     * @return HasMany<Report, $this>
     */
    public function reportsTaken(): HasMany
    {
        return $this->hasMany(Report::class, 'driver_id');
    }

    /**
     * @return HasMany<ReportDispatch, $this>
     */
    public function dispatches(): HasMany
    {
        return $this->hasMany(ReportDispatch::class, 'driver_id');
    }
}
