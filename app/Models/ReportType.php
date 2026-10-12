<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ReportType extends Model
{
    public $timestamps = false;

    protected $fillable = ['name', 'description', 'priority', 'icon', 'color', 'is_active', 'sort_order'];

    protected function casts(): array
    {
        return [
            'priority' => 'integer',
            'is_emergency' => 'boolean',
            'requires_destination' => 'boolean',
            'is_active' => 'boolean',
            'sort_order' => 'integer',
        ];
    }

    /**
     * @return HasMany<Report, $this>
     */
    public function reports(): HasMany
    {
        return $this->hasMany(Report::class);
    }

    /**
     * @return BelongsToMany<AmbulanceType, $this>
     */
    public function ambulanceTypes(): BelongsToMany
    {
        return $this->belongsToMany(AmbulanceType::class, 'report_type_ambulance_types');
    }
}
