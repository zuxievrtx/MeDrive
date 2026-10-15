<?php

namespace App\Services;

use App\Enums\AccountStatus;
use App\Enums\DispatchResponse;
use App\Enums\ReportStatus;
use App\Enums\UserRole;
use App\Events\DispatchEscalated;
use App\Events\ReportStatusChanged;
use App\Exceptions\ApiException;
use App\Models\DriverLastLocation;
use App\Models\DriverProfile;
use App\Models\DriverShift;
use App\Models\Report;
use App\Models\ReportDispatch;
use App\Models\ReportStatusLog;
use App\Models\User;
use App\Support\Geo;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

/**
 * Broadcast laporan ke ambulans terdekat lebih dulu, lalu radius diperluas per ronde.
 * Pengambilan laporan memakai UPDATE bersyarat sehingga hanya satu driver yang menang.
 */
class DispatchService
{
    public function __construct(private FcmService $fcm, private DispatchState $state) {}

    public function totalRounds(): int
    {
        return count(config('medrive.dispatch.radius_rounds_km'));
    }

    public function radiusForRound(int $round): ?float
    {
        $radius = config('medrive.dispatch.radius_rounds_km')[$round - 1] ?? null;

        return $radius === null ? null : (float) $radius;
    }

    /**
     * Driver yang berhak menerima broadcast: shift terbuka, akun aktif, tidak sedang bertugas,
     * dan jenis ambulansnya boleh melayani jenis laporan. Diurutkan dari yang terdekat.
     * Posisi = lokasi terakhir selama shift ini; bila belum ada ping, dipakai lokasi klinik.
     *
     * @param  list<int>  $excludeDriverIds
     * @return Collection<int, object{driver_id: int, shift_id: int, distance_km: float}>
     */
    public function candidates(Report $report, array $excludeDriverIds = []): Collection
    {
        $ambulanceTypeIds = DB::table('report_type_ambulance_types')
            ->where('report_type_id', $report->report_type_id)
            ->pluck('ambulance_type_id');

        if ($ambulanceTypeIds->isEmpty()) {
            return collect();
        }

        return DB::table('driver_shifts as shifts')
            ->join('users', 'users.id', '=', 'shifts.driver_id')
            ->join('driver_profiles as profiles', 'profiles.user_id', '=', 'users.id')
            ->join('clinics', 'clinics.id', '=', 'profiles.clinic_id')
            ->join('ambulances', 'ambulances.id', '=', 'shifts.ambulance_id')
            ->leftJoin('driver_last_locations as locations', function ($join): void {
                $join->on('locations.driver_id', '=', 'users.id')->whereColumn('locations.recorded_at', '>=', 'shifts.started_at');
            })
            ->whereNull('shifts.ended_at')
            ->where('users.role', UserRole::Driver->value)
            ->where('users.account_status', AccountStatus::Aktif->value)
            ->where('profiles.is_on_duty', false)
            ->whereIn('ambulances.ambulance_type_id', $ambulanceTypeIds)
            ->when($excludeDriverIds !== [], fn ($query) => $query->whereNotIn('users.id', $excludeDriverIds))
            ->get([
                'users.id as driver_id',
                'shifts.id as shift_id',
                'locations.latitude as latitude',
                'locations.longitude as longitude',
                'clinics.latitude as clinic_latitude',
                'clinics.longitude as clinic_longitude',
            ])
            ->map(function (object $row) use ($report): object {
                $latitude = (float) ($row->latitude ?? $row->clinic_latitude);
                $longitude = (float) ($row->longitude ?? $row->clinic_longitude);

                return (object) [
                    'driver_id' => (int) $row->driver_id,
                    'shift_id' => (int) $row->shift_id,
                    'distance_km' => round(Geo::distanceKm((float) $report->latitude, (float) $report->longitude, $latitude, $longitude), 2),
                ];
            })
            ->sortBy('distance_km')
            ->values();
    }

    /**
     * Ronde pertama setelah laporan dibuat. Bila tidak ada kandidat dalam radius, langsung eskalasi.
     */
    public function startDispatch(Report $report): void
    {
        $this->advance($report, 1);
    }

    /**
     * Jalankan ronde mulai $round; ronde tanpa penerima langsung naik ke ronde berikutnya.
     * Setiap ronde >= 2 mengirim peringatan eskalasi ke admin; ronde terakhir tanpa penerima memicu alarm.
     */
    public function advance(Report $report, int $round): void
    {
        $total = $this->totalRounds();

        for (; $round <= $total; $round++) {
            $recipients = $this->dispatchRound($report, $round);

            if ($round > 1) {
                DispatchEscalated::dispatch($report, $round, $this->radiusForRound($round), $recipients, $round === $total && $recipients === 0);
            }

            if ($recipients > 0) {
                return;
            }
        }

        $this->state->markAlarmed($report->id);
    }

    /**
     * Kirim broadcast satu ronde ke driver yang belum pernah menerima laporan ini.
     */
    public function dispatchRound(Report $report, int $round): int
    {
        $radius = $this->radiusForRound($round);
        $alreadySent = ReportDispatch::query()->where('report_id', $report->id)->pluck('driver_id')->all();

        $recipients = $this->candidates($report, $alreadySent)
            ->when($radius !== null, fn (Collection $candidates) => $candidates->filter(fn (object $candidate) => $candidate->distance_km <= $radius))
            ->values();

        $now = now();

        // UNIQUE (report_id, driver_id) dijaga insertOrIgnore bila dua proses eskalasi berjalan bersamaan.
        $inserted = $recipients->isEmpty() ? 0 : ReportDispatch::query()->insertOrIgnore($recipients->map(fn (object $candidate): array => [
            'report_id' => $report->id,
            'driver_id' => $candidate->driver_id,
            'shift_id' => $candidate->shift_id,
            'distance_km' => min($candidate->distance_km, 9999.99),
            'sent_at' => $now,
            'response' => DispatchResponse::Menunggu->value,
        ])->all());

        $this->state->startRound($report->id, $round);

        if ($inserted > 0) {
            $this->notifyDrivers($report, $recipients);
        }

        return $recipients->count();
    }

    /**
     * Ambil laporan secara atomik (first-come-first-served).
     */
    public function accept(ReportDispatch $dispatch, User $driver): Report
    {
        if ($dispatch->driver_id !== $driver->id) {
            throw ApiException::forbidden('not_your_dispatch', 'Tawaran ini bukan untuk akun Anda.');
        }

        $shift = DriverShift::query()->open()->where('driver_id', $driver->id)->first();

        if (! $shift) {
            throw ApiException::conflict('no_open_shift', 'Buka shift terlebih dahulu untuk mengambil laporan.');
        }

        $report = $dispatch->report;

        if ($report->status === ReportStatus::Menunggu && $dispatch->response === DispatchResponse::Kedaluwarsa) {
            throw ApiException::conflict('offer_expired', 'Tawaran ini sudah kedaluwarsa karena broadcast diperluas ke ambulans lain.');
        }

        $outcome = DB::transaction(function () use ($dispatch, $driver, $shift, $report): string {
            // Klaim driver dulu agar satu driver tidak bisa memenangkan dua laporan sekaligus.
            $claimed = DriverProfile::query()->where('user_id', $driver->id)->where('is_on_duty', false)->update(['is_on_duty' => true]);

            if ($claimed === 0) {
                return 'on_duty';
            }

            $taken = Report::query()
                ->whereKey($report->id)
                ->where('status', ReportStatus::Menunggu->value)
                ->update([
                    'driver_id' => $driver->id,
                    'ambulance_id' => $shift->ambulance_id,
                    'status' => ReportStatus::Diambil->value,
                    'taken_at' => now(),
                    'updated_at' => now(),
                ]);

            if ($taken === 0) {
                DriverProfile::query()->where('user_id', $driver->id)->update(['is_on_duty' => false]);
                $dispatch->forceFill(['response' => DispatchResponse::KalahCepat, 'responded_at' => now(), 'opened_at' => $dispatch->opened_at ?? now()])->save();

                return 'too_late';
            }

            $dispatch->forceFill(['response' => DispatchResponse::Diambil, 'responded_at' => now(), 'opened_at' => $dispatch->opened_at ?? now()])->save();

            $location = DriverLastLocation::query()->find($driver->id);

            ReportStatusLog::create([
                'report_id' => $report->id,
                'from_status' => ReportStatus::Menunggu,
                'to_status' => ReportStatus::Diambil,
                'changed_by' => $driver->id,
                'latitude' => $location?->latitude,
                'longitude' => $location?->longitude,
            ]);

            return 'won';
        });

        return match ($outcome) {
            'on_duty' => throw ApiException::conflict('already_on_duty', 'Anda masih menangani laporan lain.'),
            'too_late' => throw ApiException::conflict('too_late', 'Laporan sudah diambil driver lain.'),
            default => $this->afterTaken($report->fresh()),
        };
    }

    public function markOpened(ReportDispatch $dispatch): void
    {
        if ($dispatch->opened_at === null) {
            $dispatch->forceFill(['opened_at' => now()])->save();
        }
    }

    private function afterTaken(Report $report): Report
    {
        $this->state->forget($report->id);

        ReportStatusChanged::dispatch($report, ReportStatus::Menunggu->value);

        $this->fcm->queueForUser($report->reporter_id, 'Ambulans menuju lokasi Anda', "Laporan {$report->code} sudah diambil driver.", [
            'type' => 'report_status',
            'report_id' => $report->id,
            'report_code' => $report->code,
            'status' => $report->status->value,
        ]);

        return $report;
    }

    /**
     * @param  Collection<int, object{driver_id: int, shift_id: int, distance_km: float}>  $recipients
     */
    private function notifyDrivers(Report $report, Collection $recipients): void
    {
        $report->loadMissing('reportType');
        $dispatchIds = ReportDispatch::query()->where('report_id', $report->id)->pluck('id', 'driver_id');

        foreach ($recipients as $candidate) {
            $distance = number_format($candidate->distance_km, 1, ',', '.');

            $this->fcm->queueForUser($candidate->driver_id, "Laporan darurat: {$report->reportType->name}", "Anda {$distance} km dari lokasi. {$report->shortAddress(60)}", [
                'type' => 'dispatch',
                'dispatch_id' => $dispatchIds[$candidate->driver_id] ?? null,
                'report_id' => $report->id,
                'report_code' => $report->code,
                'report_type' => $report->reportType->code,
                'distance_km' => $candidate->distance_km,
                'priority' => $report->reportType->priority,
            ]);
        }
    }
}
