<?php

namespace App\Models;

use App\Enums\LicenseClass;
use Database\Factories\DriverProfileFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DriverProfile extends Model
{
    /** @use HasFactory<DriverProfileFactory> */
    use HasFactory;

    protected $fillable = [
        'user_id',
        'clinic_id',
        'employee_number',
        'license_number',
        'license_class',
        'license_expires_at',
        'photo_path',
        'created_by',
    ];

    protected function casts(): array
    {
        return [
            'license_class' => LicenseClass::class,
            'license_expires_at' => 'date',
            'is_on_duty' => 'boolean',
        ];
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * @return BelongsTo<Clinic, $this>
     */
    public function clinic(): BelongsTo
    {
        return $this->belongsTo(Clinic::class);
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
