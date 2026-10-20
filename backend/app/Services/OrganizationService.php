<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Models\Clinic;
use App\Models\Institution;

/**
 * Instansi dan klinik. Penghapusan mengikuti FK RESTRICT ERD v3 dengan pesan yang ramah.
 */
class OrganizationService
{
    public function __construct(private AdminLogger $logger) {}

    /**
     * @param  array<string, mixed>  $data
     */
    public function createInstitution(array $data): Institution
    {
        $institution = Institution::create($data);
        $this->logger->log('institution.created', $institution, "Menambah instansi {$institution->name} ({$institution->code})");

        return $institution;
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function updateInstitution(Institution $institution, array $data): Institution
    {
        $institution->fill($data);
        $changes = AdminLogger::describeChanges($institution->getOriginal(), $institution->getDirty());
        $institution->save();

        $this->logger->log('institution.updated', $institution, "Mengubah instansi {$institution->name}: ".($changes ?: 'tanpa perubahan'));

        return $institution;
    }

    public function deleteInstitution(Institution $institution): void
    {
        $clinicCount = $institution->clinics()->count();

        if ($clinicCount > 0) {
            throw ApiException::conflict('institution_has_clinics', "Instansi {$institution->name} masih memiliki {$clinicCount} klinik sehingga tidak bisa dihapus. Nonaktifkan instansi bila sudah tidak dipakai.", ['suggestion' => 'deactivate']);
        }

        $this->logger->log('institution.deleted', $institution, "Menghapus instansi {$institution->name} ({$institution->code})");
        $institution->delete();
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function createClinic(array $data): Clinic
    {
        $clinic = Clinic::create($data);
        $this->logger->log('clinic.created', $clinic, "Menambah klinik {$clinic->name} ({$clinic->code})");

        return $clinic;
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function updateClinic(Clinic $clinic, array $data): Clinic
    {
        $clinic->fill($data);
        $changes = AdminLogger::describeChanges($clinic->getOriginal(), $clinic->getDirty());
        $clinic->save();

        $this->logger->log('clinic.updated', $clinic, "Mengubah klinik {$clinic->name}: ".($changes ?: 'tanpa perubahan'));

        return $clinic;
    }

    public function deleteClinic(Clinic $clinic): void
    {
        $driverCount = $clinic->driverProfiles()->count();
        $ambulanceCount = $clinic->ambulances()->count();

        if ($driverCount > 0 || $ambulanceCount > 0) {
            throw ApiException::conflict('clinic_in_use', "Klinik {$clinic->name} masih memiliki {$driverCount} driver dan {$ambulanceCount} ambulans sehingga tidak bisa dihapus. Pindahkan datanya atau nonaktifkan klinik.", ['suggestion' => 'deactivate']);
        }

        $this->logger->log('clinic.deleted', $clinic, "Menghapus klinik {$clinic->name} ({$clinic->code})");
        $clinic->delete();
    }
}
