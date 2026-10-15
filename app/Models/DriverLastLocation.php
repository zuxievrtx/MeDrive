<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DriverLastLocation extends Model
{
    public const CREATED_AT = null;

    public $incrementing = false;

    protected $primaryKey = 'driver_id';

    protected $fillable = ['driver_id', 'shift_id', 'latitude', 'longitude', 'accuracy_m', 'speed_kmh', 'heading', 'battery_level', 'is_mock_location', 'recorded_at'];

    protected function casts(): array
    {
        return [
            'latitude' => 'decimal:7',
            'longitude' => 'decimal:7',
            'accuracy_m' => 'decimal:1',
            'speed_kmh' => 'decimal:1',
            'heading' => 'integer',
            'battery_level' => 'integer',
            'is_mock_location' => 'boolean',
            'recorded_at' => 'datetime',
        ];
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function driver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'driver_id');
    }

    /**
     * @return BelongsTo<DriverShift, $this>
     */
    public function shift(): BelongsTo
    {
        return $this->belongsTo(DriverShift::class, 'shift_id');
    }
}
