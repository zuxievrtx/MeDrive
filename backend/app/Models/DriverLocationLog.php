<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\MassPrunable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DriverLocationLog extends Model
{
    use MassPrunable;

    public $timestamps = false;

    protected $fillable = [
        'driver_id',
        'shift_id',
        'report_id',
        'latitude',
        'longitude',
        'accuracy_m',
        'altitude_m',
        'speed_kmh',
        'heading',
        'battery_level',
        'provider',
        'is_mock_location',
        'recorded_at',
        'received_at',
    ];

    protected function casts(): array
    {
        return [
            'latitude' => 'decimal:7',
            'longitude' => 'decimal:7',
            'accuracy_m' => 'decimal:1',
            'altitude_m' => 'decimal:1',
            'speed_kmh' => 'decimal:1',
            'heading' => 'integer',
            'battery_level' => 'integer',
            'is_mock_location' => 'boolean',
            'recorded_at' => 'datetime',
            'received_at' => 'datetime',
        ];
    }

    /**
     * Retensi log detail 14 hari (model:prune tiap malam). Memakai received_at karena kolom itu punya index sendiri (idx_dlog_received).
     *
     * @return Builder<DriverLocationLog>
     */
    public function prunable(): Builder
    {
        return static::query()->where('received_at', '<', now()->subDays((int) config('medrive.location_log_retention_days')));
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

    /**
     * @return BelongsTo<Report, $this>
     */
    public function report(): BelongsTo
    {
        return $this->belongsTo(Report::class);
    }
}
