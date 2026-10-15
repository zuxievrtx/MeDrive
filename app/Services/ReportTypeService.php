<?php

namespace App\Services;

use App\Models\AmbulanceType;
use App\Models\ReportType;
use Illuminate\Support\Facades\DB;

/**
 * Aturan jenis laporan, termasuk jenis ambulans penerima broadcast (report_type_ambulance_types).
 */
class ReportTypeService
{
    public function __construct(private AdminLogger $logger) {}

    /**
     * @param  array<string, mixed>  $data
     * @param  list<int>  $ambulanceTypeIds
     */
    public function update(ReportType $reportType, array $data, array $ambulanceTypeIds): ReportType
    {
        DB::transaction(function () use ($reportType, $data, $ambulanceTypeIds): void {
            $reportType->load('ambulanceTypes:id,name');
            $before = $reportType->ambulanceTypes->pluck('name')->sort()->implode(', ');

            $reportType->fill($data);
            $changes = array_filter([AdminLogger::describeChanges($reportType->getOriginal(), $reportType->getDirty())]);
            $reportType->save();

            $sync = $reportType->ambulanceTypes()->sync($ambulanceTypeIds);

            if (array_filter($sync)) {
                $after = AmbulanceType::query()->whereIn('id', $ambulanceTypeIds)->pluck('name')->sort()->implode(', ');
                $changes[] = 'penerima broadcast: '.($before ?: 'kosong').' -> '.($after ?: 'kosong');
            }

            $this->logger->log('report_type.updated', $reportType, "Mengubah jenis laporan {$reportType->name}: ".($changes ? implode('; ', $changes) : 'tanpa perubahan'));
        });

        return $reportType->load('ambulanceTypes');
    }
}
