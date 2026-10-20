<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ReportMedicalDetail extends Model
{
    public $timestamps = false;

    public $incrementing = false;

    protected $primaryKey = 'report_id';

    protected $fillable = ['report_id', 'medical_category', 'symptom_onset_at', 'has_medical_history', 'medical_history_notes'];

    protected function casts(): array
    {
        return [
            'symptom_onset_at' => 'datetime',
            'has_medical_history' => 'boolean',
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
