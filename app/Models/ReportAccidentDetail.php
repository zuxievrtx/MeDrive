<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ReportAccidentDetail extends Model
{
    public $timestamps = false;

    public $incrementing = false;

    protected $primaryKey = 'report_id';

    protected $fillable = ['report_id', 'accident_type', 'estimated_victim_count', 'has_trapped_victim', 'has_fire_hazard', 'is_road_blocked'];

    protected function casts(): array
    {
        return [
            'estimated_victim_count' => 'integer',
            'has_trapped_victim' => 'boolean',
            'has_fire_hazard' => 'boolean',
            'is_road_blocked' => 'boolean',
        ];
    }

    /**
     * @return BelongsTo<Report, $this>
     */
    public function report(): BelongsTo
    {
        return $this->belongsTo(Report::class);
    }
}
