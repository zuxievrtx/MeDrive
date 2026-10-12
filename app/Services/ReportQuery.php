<?php

namespace App\Services;

use App\Models\Report;
use Illuminate\Database\Eloquent\Builder;

/**
 * Filter daftar laporan yang dipakai bersama oleh tabel dan export CSV agar hasilnya selalu sama.
 */
class ReportQuery
{
    /**
     * @return array<string, array<int, string>>
     */
    public static function rules(): array
    {
        return [
            'q' => ['nullable', 'string', 'max:100'],
            'type' => ['nullable', 'integer'],
            'status' => ['nullable', 'in:menunggu,diambil,dalam_perjalanan,tiba_di_lokasi,mengantar_pasien,selesai,dibatalkan'],
            'from' => ['nullable', 'date'],
            'to' => ['nullable', 'date', 'after_or_equal:from'],
            'driver_id' => ['nullable', 'integer'],
            'clinic_id' => ['nullable', 'integer'],
        ];
    }

    /**
     * @param  array<string, mixed>  $filters
     * @return Builder<Report>
     */
    public static function filtered(array $filters): Builder
    {
        return Report::query()
            ->when($filters['q'] ?? null, fn (Builder $query, string $search) => $query->where(fn (Builder $query) => $query
                ->where('code', 'like', "%{$search}%")
                ->orWhere('description', 'like', "%{$search}%")
                ->orWhere('address', 'like', "%{$search}%")))
            ->when($filters['type'] ?? null, fn (Builder $query, int $typeId) => $query->where('report_type_id', $typeId))
            ->when($filters['status'] ?? null, fn (Builder $query, string $status) => $query->where('status', $status))
            ->when($filters['from'] ?? null, fn (Builder $query, string $from) => $query->where('created_at', '>=', now()->parse($from)->startOfDay()))
            ->when($filters['to'] ?? null, fn (Builder $query, string $to) => $query->where('created_at', '<=', now()->parse($to)->endOfDay()))
            ->when($filters['driver_id'] ?? null, fn (Builder $query, int $driverId) => $query->where('driver_id', $driverId))
            ->when($filters['clinic_id'] ?? null, fn (Builder $query, int $clinicId) => $query->whereHas('ambulance', fn (Builder $query) => $query->where('clinic_id', $clinicId)));
    }
}
