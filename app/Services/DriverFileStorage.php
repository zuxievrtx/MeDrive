<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

/**
 * Berkas driver (foto, sertifikat) disimpan di disk privat dan hanya diakses lewat route ber-otorisasi.
 */
class DriverFileStorage
{
    /** @var list<string> */
    private array $stored = [];

    public function storePhoto(int $driverId, UploadedFile $file): string
    {
        return $this->remember($file->store("drivers/{$driverId}/photo", 'local'));
    }

    public function storeCertification(int $driverId, UploadedFile $file): string
    {
        return $this->remember($file->store("drivers/{$driverId}/certifications", 'local'));
    }

    public function delete(?string $path): void
    {
        if ($path) {
            Storage::disk('local')->delete($path);
        }
    }

    /**
     * Hapus berkas yang sudah tersimpan bila transaksi database gagal.
     */
    public function rollback(): void
    {
        Storage::disk('local')->delete($this->stored);
        $this->stored = [];
    }

    private function remember(string|false $path): string
    {
        if ($path === false) {
            throw new \RuntimeException('Berkas gagal disimpan.');
        }

        $this->stored[] = $path;

        return $path;
    }
}
