<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ReportMaternityDetail extends Model
{
    public $timestamps = false;

    public $incrementing = false;

    protected $primaryKey = 'report_id';

    protected $fillable = [
        'report_id',
        'gestational_age_weeks',
        'contraction_interval_minutes',
        'is_water_broken',
        'has_bleeding',
        'pregnancy_number',
        'destination_clinic_id',
    ];

    protected function casts(): array
    {
        return [
            'gestational_age_weeks' => 'integer',
            'contraction_interval_minutes' => 'integer',
            'is_water_broken' => 'boolean',
            'has_bleeding' => 'boolean',
            'pregnancy_number' => 'integer',
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
     * @return BelongsTo<Clinic, $this>
     */
    public function destinationClinic(): BelongsTo
    {
        return $this->belongsTo(Clinic::class, 'destination_clinic_id');
    }
}
