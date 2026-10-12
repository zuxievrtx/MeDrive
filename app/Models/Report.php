<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Report extends Model
{
    protected $fillable = ['reporter_id', 'latitude', 'longitude', 'victim_count', 'description', 'photo_path'];

    protected function casts(): array
    {
        return [
            'latitude'     => 'decimal:7',
            'longitude'    => 'decimal:7',
            'victim_count' => 'integer',
            'taken_at'     => 'datetime',
            'completed_at' => 'datetime',
        ];
    }

    public function reporter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reporter_id');
    }

    public function driver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'driver_id');
    }
}
