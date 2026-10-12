<?php

namespace App\Models;

use App\Enums\DispatchResponse;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ReportDispatch extends Model
{
    public $timestamps = false;

    protected $fillable = ['report_id', 'driver_id', 'shift_id', 'distance_km', 'sent_at', 'opened_at', 'response', 'responded_at'];

    protected function casts(): array
    {
        return [
            'distance_km' => 'decimal:2',
            'sent_at' => 'datetime',
            'opened_at' => 'datetime',
            'responded_at' => 'datetime',
            'response' => DispatchResponse::class,
        ];
    }

    /**
     * @return BelongsTo<Report, $this>
     */
    public function report(): BelongsTo
    {
        return $this->belongsTo(Report::class);
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
