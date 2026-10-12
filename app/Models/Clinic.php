<?php

namespace App\Models;

use App\Enums\ClinicType;
use Database\Factories\ClinicFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Clinic extends Model
{
    /** @use HasFactory<ClinicFactory> */
    use HasFactory;

    protected $fillable = ['institution_id', 'code', 'name', 'type', 'phone', 'address', 'latitude', 'longitude', 'is_active'];

    protected function casts(): array
    {
        return [
            'type' => ClinicType::class,
            'latitude' => 'decimal:7',
            'longitude' => 'decimal:7',
            'is_active' => 'boolean',
        ];
    }

    /**
     * Label dropdown "Klinik - Instansi".
     */
    public function labelWithInstitution(): string
    {
        return $this->name.' - '.$this->institution?->name;
    }

    /**
     * @return BelongsTo<Institution, $this>
     */
    public function institution(): BelongsTo
    {
        return $this->belongsTo(Institution::class);
    }

    /**
     * @return HasMany<DriverProfile, $this>
     */
    public function driverProfiles(): HasMany
    {
        return $this->hasMany(DriverProfile::class);
    }

    /**
     * @return HasMany<Ambulance, $this>
     */
    public function ambulances(): HasMany
    {
        return $this->hasMany(Ambulance::class);
    }
}
