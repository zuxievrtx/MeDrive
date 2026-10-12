<?php

namespace App\Http\Controllers\Admin;

use App\Enums\ClinicType;
use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\ClinicRequest;
use App\Models\Clinic;
use App\Models\Institution;
use App\Services\AdminLogger;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\View\View;

class ClinicController extends Controller
{
    public function index(Request $request): View
    {
        Gate::authorize('viewAny', Clinic::class);

        $filters = $request->validate([
            'q' => ['nullable', 'string', 'max:100'],
            'institution_id' => ['nullable', 'integer'],
            'type' => ['nullable', 'in:klinik,puskesmas,rumah_sakit,pos_ambulans'],
            'active' => ['nullable', 'in:1,0'],
        ]);

        $clinics = Clinic::query()
            ->with('institution:id,name')
            ->withCount(['driverProfiles', 'ambulances'])
            ->when($filters['q'] ?? null, fn (Builder $query, string $search) => $query->where(fn (Builder $query) => $query
                ->where('name', 'like', "%{$search}%")
                ->orWhere('code', 'like', "%{$search}%")
                ->orWhere('address', 'like', "%{$search}%")))
            ->when($filters['institution_id'] ?? null, fn (Builder $query, int $institutionId) => $query->where('institution_id', $institutionId))
            ->when($filters['type'] ?? null, fn (Builder $query, string $type) => $query->where('type', $type))
            ->when(isset($filters['active']), fn (Builder $query) => $query->where('is_active', (bool) $filters['active']))
            ->orderBy('name')
            ->paginate(20)
            ->withQueryString();

        return view('admin.clinics.index', [
            'clinics' => $clinics,
            'filters' => $filters,
            'institutions' => Institution::query()->orderBy('name')->get(['id', 'name']),
            'types' => ClinicType::cases(),
        ]);
    }

    public function create(): View
    {
        Gate::authorize('create', Clinic::class);

        return $this->form(new Clinic(['is_active' => true]));
    }

    public function store(ClinicRequest $request, AdminLogger $logger): RedirectResponse
    {
        $clinic = Clinic::create($request->validated());
        $logger->log('clinic.created', $clinic, "Menambah klinik {$clinic->name} ({$clinic->code})");

        return redirect()->route('admin.clinics.index')->with('success', "Klinik {$clinic->name} ditambahkan.");
    }

    public function edit(Clinic $clinic): View
    {
        Gate::authorize('update', $clinic);

        return $this->form($clinic);
    }

    public function update(ClinicRequest $request, Clinic $clinic, AdminLogger $logger): RedirectResponse
    {
        $clinic->fill($request->validated());
        $changes = AdminLogger::describeChanges($clinic->getOriginal(), $clinic->getDirty());
        $clinic->save();

        $logger->log('clinic.updated', $clinic, "Mengubah klinik {$clinic->name}: ".($changes ?: 'tanpa perubahan'));

        return redirect()->route('admin.clinics.index')->with('success', "Klinik {$clinic->name} diperbarui.");
    }

    /**
     * Klinik yang masih punya driver atau ambulans tidak bisa dihapus (FK RESTRICT).
     */
    public function destroy(Clinic $clinic, AdminLogger $logger): RedirectResponse
    {
        Gate::authorize('delete', $clinic);

        $driverCount = $clinic->driverProfiles()->count();
        $ambulanceCount = $clinic->ambulances()->count();

        if ($driverCount > 0 || $ambulanceCount > 0) {
            return back()->with('error', "Klinik {$clinic->name} masih memiliki {$driverCount} driver dan {$ambulanceCount} ambulans sehingga tidak bisa dihapus. Pindahkan datanya atau nonaktifkan klinik.");
        }

        $logger->log('clinic.deleted', $clinic, "Menghapus klinik {$clinic->name} ({$clinic->code})");
        $clinic->delete();

        return redirect()->route('admin.clinics.index')->with('success', "Klinik {$clinic->name} dihapus.");
    }

    private function form(Clinic $clinic): View
    {
        return view('admin.clinics.form', [
            'clinic' => $clinic,
            'institutions' => Institution::query()->orderBy('name')->get(['id', 'name', 'is_active']),
            'types' => ClinicType::cases(),
        ]);
    }
}
