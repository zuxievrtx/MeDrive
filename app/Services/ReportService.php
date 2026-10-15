<?php

namespace App\Services;

use App\Enums\ReportStatus;
use App\Events\ReportStatusChanged;
use App\Exceptions\ApiException;
use App\Models\Clinic;
use App\Models\DriverLastLocation;
use App\Models\DriverProfile;
use App\Models\Report;
use App\Models\ReportAttachment;
use App\Models\ReportPatient;
use App\Models\ReportStatusLog;
use App\Models\ReportType;
use App\Models\User;
use Illuminate\Database\UniqueConstraintViolationException;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Throwable;

/**
 * Siklus hidup laporan: dibuat pelapor, transisi status oleh driver, pembatalan oleh admin.
 */
class ReportService
{
    private const CODE_ATTEMPTS = 5;

    /**
     * Transisi yang boleh dilakukan driver dari setiap status.
     *
     * @var array<string, list<string>>
     */
    private const DRIVER_TRANSITIONS = [
        'diambil' => ['dalam_perjalanan'],
        'dalam_perjalanan' => ['tiba_di_lokasi'],
        'tiba_di_lokasi' => ['mengantar_pasien', 'selesai'],
        'mengantar_pasien' => ['selesai'],
    ];

    public function __construct(private DispatchService $dispatch, private FcmService $fcm) {}

    /**
     * Buat laporan + satu baris detail sesuai jenis + log status + lampiran dalam satu transaksi,
     * lalu mulai broadcast ke ambulans terdekat.
     *
     * @param  array<string, mixed>  $data
     * @param  list<UploadedFile>  $photos
     */
    public function create(User $reporter, ReportType $type, array $data, array $photos = [], ?UploadedFile $deathCertificate = null): Report
    {
        $storedFiles = [];

        try {
            $report = $this->withUniqueCode(function (string $code) use ($reporter, $type, $data, $photos, $deathCertificate, &$storedFiles): Report {
                return DB::transaction(function () use ($code, $reporter, $type, $data, $photos, $deathCertificate, &$storedFiles): Report {
                    $destination = $this->resolveDestination($data);

                    $report = Report::create([
                        'code' => $code,
                        'report_type_id' => $type->id,
                        'reporter_id' => $reporter->id,
                        'latitude' => $data['latitude'],
                        'longitude' => $data['longitude'],
                        'address' => $data['address'] ?? null,
                        'description' => $data['description'],
                        ...$destination,
                    ]);

                    $this->createDetail($report, $type, $data);

                    ReportStatusLog::create([
                        'report_id' => $report->id,
                        'from_status' => null,
                        'to_status' => ReportStatus::Menunggu,
                        'changed_by' => $reporter->id,
                        'latitude' => $data['latitude'],
                        'longitude' => $data['longitude'],
                        'note' => 'Laporan dibuat',
                    ]);

                    foreach ($photos as $photo) {
                        $storedFiles[] = $this->storeAttachment($report, $reporter, $photo, 'foto_kejadian')->file_path;
                    }

                    if ($deathCertificate) {
                        $storedFiles[] = $this->storeAttachment($report, $reporter, $deathCertificate, 'surat_kematian')->file_path;
                    }

                    return $report;
                });
            });
        } catch (Throwable $exception) {
            Storage::disk('local')->delete($storedFiles);

            throw $exception;
        }

        // Status dan created_at memakai default kolom DB, jadi muat ulang sebelum dipakai.
        $report->refresh();
        $this->dispatch->startDispatch($report);

        return $report;
    }

    /**
     * Transisi status oleh driver yang menangani laporan.
     */
    public function transition(Report $report, User $driver, ReportStatus $to, ?float $latitude = null, ?float $longitude = null, ?string $note = null): Report
    {
        if ($report->driver_id !== $driver->id) {
            throw ApiException::forbidden('not_your_report', 'Laporan ini tidak sedang Anda tangani.');
        }

        $report->loadMissing('reportType');
        $from = $report->status;
        $allowed = self::DRIVER_TRANSITIONS[$from->value] ?? [];

        if (! in_array($to->value, $allowed, true)) {
            throw ApiException::conflict('invalid_transition', "Status {$from->label()} tidak bisa diubah menjadi {$to->label()}.", [
                'current_status' => $from->value,
                'allowed' => $allowed,
            ]);
        }

        if ($to === ReportStatus::Selesai && $from === ReportStatus::TibaDiLokasi && $report->reportType->requires_destination) {
            throw ApiException::unprocessable('destination_required', 'Jenis laporan ini wajib melewati status mengantar pasien sebelum selesai.');
        }

        if ($to === ReportStatus::Selesai && ! $report->patients()->whereNotNull('handed_over_to')->exists()) {
            throw ApiException::unprocessable('patient_handover_required', 'Isi minimal satu data pasien beserta serah terimanya sebelum menyelesaikan laporan.');
        }

        $location = $latitude === null ? DriverLastLocation::query()->find($driver->id) : null;

        DB::transaction(function () use ($report, $driver, $from, $to, $latitude, $longitude, $note, $location): void {
            $changes = ['status' => $to->value, 'updated_at' => now()];

            if ($to === ReportStatus::TibaDiLokasi) {
                $changes['arrived_at'] = now();
            }

            if ($to === ReportStatus::Selesai) {
                $changes['completed_at'] = now();
            }

            // Kondisi status lama mencegah transisi ganda saat aplikasi mengirim ulang permintaan.
            $updated = Report::query()->whereKey($report->id)->where('status', $from->value)->update($changes);

            if ($updated === 0) {
                throw ApiException::conflict('status_changed', 'Status laporan sudah berubah. Muat ulang data laporan.');
            }

            ReportStatusLog::create([
                'report_id' => $report->id,
                'from_status' => $from,
                'to_status' => $to,
                'changed_by' => $driver->id,
                'latitude' => $latitude ?? $location?->latitude,
                'longitude' => $longitude ?? $location?->longitude,
                'note' => $note,
            ]);

            if ($to === ReportStatus::Selesai) {
                DriverProfile::query()->where('user_id', $driver->id)->update(['is_on_duty' => false]);
            }
        });

        $report->refresh();

        ReportStatusChanged::dispatch($report, $from->value);

        $this->fcm->queueForUser($report->reporter_id, 'Status laporan '.$report->code, 'Status terbaru: '.$to->label().'.', [
            'type' => 'report_status',
            'report_id' => $report->id,
            'report_code' => $report->code,
            'status' => $to->value,
        ]);

        return $report;
    }

    /**
     * Admin hanya boleh membatalkan laporan menunggu. UPDATE bersyarat mencegah balapan dengan driver
     * yang menekan "ambil" di saat bersamaan (constraint DB: dibatalkan wajib taken_at NULL).
     */
    public function cancelByAdmin(Report $report, User $admin, string $reason, AdminLogger $logger): Report
    {
        $cancelled = DB::transaction(function () use ($report, $admin, $reason, $logger): bool {
            $updated = Report::query()
                ->whereKey($report->id)
                ->where('status', ReportStatus::Menunggu->value)
                ->whereNull('taken_at')
                ->update(['status' => ReportStatus::Dibatalkan->value, 'updated_at' => now()]);

            if ($updated !== 1) {
                return false;
            }

            ReportStatusLog::create([
                'report_id' => $report->id,
                'from_status' => ReportStatus::Menunggu,
                'to_status' => ReportStatus::Dibatalkan,
                'changed_by' => $admin->id,
                'note' => 'Dibatalkan admin: '.$reason,
            ]);

            $logger->log('report.cancelled', $report, "Membatalkan laporan {$report->code}: {$reason}");

            return true;
        });

        if (! $cancelled) {
            throw ApiException::conflict('report_not_cancellable', "Laporan {$report->code} sudah diambil driver atau sudah ditutup sehingga tidak bisa dibatalkan.");
        }

        $report->refresh();
        ReportStatusChanged::dispatch($report, ReportStatus::Menunggu->value);

        $this->fcm->queueForUser($report->reporter_id, 'Laporan dibatalkan', "Laporan {$report->code} dibatalkan admin pusat.", [
            'type' => 'report_status',
            'report_id' => $report->id,
            'report_code' => $report->code,
            'status' => ReportStatus::Dibatalkan->value,
        ]);

        return $report;
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function addPatient(Report $report, User $driver, array $data): ReportPatient
    {
        $this->ensureHandling($report, $driver);

        return $report->patients()->create($this->patientAttributes($data));
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function updatePatient(ReportPatient $patient, User $driver, array $data): ReportPatient
    {
        $this->ensureHandling($patient->report, $driver);

        $patient->update($this->patientAttributes($data, $patient));

        return $patient->refresh();
    }

    /**
     * @param  list<UploadedFile>  $photos
     * @return list<ReportAttachment>
     */
    public function addHandlingPhotos(Report $report, User $driver, array $photos): array
    {
        $this->ensureHandling($report, $driver);
        $stored = [];

        try {
            return DB::transaction(function () use ($report, $driver, $photos, &$stored): array {
                return array_map(function (UploadedFile $photo) use ($report, $driver, &$stored): ReportAttachment {
                    $attachment = $this->storeAttachment($report, $driver, $photo, 'foto_penanganan');
                    $stored[] = $attachment->file_path;

                    return $attachment;
                }, $photos);
            });
        } catch (Throwable $exception) {
            Storage::disk('local')->delete($stored);

            throw $exception;
        }
    }

    /**
     * Kode MDR-YYMMDD-NNNN: nomor berikutnya dari MAX hari ini; bila dua permintaan bersamaan
     * mendapat nomor sama, UNIQUE uq_reports_code menolak salah satunya dan transaksi diulang.
     *
     * @param  callable(string): Report  $create
     */
    private function withUniqueCode(callable $create): Report
    {
        for ($attempt = 1; ; $attempt++) {
            try {
                return $create($this->nextCode());
            } catch (UniqueConstraintViolationException $exception) {
                if ($attempt >= self::CODE_ATTEMPTS || ! str_contains($exception->getMessage(), 'code')) {
                    throw $exception;
                }

                usleep(random_int(5, 40) * 1000);
            }
        }
    }

    public function nextCode(): string
    {
        $prefix = 'MDR-'.now()->format('ymd').'-';
        $last = Report::query()->where('code', 'like', $prefix.'%')->max('code');
        $next = $last ? ((int) substr($last, strlen($prefix))) + 1 : 1;

        return $prefix.str_pad((string) $next, 4, '0', STR_PAD_LEFT);
    }

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    private function resolveDestination(array $data): array
    {
        $clinicId = $data['destination_clinic_id'] ?? null;

        if ($clinicId) {
            $clinic = Clinic::query()->findOrFail($clinicId);

            return [
                'destination_name' => $clinic->name,
                'destination_address' => $clinic->address,
                'destination_lat' => $clinic->latitude,
                'destination_lng' => $clinic->longitude,
            ];
        }

        return [
            'destination_name' => $data['destination_name'] ?? null,
            'destination_address' => $data['destination_address'] ?? null,
            'destination_lat' => $data['destination_lat'] ?? null,
            'destination_lng' => $data['destination_lng'] ?? null,
        ];
    }

    /**
     * @param  array<string, mixed>  $data
     */
    private function createDetail(Report $report, ReportType $type, array $data): void
    {
        $detail = $data['details'] ?? [];

        match ($type->detailKind()) {
            'accident' => $report->accidentDetail()->create([
                'accident_type' => $detail['accident_type'],
                'estimated_victim_count' => $detail['estimated_victim_count'] ?? 1,
                'has_trapped_victim' => (bool) ($detail['has_trapped_victim'] ?? false),
                'has_fire_hazard' => (bool) ($detail['has_fire_hazard'] ?? false),
                'is_road_blocked' => (bool) ($detail['is_road_blocked'] ?? false),
            ]),
            'medical' => $report->medicalDetail()->create([
                'medical_category' => $detail['medical_category'],
                'symptom_onset_at' => $detail['symptom_onset_at'] ?? null,
                'has_medical_history' => (bool) ($detail['has_medical_history'] ?? false),
                'medical_history_notes' => $detail['medical_history_notes'] ?? null,
            ]),
            'maternity' => $report->maternityDetail()->create([
                'gestational_age_weeks' => $detail['gestational_age_weeks'] ?? null,
                'contraction_interval_minutes' => $detail['contraction_interval_minutes'] ?? null,
                'is_water_broken' => (bool) ($detail['is_water_broken'] ?? false),
                'has_bleeding' => (bool) ($detail['has_bleeding'] ?? false),
                'pregnancy_number' => $detail['pregnancy_number'] ?? null,
                'destination_clinic_id' => $data['destination_clinic_id'] ?? null,
            ]),
            'funeral' => $report->funeralDetail()->create([
                'deceased_name' => $detail['deceased_name'],
                'pickup_place_type' => $detail['pickup_place_type'],
                'scheduled_pickup_at' => $detail['scheduled_pickup_at'] ?? null,
                'has_death_certificate' => (bool) ($detail['has_death_certificate'] ?? false),
                'family_contact_name' => $detail['family_contact_name'],
                'family_contact_phone' => $detail['family_contact_phone'],
            ]),
            default => null,
        };
    }

    private function storeAttachment(Report $report, User $uploader, UploadedFile $file, string $type): ReportAttachment
    {
        $path = $file->store('reports/'.now()->format('Y/m').'/'.$report->id, 'local');

        return $report->attachments()->create([
            'uploaded_by' => $uploader->id,
            'type' => $type,
            'file_path' => $path,
            'mime_type' => $file->getMimeType() ?? 'application/octet-stream',
            'size_kb' => (int) ceil($file->getSize() / 1024),
        ]);
    }

    private function ensureHandling(Report $report, User $driver): void
    {
        if ($report->driver_id !== $driver->id) {
            throw ApiException::forbidden('not_your_report', 'Laporan ini tidak sedang Anda tangani.');
        }

        if (! in_array($report->status, ReportStatus::active(), true)) {
            throw ApiException::conflict('report_not_active', 'Data laporan hanya bisa dilengkapi selama laporan masih berjalan.');
        }
    }

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    private function patientAttributes(array $data, ?ReportPatient $existing = null): array
    {
        if (filled($data['handed_over_to'] ?? null) && empty($data['handed_over_at']) && ! $existing?->handed_over_at) {
            $data['handed_over_at'] = now();
        }

        return collect($data)->only([
            'name', 'gender', 'age_estimate', 'consciousness', 'is_breathing',
            'condition_note', 'handed_over_to', 'handed_over_at',
        ])->all();
    }
}
