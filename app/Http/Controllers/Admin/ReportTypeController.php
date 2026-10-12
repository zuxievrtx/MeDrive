<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\ReportTypeRequest;
use App\Models\AmbulanceType;
use App\Models\ReportType;
use App\Services\AdminLogger;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\View\View;

/**
 * Aturan jenis laporan, termasuk jenis ambulans yang menerima broadcast (report_type_ambulance_types).
 */
class ReportTypeController extends Controller
{
    public function index(): View
    {
        Gate::authorize('viewAny', ReportType::class);

        return view('admin.report-types.index', [
            'reportTypes' => ReportType::query()->with('ambulanceTypes:id,name')->withCount('reports')->orderBy('sort_order')->get(),
        ]);
    }

    public function edit(ReportType $reportType): View
    {
        Gate::authorize('update', $reportType);

        $reportType->load('ambulanceTypes:id');

        return view('admin.report-types.edit', [
            'reportType' => $reportType,
            'ambulanceTypes' => AmbulanceType::query()->orderBy('id')->get(),
        ]);
    }

    public function update(ReportTypeRequest $request, ReportType $reportType, AdminLogger $logger): RedirectResponse
    {
        $data = $request->validated();

        DB::transaction(function () use ($data, $reportType, $logger): void {
            $reportType->load('ambulanceTypes:id,name');
            $before = $reportType->ambulanceTypes->pluck('name')->sort()->implode(', ');

            $reportType->fill(collect($data)->except('ambulance_type_ids')->all());
            $changes = array_filter([AdminLogger::describeChanges($reportType->getOriginal(), $reportType->getDirty())]);
            $reportType->save();

            $sync = $reportType->ambulanceTypes()->sync($data['ambulance_type_ids'] ?? []);

            if (array_filter($sync)) {
                $after = AmbulanceType::query()->whereIn('id', $data['ambulance_type_ids'] ?? [])->pluck('name')->sort()->implode(', ');
                $changes[] = 'penerima broadcast: '.($before ?: 'kosong').' -> '.($after ?: 'kosong');
            }

            $logger->log('report_type.updated', $reportType, "Mengubah jenis laporan {$reportType->name}: ".($changes ? implode('; ', $changes) : 'tanpa perubahan'));
        });

        return redirect()->route('admin.report-types.index')->with('success', "Jenis laporan {$reportType->name} diperbarui.");
    }
}
