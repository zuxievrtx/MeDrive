<?php

namespace App\Services;

use App\Enums\AmbulanceStatus;
use App\Enums\ShiftEndReason;
use App\Exceptions\ApiException;
use App\Models\Ambulance;
use App\Models\DriverShift;
use App\Models\User;
use Illuminate\Database\UniqueConstraintViolationException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * Shift driver. Driver "aktif" = punya shift terbuka. Tidak ada penutupan shift otomatis oleh sistem.
 */
class ShiftService
{
    public function open(User $driver, int $ambulanceId): DriverShift
    {
        $driver->loadMissing('driverProfile');

        if (DriverShift::query()->open()->where('driver_id', $driver->id)->exists()) {
            throw ApiException::conflict('shift_already_open', 'Anda masih memiliki shift terbuka. Tutup shift tersebut sebelum membuka shift baru.');
        }

        $ambulance = Ambulance::query()->with('openShift')->find($ambulanceId);

        if (! $ambulance || $ambulance->clinic_id !== $driver->driverProfile?->clinic_id) {
            throw ApiException::unprocessable('ambulance_not_allowed', 'Ambulans ini bukan milik klinik Anda.');
        }

        if ($ambulance->status !== AmbulanceStatus::Tersedia) {
            throw ApiException::conflict('ambulance_unavailable', "Ambulans {$ambulance->plate_number} sedang {$ambulance->status->label()}.");
        }

        if ($ambulance->openShift) {
            throw ApiException::conflict('ambulance_in_use', "Ambulans {$ambulance->plate_number} sedang dipakai driver lain.");
        }

        try {
            return DriverShift::create(['driver_id' => $driver->id, 'ambulance_id' => $ambulance->id, 'started_at' => now()])
                ->load('ambulance.ambulanceType');
        } catch (UniqueConstraintViolationException $exception) {
            // Kolom generated UNIQUE open_driver_id / open_ambulance_id menolak shift ganda yang lolos balapan.
            throw str_contains($exception->getMessage(), 'open_driver')
                ? ApiException::conflict('shift_already_open', 'Anda masih memiliki shift terbuka.')
                : ApiException::conflict('ambulance_in_use', "Ambulans {$ambulance->plate_number} baru saja dipakai driver lain.");
        }
    }

    /**
     * Driver menutup shift sendiri. Alasan singkat dicatat di log aplikasi karena driver_shifts v3
     * tidak punya kolom catatan.
     */
    public function close(User $driver, string $reason): DriverShift
    {
        $shift = DriverShift::query()->open()->where('driver_id', $driver->id)->with('ambulance')->first();

        if (! $shift) {
            throw ApiException::conflict('no_open_shift', 'Tidak ada shift terbuka yang bisa ditutup.');
        }

        if ($driver->driverProfile()->value('is_on_duty')) {
            throw ApiException::conflict('report_in_progress', 'Selesaikan laporan yang sedang ditangani sebelum menutup shift.');
        }

        $this->endShift($shift, ShiftEndReason::SelesaiShift);

        Log::info('Driver menutup shift', ['shift_id' => $shift->id, 'driver_id' => $driver->id, 'reason' => $reason]);

        return $shift->refresh();
    }

    /**
     * Admin mengakhiri shift terbuka. Laporan yang sedang ditangani tidak diubah.
     */
    public function endByAdmin(DriverShift $shift, AdminLogger $logger): DriverShift
    {
        $shift->loadMissing(['driver', 'ambulance']);

        if (! $shift->isOpen() || ! $this->endShift($shift, ShiftEndReason::DihentikanAdmin)) {
            throw ApiException::conflict('shift_already_closed', 'Shift ini sudah berakhir sebelumnya.');
        }

        $logger->log('shift.ended', $shift, "Mengakhiri shift {$shift->driver->name} ({$shift->ambulance->plate_number}) dengan alasan dihentikan admin");

        return $shift->refresh();
    }

    private function endShift(DriverShift $shift, ShiftEndReason $reason): bool
    {
        return DB::transaction(fn (): bool => DriverShift::query()
            ->whereKey($shift->id)
            ->whereNull('ended_at')
            ->update(['ended_at' => now(), 'end_reason' => $reason->value]) === 1);
    }
}
