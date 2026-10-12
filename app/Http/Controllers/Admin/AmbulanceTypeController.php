<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AmbulanceType;
use App\Services\AdminLogger;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\View\View;

/**
 * Jenis ambulans hanya bisa diubah nama dan deskripsinya; kode dipakai aturan broadcast sehingga tetap.
 */
class AmbulanceTypeController extends Controller
{
    public function index(): View
    {
        Gate::authorize('viewAny', AmbulanceType::class);

        return view('admin.ambulance-types.index', [
            'ambulanceTypes' => AmbulanceType::query()->withCount('ambulances')->with('reportTypes:id,name,color,icon')->orderBy('id')->get(),
        ]);
    }

    public function edit(AmbulanceType $ambulanceType): View
    {
        Gate::authorize('update', $ambulanceType);

        return view('admin.ambulance-types.edit', ['ambulanceType' => $ambulanceType]);
    }

    public function update(Request $request, AmbulanceType $ambulanceType, AdminLogger $logger): RedirectResponse
    {
        Gate::authorize('update', $ambulanceType);

        $ambulanceType->fill($request->validate([
            'name' => ['required', 'string', 'max:100'],
            'description' => ['nullable', 'string', 'max:255'],
        ], attributes: ['name' => 'nama', 'description' => 'deskripsi']));

        $changes = AdminLogger::describeChanges($ambulanceType->getOriginal(), $ambulanceType->getDirty());
        $ambulanceType->save();

        $logger->log('ambulance_type.updated', $ambulanceType, "Mengubah jenis ambulans {$ambulanceType->code}: ".($changes ?: 'tanpa perubahan'));

        return redirect()->route('admin.ambulance-types.index')->with('success', "Jenis ambulans {$ambulanceType->name} diperbarui.");
    }
}
