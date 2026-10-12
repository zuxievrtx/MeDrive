<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\DriverCertificationRequest;
use App\Models\DriverCertification;
use App\Models\User;
use App\Services\AdminLogger;
use App\Services\DriverFileStorage;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\StreamedResponse;
use Throwable;

class DriverCertificationController extends Controller
{
    public function store(DriverCertificationRequest $request, User $driver, AdminLogger $logger, DriverFileStorage $files): RedirectResponse
    {
        try {
            DB::transaction(function () use ($request, $driver, $logger, $files): void {
                $certification = $driver->certifications()->create([
                    ...$request->safe()->except('file'),
                    'file_path' => $request->hasFile('file') ? $files->storeCertification($driver->id, $request->file('file')) : null,
                ]);

                $logger->log('certification.created', $certification, "Menambah sertifikat {$certification->name} untuk driver {$driver->name}");
            });
        } catch (Throwable $exception) {
            $files->rollback();

            throw $exception;
        }

        return redirect()
            ->route('admin.drivers.show', ['driver' => $driver, 'tab' => 'sertifikat'])
            ->with('success', 'Sertifikat ditambahkan.');
    }

    public function update(DriverCertificationRequest $request, DriverCertification $certification, AdminLogger $logger, DriverFileStorage $files): RedirectResponse
    {
        Gate::authorize('update', $certification);

        $certification->load('driver');
        $oldFilePath = $certification->file_path;

        try {
            DB::transaction(function () use ($request, $certification, $logger, $files): void {
                $certification->fill($request->safe()->except('file'));
                $changes = AdminLogger::describeChanges($certification->getOriginal(), $certification->getDirty());

                if ($request->hasFile('file')) {
                    $certification->file_path = $files->storeCertification($certification->driver_id, $request->file('file'));
                    $changes = trim($changes.'; berkas diganti', '; ');
                }

                $certification->save();

                $logger->log(
                    'certification.updated',
                    $certification,
                    "Mengubah sertifikat {$certification->name} milik {$certification->driver->name}: ".($changes ?: 'tanpa perubahan'),
                );
            });
        } catch (Throwable $exception) {
            $files->rollback();

            throw $exception;
        }

        if ($request->hasFile('file')) {
            $files->delete($oldFilePath);
        }

        return redirect()
            ->route('admin.drivers.show', ['driver' => $certification->driver_id, 'tab' => 'sertifikat'])
            ->with('success', 'Sertifikat diperbarui.');
    }

    public function destroy(DriverCertification $certification, AdminLogger $logger, DriverFileStorage $files): RedirectResponse
    {
        Gate::authorize('delete', $certification);

        $certification->load('driver');

        DB::transaction(function () use ($certification, $logger): void {
            $logger->log('certification.deleted', $certification, "Menghapus sertifikat {$certification->name} milik {$certification->driver->name}");
            $certification->delete();
        });

        $files->delete($certification->file_path);

        return redirect()
            ->route('admin.drivers.show', ['driver' => $certification->driver_id, 'tab' => 'sertifikat'])
            ->with('success', 'Sertifikat dihapus.');
    }

    public function file(DriverCertification $certification): StreamedResponse
    {
        Gate::authorize('download', $certification);

        abort_unless($certification->file_path && Storage::disk('local')->exists($certification->file_path), 404, 'Berkas sertifikat tidak ditemukan.');

        $extension = pathinfo($certification->file_path, PATHINFO_EXTENSION);

        return Storage::disk('local')->download($certification->file_path, str($certification->name)->slug().'.'.$extension);
    }
}
