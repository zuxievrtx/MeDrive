<?php

namespace App\Services;

use App\Enums\AccountStatus;
use App\Enums\UserRole;
use App\Exceptions\ApiException;
use App\Models\Clinic;
use App\Models\DriverCertification;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Throwable;

/**
 * Akun driver hanya dibuat admin pusat: users (role driver) + driver_profiles (+ sertifikat) dalam satu transaksi.
 */
class DriverAccountService
{
    private const PASSWORD_ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';

    public function __construct(private DriverFileStorage $files, private AdminLogger $logger) {}

    /**
     * @param  array<string, mixed>  $data
     * @param  list<array{data: array<string, mixed>, file: ?UploadedFile}>  $certifications
     */
    public function create(array $data, ?UploadedFile $photo, array $certifications, User $admin): User
    {
        $clinic = Clinic::query()->findOrFail($data['clinic_id']);

        try {
            return DB::transaction(function () use ($data, $photo, $certifications, $admin, $clinic): User {
                $driver = User::create([
                    'name' => $data['name'],
                    'phone' => $data['phone'],
                    'email' => $data['email'],
                    'password' => $data['password'],
                    'role' => UserRole::Driver,
                    'account_status' => AccountStatus::Aktif,
                    'must_change_password' => $data['must_change_password'] ?? true,
                ]);

                $driver->driverProfile()->create([
                    'clinic_id' => $clinic->id,
                    'employee_number' => $data['employee_number'] ?? null,
                    'license_number' => $data['license_number'],
                    'license_class' => $data['license_class'],
                    'license_expires_at' => $data['license_expires_at'],
                    'photo_path' => $photo ? $this->files->storePhoto($driver->id, $photo) : null,
                    'created_by' => $admin->id,
                ]);

                $this->logger->log('driver.created', $driver, "Mendaftarkan driver {$driver->name} ({$clinic->name})");

                foreach ($certifications as $certification) {
                    $this->storeCertification($driver, $certification['data'], $certification['file']);
                }

                return $driver;
            });
        } catch (Throwable $exception) {
            $this->files->rollback();

            throw $exception;
        }
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function update(User $driver, array $data, ?UploadedFile $photo): User
    {
        $profile = $driver->driverProfile;
        $oldPhotoPath = $profile->photo_path;

        try {
            DB::transaction(function () use ($driver, $profile, $data, $photo): void {
                $driver->fill(collect($data)->only(['name', 'phone', 'email'])->all());
                $profile->fill(collect($data)->only(['clinic_id', 'employee_number', 'license_number', 'license_class', 'license_expires_at'])->all());

                $changes = array_filter([
                    AdminLogger::describeChanges($driver->getOriginal(), $driver->getDirty()),
                    AdminLogger::describeChanges($profile->getOriginal(), $profile->getDirty()),
                ]);

                if (filled($data['new_password'] ?? null)) {
                    $driver->password = $data['new_password'];
                    $driver->must_change_password = true;
                    $changes[] = 'password direset (wajib ganti saat login)';
                }

                if ($photo) {
                    $profile->photo_path = $this->files->storePhoto($driver->id, $photo);
                    $changes[] = 'foto diganti';
                }

                $driver->save();
                $profile->save();

                if (filled($data['new_password'] ?? null)) {
                    $driver->tokens()->delete();
                }

                $this->logger->log('driver.updated', $driver, "Mengubah data driver {$driver->name}: ".($changes ? implode('; ', $changes) : 'tanpa perubahan'));
            });
        } catch (Throwable $exception) {
            $this->files->rollback();

            throw $exception;
        }

        if ($photo) {
            $this->files->delete($oldPhotoPath);
        }

        return $driver->refresh();
    }

    /**
     * Reset password: pakai password dari admin atau buat acak, wajib ganti saat login, cabut semua token.
     */
    public function resetPassword(User $driver, ?string $password = null): string
    {
        $password = filled($password) ? $password : $this->generatePassword();

        DB::transaction(function () use ($driver, $password): void {
            $driver->forceFill(['password' => $password, 'must_change_password' => true])->save();
            $driver->tokens()->delete();
            $this->logger->log('driver.password_reset', $driver, "Mereset password driver {$driver->name}");
        });

        return $password;
    }

    /**
     * Driver dengan shift terbuka harus diakhiri shift-nya terlebih dahulu.
     */
    public function deactivate(User $driver): User
    {
        if (! $driver->isActive()) {
            return $driver;
        }

        if ($driver->openShift()->exists()) {
            throw ApiException::conflict('driver_has_open_shift', "{$driver->name} masih memiliki shift terbuka. Akhiri shift terlebih dahulu sebelum menonaktifkan akun.");
        }

        DB::transaction(function () use ($driver): void {
            $driver->forceFill(['account_status' => AccountStatus::Nonaktif])->save();
            $driver->tokens()->delete();
            $this->logger->log('driver.deactivated', $driver, "Menonaktifkan akun driver {$driver->name}");
        });

        return $driver;
    }

    public function activate(User $driver): User
    {
        if ($driver->isActive()) {
            return $driver;
        }

        $driver->forceFill(['account_status' => AccountStatus::Aktif])->save();
        $this->logger->log('driver.activated', $driver, "Mengaktifkan kembali akun driver {$driver->name}");

        return $driver;
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function addCertification(User $driver, array $data, ?UploadedFile $file): DriverCertification
    {
        try {
            return DB::transaction(fn (): DriverCertification => $this->storeCertification($driver, $data, $file));
        } catch (Throwable $exception) {
            $this->files->rollback();

            throw $exception;
        }
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function updateCertification(DriverCertification $certification, array $data, ?UploadedFile $file): DriverCertification
    {
        $certification->loadMissing('driver');
        $oldFilePath = $certification->file_path;

        try {
            DB::transaction(function () use ($certification, $data, $file): void {
                $certification->fill(collect($data)->only(['name', 'certificate_number', 'issuer', 'issued_at', 'expires_at'])->all());
                $changes = AdminLogger::describeChanges($certification->getOriginal(), $certification->getDirty());

                if ($file) {
                    $certification->file_path = $this->files->storeCertification($certification->driver_id, $file);
                    $changes = trim($changes.'; berkas diganti', '; ');
                }

                $certification->save();

                $this->logger->log('certification.updated', $certification, "Mengubah sertifikat {$certification->name} milik {$certification->driver->name}: ".($changes ?: 'tanpa perubahan'));
            });
        } catch (Throwable $exception) {
            $this->files->rollback();

            throw $exception;
        }

        if ($file) {
            $this->files->delete($oldFilePath);
        }

        return $certification->refresh();
    }

    public function deleteCertification(DriverCertification $certification): void
    {
        $certification->loadMissing('driver');

        DB::transaction(function () use ($certification): void {
            $this->logger->log('certification.deleted', $certification, "Menghapus sertifikat {$certification->name} milik {$certification->driver->name}");
            $certification->delete();
        });

        $this->files->delete($certification->file_path);
    }

    public function generatePassword(int $length = 12): string
    {
        return collect(range(1, $length))
            ->map(fn (): string => self::PASSWORD_ALPHABET[random_int(0, strlen(self::PASSWORD_ALPHABET) - 1)])
            ->implode('');
    }

    /**
     * @param  array<string, mixed>  $data
     */
    private function storeCertification(User $driver, array $data, ?UploadedFile $file): DriverCertification
    {
        $certification = $driver->certifications()->create([
            ...collect($data)->only(['name', 'certificate_number', 'issuer', 'issued_at', 'expires_at'])->all(),
            'file_path' => $file ? $this->files->storeCertification($driver->id, $file) : null,
        ]);

        $this->logger->log('certification.created', $certification, "Menambah sertifikat {$certification->name} untuk driver {$driver->name}");

        return $certification;
    }
}
