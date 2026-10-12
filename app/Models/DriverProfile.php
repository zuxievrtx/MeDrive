<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DriverProfile extends Model
{
    public $timestamps = false;

    protected $fillable = ['user_id', 'plate_number', 'is_active', 'is_on_duty', 'last_lat', 'last_lng', 'last_location_at'];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'is_on_duty' => 'boolean',
            'last_lat' => 'decimal:7',
            'last_lng' => 'decimal:7',
            'last_location_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
