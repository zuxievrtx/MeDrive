<?php

namespace App\Models;

use App\Enums\AmbulanceStatus;
use Database\Factories\AmbulanceFactory;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Ambulance extends Model
{
    /** @use HasFactory<AmbulanceFactory> */
    use HasFactory;

    protected $fillable = ['clinic_id', 'ambulance_type_id', 'plate_number', 'vehicle_name', 'year', 'status', 'notes'];

    protected function casts(): array
    {
        return [
            'status' => AmbulanceStatus::class,
            'year' => 'integer',
        ];
    }

    /**
     * Nomor polisi selalu disimpan huruf besar.
     */
    protected function plateNumber(): Attribute
    {
        return Attribute::make(
            set: fn (string $value): string => mb_strtoupper(preg_replace('/\s+/', ' ', trim($value))),
        );
    }

    /**
     * Sedang dipakai = punya shift terbuka.
     */
    protected function inUse(): Attribute
    {
        return Attribute::make(get: fn (): bool => $this->openShift !== null);
    }

    /**
     * @return BelongsTo<Clinic, $this>
     */
    public function clinic(): BelongsTo
    {
        return $this->belongsTo(Clinic::class);
    }

    /**
     * @return BelongsTo<AmbulanceType, $this>
     */
    public function ambulanceType(): BelongsTo
    {
        return $this->belongsTo(AmbulanceType::class);
    }

    /**
     * @return HasMany<DriverShift, $this>
     */
    public function shifts(): HasMany
    {
        return $this->hasMany(DriverShift::class);
    }

    /**
     * @return HasOne<DriverShift, $this>
     */
    public function openShift(): HasOne
    {
        return $this->hasOne(DriverShift::class)->whereNull('ended_at');
    }
}
