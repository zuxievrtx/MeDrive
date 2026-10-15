<?php

namespace App\Http\Controllers\Api\V1;

use App\Exceptions\ApiException;
use App\Http\Controllers\Api\ApiController;
use App\Models\DriverCertification;
use App\Models\DriverProfile;
use App\Models\Report;
use App\Models\ReportAttachment;
use App\Models\ReportDispatch;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\StreamedResponse;

/**
 * Streaming berkas privat (foto driver, sertifikat, lampiran laporan) dengan otorisasi per jenis berkas.
 * Berkas tidak pernah punya URL publik.
 */
class MediaController extends ApiController
{
    public function __invoke(Request $request, string $type, int $id): StreamedResponse
    {
        $user = $request->user();

        [$path, $filename, $mime] = match ($type) {
            'driver-photo' => $this->driverPhoto($user, $id),
            'certification' => $this->certification($user, $id),
            'attachment' => $this->attachment($user, $id),
        };

        if (! $path || ! Storage::disk('local')->exists($path)) {
            throw new ApiException('file_not_found', 'Berkas tidak ditemukan di penyimpanan.', 404);
        }

        $headers = array_filter(['Content-Type' => $mime, 'Cache-Control' => 'private, max-age=600']);
        $isImage = str_starts_with((string) ($mime ?? Storage::disk('local')->mimeType($path)), 'image/');

        return $isImage && ! $request->boolean('download')
            ? Storage::disk('local')->response($path, $filename, $headers)
            : Storage::disk('local')->download($path, $filename, $headers);
    }

    /**
     * @return array{0: ?string, 1: string, 2: ?string}
     */
    private function driverPhoto(User $user, int $driverId): array
    {
        $allowed = $user->isAdmin()
            || $user->id === $driverId
            || Report::query()->where('reporter_id', $user->id)->where('driver_id', $driverId)->exists();

        $this->authorizeOrFail($allowed);

        $path = DriverProfile::query()->where('user_id', $driverId)->value('photo_path');

        return [$path, 'foto-driver-'.$driverId.'.'.pathinfo((string) $path, PATHINFO_EXTENSION), null];
    }

    /**
     * @return array{0: ?string, 1: string, 2: ?string}
     */
    private function certification(User $user, int $id): array
    {
        $certification = DriverCertification::query()->findOrFail($id);
        $this->authorizeOrFail($user->isAdmin() || $user->id === $certification->driver_id);

        return [$certification->file_path, str($certification->name)->slug().'.'.pathinfo((string) $certification->file_path, PATHINFO_EXTENSION), null];
    }

    /**
     * Lampiran laporan: admin, pelapor pemilik, driver yang menangani, atau driver yang menerima tawarannya.
     *
     * @return array{0: ?string, 1: string, 2: ?string}
     */
    private function attachment(User $user, int $id): array
    {
        $attachment = ReportAttachment::query()->with('report:id,code,reporter_id,driver_id')->findOrFail($id);
        $report = $attachment->report;

        $allowed = $user->isAdmin()
            || $report->reporter_id === $user->id
            || $report->driver_id === $user->id
            || ($user->isDriver() && ReportDispatch::query()->where('report_id', $report->id)->where('driver_id', $user->id)->exists());

        $this->authorizeOrFail($allowed);

        return [$attachment->file_path, $report->code.'-'.$attachment->type.'.'.pathinfo($attachment->file_path, PATHINFO_EXTENSION), $attachment->mime_type];
    }

    private function authorizeOrFail(bool $allowed): void
    {
        if (! $allowed) {
            throw ApiException::forbidden('media_forbidden', 'Anda tidak berhak membuka berkas ini.');
        }
    }
}
