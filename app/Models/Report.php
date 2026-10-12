<?php

namespace App\Models;

use App\Enums\ReportStatus;
use App\Events\ReportCreated;
use Database\Factories\ReportFactory;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Support\Str;

class Report extends Model
{
    /** @use HasFactory<ReportFactory> */
    use HasFactory;

    protected $fillable = [
        'code',
        'report_type_id',
        'reporter_id',
        'latitude',
        'longitude',
        'address',
        'description',
        'destination_name',
        'destination_address',
        'destination_lat',
        'destination_lng',
    ];

    /**
     * Laporan baru dari aplikasi pelapor langsung dikabarkan ke dashboard admin.
     *
     * @var array<string, class-string>
     */
    protected $dispatchesEvents = [
        'created' => ReportCreated::class,
    ];

    protected function casts(): array
    {
        return [
            'status' => ReportStatus::class,
            'latitude' => 'decimal:7',
            'longitude' => 'decimal:7',
            'destination_lat' => 'decimal:7',
            'destination_lng' => 'decimal:7',
            'taken_at' => 'datetime',
            'arrived_at' => 'datetime',
            'completed_at' => 'datetime',
        ];
    }

    /**
     * Durasi respons (taken_at - created_at) dalam menit.
     */
    protected function responseTimeMinutes(): Attribute
    {
        return Attribute::make(
            get: fn (): ?float => $this->taken_at
                ? round($this->created_at->diffInSeconds($this->taken_at) / 60, 1)
                : null,
        );
    }

    public function shortAddress(int $limit = 48): string
    {
        return Str::limit($this->address ?? sprintf('%.5f, %.5f', $this->latitude, $this->longitude), $limit);
    }

    public function isCancellable(): bool
    {
        return $this->status === ReportStatus::Menunggu;
    }

    /**
     * @return BelongsTo<ReportType, $this>
     */
    public function reportType(): BelongsTo
    {
        return $this->belongsTo(ReportType::class);
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function reporter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reporter_id');
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function driver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'driver_id');
    }

    /**
     * @return BelongsTo<Ambulance, $this>
     */
    public function ambulance(): BelongsTo
    {
        return $this->belongsTo(Ambulance::class);
    }

    /**
     * @return HasOne<ReportAccidentDetail, $this>
     */
    public function accidentDetail(): HasOne
    {
        return $this->hasOne(ReportAccidentDetail::class);
    }

    /**
     * @return HasOne<ReportMedicalDetail, $this>
     */
    public function medicalDetail(): HasOne
    {
        return $this->hasOne(ReportMedicalDetail::class);
    }

    /**
     * @return HasOne<ReportMaternityDetail, $this>
     */
    public function maternityDetail(): HasOne
    {
        return $this->hasOne(ReportMaternityDetail::class);
    }

    /**
     * @return HasOne<ReportFuneralDetail, $this>
     */
    public function funeralDetail(): HasOne
    {
        return $this->hasOne(ReportFuneralDetail::class);
    }

    /**
     * @return HasMany<ReportPatient, $this>
     */
    public function patients(): HasMany
    {
        return $this->hasMany(ReportPatient::class);
    }

    /**
     * @return HasMany<ReportAttachment, $this>
     */
    public function attachments(): HasMany
    {
        return $this->hasMany(ReportAttachment::class);
    }

    /**
     * @return HasMany<ReportStatusLog, $this>
     */
    public function statusLogs(): HasMany
    {
        return $this->hasMany(ReportStatusLog::class);
    }

    /**
     * @return HasMany<ReportDispatch, $this>
     */
    public function dispatches(): HasMany
    {
        return $this->hasMany(ReportDispatch::class);
    }
}
