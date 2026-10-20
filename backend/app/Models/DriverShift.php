<?php

namespace App\Models;

use App\Enums\ShiftEndReason;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class DriverShift extends Model
{
    public $timestamps = false;

    protected $fillable = ['driver_id', 'ambulance_id', 'started_at', 'ended_at', 'end_reason'];

    protected function casts(): array
    {
        return [
            'started_at' => 'datetime',
            'ended_at' => 'datetime',
            'end_reason' => ShiftEndReason::class,
        ];
    }

    public function isOpen(): bool
    {
        return $this->ended_at === null;
    }

    /**
     * @param  Builder<DriverShift>  $query
     */
    public function scopeOpen(Builder $query): void
    {
        $query->whereNull('ended_at');
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function driver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'driver_id');
    }

    /**
     * @return BelongsTo<Ambulance, $this>
     */
    public function ambulance(): BelongsTo
    {
        return $this->belongsTo(Ambulance::class);
    }

    /**
     * @return HasMany<ReportDispatch, $this>
     */
    public function dispatches(): HasMany
    {
        return $this->hasMany(ReportDispatch::class, 'shift_id');
    }

    /**
     * @return HasMany<DriverLocationLog, $this>
     */
    public function locationLogs(): HasMany
    {
        return $this->hasMany(DriverLocationLog::class, 'shift_id');
    }
}
