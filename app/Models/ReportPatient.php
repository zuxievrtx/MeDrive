<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ReportPatient extends Model
{
    protected $fillable = [
        'report_id',
        'name',
        'gender',
        'age_estimate',
        'consciousness',
        'is_breathing',
        'condition_note',
        'handed_over_to',
        'handed_over_at',
    ];

    protected function casts(): array
    {
        return [
            'age_estimate' => 'integer',
            'is_breathing' => 'boolean',
            'handed_over_at' => 'datetime',
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
