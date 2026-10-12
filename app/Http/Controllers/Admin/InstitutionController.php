<?php

namespace App\Http\Controllers\Admin;

use App\Enums\InstitutionType;
use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\InstitutionRequest;
use App\Models\Institution;
use App\Services\AdminLogger;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\View\View;

class InstitutionController extends Controller
{
    public function index(Request $request): View
    {
        Gate::authorize('viewAny', Institution::class);

        $filters = $request->validate([
            'q' => ['nullable', 'string', 'max:100'],
            'type' => ['nullable', 'in:pemerintah,swasta,sosial'],
            'active' => ['nullable', 'in:1,0'],
        ]);

        $institutions = Institution::query()
            ->withCount('clinics')
            ->when($filters['q'] ?? null, fn (Builder $query, string $search) => $query->where(fn (Builder $query) => $query
                ->where('name', 'like', "%{$search}%")
                ->orWhere('code', 'like', "%{$search}%")))
            ->when($filters['type'] ?? null, fn (Builder $query, string $type) => $query->where('type', $type))
            ->when(isset($filters['active']), fn (Builder $query) => $query->where('is_active', (bool) $filters['active']))
            ->orderBy('name')
            ->paginate(20)
            ->withQueryString();

        return view('admin.institutions.index', [
            'institutions' => $institutions,
            'filters' => $filters,
            'types' => InstitutionType::cases(),
        ]);
    }

    public function create(): View
    {
        Gate::authorize('create', Institution::class);

        return view('admin.institutions.form', ['institution' => new Institution(['is_active' => true]), 'types' => InstitutionType::cases()]);
    }

    public function store(InstitutionRequest $request, AdminLogger $logger): RedirectResponse
    {
        $institution = Institution::create($request->validated());
        $logger->log('institution.created', $institution, "Menambah instansi {$institution->name} ({$institution->code})");

        return redirect()->route('admin.institutions.index')->with('success', "Instansi {$institution->name} ditambahkan.");
    }

    public function edit(Institution $institution): View
    {
        Gate::authorize('update', $institution);

        return view('admin.institutions.form', ['institution' => $institution, 'types' => InstitutionType::cases()]);
    }

    public function update(InstitutionRequest $request, Institution $institution, AdminLogger $logger): RedirectResponse
    {
        $institution->fill($request->validated());
        $changes = AdminLogger::describeChanges($institution->getOriginal(), $institution->getDirty());
        $institution->save();

        $logger->log('institution.updated', $institution, "Mengubah instansi {$institution->name}: ".($changes ?: 'tanpa perubahan'));

        return redirect()->route('admin.institutions.index')->with('success', "Instansi {$institution->name} diperbarui.");
    }

    /**
     * Instansi yang masih punya klinik tidak bisa dihapus (FK RESTRICT); sarankan menonaktifkan.
     */
    public function destroy(Institution $institution, AdminLogger $logger): RedirectResponse
    {
        Gate::authorize('delete', $institution);

        $clinicCount = $institution->clinics()->count();

        if ($clinicCount > 0) {
            return back()->with('error', "Instansi {$institution->name} masih memiliki {$clinicCount} klinik sehingga tidak bisa dihapus. Nonaktifkan instansi bila sudah tidak dipakai.");
        }

        $logger->log('institution.deleted', $institution, "Menghapus instansi {$institution->name} ({$institution->code})");
        $institution->delete();

        return redirect()->route('admin.institutions.index')->with('success', "Instansi {$institution->name} dihapus.");
    }
}
