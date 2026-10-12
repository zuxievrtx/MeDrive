<?php

namespace App\Http\Controllers\Admin;

use App\Enums\AmbulanceStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\AmbulanceRequest;
use App\Models\Ambulance;
use App\Models\AmbulanceType;
use App\Models\Clinic;
use App\Models\Report;
use App\Services\AdminLogger;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class AmbulanceController extends Controller
{
    public function index(Request $request): View
    {
        Gate::authorize('viewAny', Ambulance::class);

        $filters = $request->validate([
            'q' => ['nullable', 'string', 'max:20'],
            'clinic_id' => ['nullable', 'integer'],
            'ambulance_type_id' => ['nullable', 'integer'],
            'status' => ['nullable', Rule::enum(AmbulanceStatus::class)],
        ]);

        $ambulances = Ambulance::query()
            ->with(['clinic:id,name', 'ambulanceType:id,name', 'openShift.driver:id,name'])
            ->when($filters['q'] ?? null, fn (Builder $query, string $search) => $query->where('plate_number', 'like', '%'.mb_strtoupper($search).'%'))
            ->when($filters['clinic_id'] ?? null, fn (Builder $query, int $clinicId) => $query->where('clinic_id', $clinicId))
            ->when($filters['ambulance_type_id'] ?? null, fn (Builder $query, int $typeId) => $query->where('ambulance_type_id', $typeId))
            ->when($filters['status'] ?? null, fn (Builder $query, string $status) => $query->where('status', $status))
            ->orderBy('plate_number')
            ->paginate(20)
            ->withQueryString();

        return view('admin.ambulances.index', [
            'ambulances' => $ambulances,
            'filters' => $filters,
            'clinics' => Clinic::query()->orderBy('name')->get(['id', 'name']),
            'ambulanceTypes' => AmbulanceType::query()->orderBy('name')->get(['id', 'name']),
            'statuses' => AmbulanceStatus::cases(),
        ]);
    }

    public function create(): View
    {
        Gate::authorize('create', Ambulance::class);

        return $this->form(new Ambulance(['status' => AmbulanceStatus::Tersedia]));
    }

    public function store(AmbulanceRequest $request, AdminLogger $logger): RedirectResponse
    {
        $ambulance = Ambulance::create($request->validated());
        $ambulance->load('clinic');
        $logger->log('ambulance.created', $ambulance, "Menambah ambulans {$ambulance->plate_number} ({$ambulance->clinic->name})");

        return redirect()->route('admin.ambulances.index')->with('success', "Ambulans {$ambulance->plate_number} ditambahkan.");
    }

    public function edit(Ambulance $ambulance): View
    {
        Gate::authorize('update', $ambulance);

        return $this->form($ambulance);
    }

    public function update(AmbulanceRequest $request, Ambulance $ambulance, AdminLogger $logger): RedirectResponse
    {
        $data = $request->validated();

        if ($error = $this->guardInUse($ambulance, $data['status'], (int) $data['clinic_id'])) {
            return back()->withInput()->with('error', $error);
        }

        $ambulance->fill($data);
        $statusChanged = $ambulance->isDirty('status');
        $changes = AdminLogger::describeChanges($ambulance->getOriginal(), $ambulance->getDirty());
        $ambulance->save();

        $logger->log(
            $statusChanged ? 'ambulance.status_changed' : 'ambulance.updated',
            $ambulance,
            "Mengubah ambulans {$ambulance->plate_number}: ".($changes ?: 'tanpa perubahan'),
        );

        return redirect()->route('admin.ambulances.index')->with('success', "Ambulans {$ambulance->plate_number} diperbarui.");
    }

    public function updateStatus(Request $request, Ambulance $ambulance, AdminLogger $logger): RedirectResponse
    {
        Gate::authorize('update', $ambulance);

        $status = AmbulanceStatus::from($request->validate([
            'status' => ['required', Rule::enum(AmbulanceStatus::class)],
        ])['status']);

        if ($error = $this->guardInUse($ambulance, $status->value, $ambulance->clinic_id)) {
            return back()->with('error', $error);
        }

        $previous = $ambulance->status;
        $ambulance->update(['status' => $status]);

        $logger->log('ambulance.status_changed', $ambulance, "Status {$ambulance->plate_number} diubah dari {$previous->value} menjadi {$status->value}");

        return back()->with('success', "Status {$ambulance->plate_number} menjadi {$status->label()}.");
    }

    /**
     * Ambulans dengan riwayat shift atau laporan tidak bisa dihapus (FK RESTRICT); sarankan menonaktifkan.
     */
    public function destroy(Ambulance $ambulance, AdminLogger $logger): RedirectResponse
    {
        Gate::authorize('delete', $ambulance);

        if ($ambulance->shifts()->exists() || Report::query()->where('ambulance_id', $ambulance->id)->exists()) {
            return back()->with('error', "Ambulans {$ambulance->plate_number} sudah punya riwayat shift atau laporan sehingga tidak bisa dihapus. Ubah statusnya menjadi nonaktif.");
        }

        $logger->log('ambulance.deleted', $ambulance, "Menghapus ambulans {$ambulance->plate_number}");
        $ambulance->delete();

        return redirect()->route('admin.ambulances.index')->with('success', "Ambulans {$ambulance->plate_number} dihapus.");
    }

    /**
     * Ambulans yang sedang dipakai shift terbuka tidak boleh dipindah klinik atau dikeluarkan dari status tersedia.
     */
    private function guardInUse(Ambulance $ambulance, string $status, int $clinicId): ?string
    {
        $ambulance->loadMissing('openShift.driver');

        if (! $ambulance->in_use) {
            return null;
        }

        if ($status !== AmbulanceStatus::Tersedia->value || $clinicId !== $ambulance->clinic_id) {
            return "Ambulans {$ambulance->plate_number} sedang dipakai {$ambulance->openShift->driver->name}. Akhiri shift terlebih dahulu sebelum mengubah status atau klinik.";
        }

        return null;
    }

    private function form(Ambulance $ambulance): View
    {
        return view('admin.ambulances.form', [
            'ambulance' => $ambulance,
            'clinics' => Clinic::query()->with('institution:id,name')->orderBy('name')->get(['id', 'institution_id', 'name', 'is_active']),
            'ambulanceTypes' => AmbulanceType::query()->orderBy('name')->get(['id', 'name']),
            'statuses' => AmbulanceStatus::cases(),
        ]);
    }
}
