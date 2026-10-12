<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class AmbulanceType extends Model
{
    public $timestamps = false;

    protected $fillable = ['name', 'description'];

    /**
     * Ikon Font Awesome untuk marker peta, dipetakan dari kode jenis (config/medrive.php).
     */
    public function mapIcon(): string
    {
        return config('medrive.ambulance_type_icons.'.$this->code, config('medrive.ambulance_type_icons.default'));
    }

    /**
     * @return HasMany<Ambulance, $this>
     */
    public function ambulances(): HasMany
    {
        return $this->hasMany(Ambulance::class);
    }

    /**
     * @return BelongsToMany<ReportType, $this>
     */
    public function reportTypes(): BelongsToMany
    {
        return $this->belongsToMany(ReportType::class, 'report_type_ambulance_types');
    }
}
