<?php

namespace App\Services;

use App\Enums\AmbulanceStatus;
use App\Exceptions\ApiException;
use App\Models\Ambulance;
use App\Models\AmbulanceType;
use App\Models\Report;

/**
 * Ambulans dan jenis ambulans.
 */
class FleetService
{
    public function __construct(private AdminLogger $logger) {}

    /**
     * @param  array<string, mixed>  $data
     */
    public function createAmbulance(array $data): Ambulance
    {
        $ambulance = Ambulance::create($data)->load('clinic');
        $this->logger->log('ambulance.created', $ambulance, "Menambah ambulans {$ambulance->plate_number} ({$ambulance->clinic->name})");

        return $ambulance;
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function updateAmbulance(Ambulance $ambulance, array $data): Ambulance
    {
        $this->guardInUse($ambulance, $data['status'], (int) $data['clinic_id']);

        $ambulance->fill($data);
        $statusChanged = $ambulance->isDirty('status');
        $changes = AdminLogger::describeChanges($ambulance->getOriginal(), $ambulance->getDirty());
        $ambulance->save();

        $this->logger->log(
            $statusChanged ? 'ambulance.status_changed' : 'ambulance.updated',
            $ambulance,
            "Mengubah ambulans {$ambulance->plate_number}: ".($changes ?: 'tanpa perubahan'),
        );

        return $ambulance;
    }

    public function changeStatus(Ambulance $ambulance, AmbulanceStatus $status): Ambulance
    {
        $this->guardInUse($ambulance, $status->value, $ambulance->clinic_id);

        $previous = $ambulance->status;
        $ambulance->update(['status' => $status]);

        $this->logger->log('ambulance.status_changed', $ambulance, "Status {$ambulance->plate_number} diubah dari {$previous->value} menjadi {$status->value}");

        return $ambulance;
    }

    public function deleteAmbulance(Ambulance $ambulance): void
    {
        if ($ambulance->shifts()->exists() || Report::query()->where('ambulance_id', $ambulance->id)->exists()) {
            throw ApiException::conflict('ambulance_has_history', "Ambulans {$ambulance->plate_number} sudah punya riwayat shift atau laporan sehingga tidak bisa dihapus. Ubah statusnya menjadi nonaktif.", ['suggestion' => 'deactivate']);
        }

        $this->logger->log('ambulance.deleted', $ambulance, "Menghapus ambulans {$ambulance->plate_number}");
        $ambulance->delete();
    }

    /**
     * @param  array{name: string, description?: ?string}  $data
     */
    public function updateType(AmbulanceType $type, array $data): AmbulanceType
    {
        $type->fill($data);
        $changes = AdminLogger::describeChanges($type->getOriginal(), $type->getDirty());
        $type->save();

        $this->logger->log('ambulance_type.updated', $type, "Mengubah jenis ambulans {$type->code}: ".($changes ?: 'tanpa perubahan'));

        return $type;
    }

    /**
     * Ambulans yang sedang dipakai shift terbuka tidak boleh dipindah klinik atau dikeluarkan dari status tersedia.
     */
    private function guardInUse(Ambulance $ambulance, string $status, int $clinicId): void
    {
        $ambulance->loadMissing('openShift.driver');

        if ($ambulance->in_use && ($status !== AmbulanceStatus::Tersedia->value || $clinicId !== $ambulance->clinic_id)) {
            throw ApiException::conflict('ambulance_in_use', "Ambulans {$ambulance->plate_number} sedang dipakai {$ambulance->openShift->driver->name}. Akhiri shift terlebih dahulu sebelum mengubah status atau klinik.");
        }
    }
}
