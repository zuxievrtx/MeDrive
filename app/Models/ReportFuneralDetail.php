<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ReportFuneralDetail extends Model
{
    public $timestamps = false;

    public $incrementing = false;

    protected $primaryKey = 'report_id';

    protected $fillable = [
        'report_id',
        'deceased_name',
        'pickup_place_type',
        'scheduled_pickup_at',
        'has_death_certificate',
        'family_contact_name',
        'family_contact_phone',
    ];

    protected function casts(): array
    {
        return [
            'scheduled_pickup_at' => 'datetime',
            'has_death_certificate' => 'boolean',
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
