<?php

namespace App\Http\Controllers\Admin;

use App\Enums\AccountStatus;
use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\AdminLogger;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\View\View;

/**
 * Akun pelapor (role pelapor) yang mendaftar dari aplikasi Pelapor.
 */
class ReporterController extends Controller
{
    public function index(Request $request): View
    {
        Gate::authorize('viewAny', User::class);

        $filters = $request->validate([
            'q' => ['nullable', 'string', 'max:100'],
            'status' => ['nullable', 'in:aktif,nonaktif'],
        ]);

        $reporters = User::query()
            ->reporters()
            ->withCount(['devices', 'reportsMade'])
            ->withMax('devices', 'last_seen_at')
            ->when($filters['q'] ?? null, fn (Builder $query, string $search) => $query->where(fn (Builder $query) => $query
                ->where('name', 'like', "%{$search}%")
                ->orWhere('email', 'like', "%{$search}%")
                ->orWhere('phone', 'like', "%{$search}%")))
            ->when($filters['status'] ?? null, fn (Builder $query, string $status) => $query->where('account_status', $status))
            ->orderBy('name')
            ->paginate(20)
            ->withQueryString();

        return view('admin.users.index', ['reporters' => $reporters, 'filters' => $filters]);
    }

    public function show(User $reporter): View
    {
        Gate::authorize('view', $reporter);

        return view('admin.users.show', [
            'reporter' => $reporter,
            'devices' => $reporter->devices()->latest('last_seen_at')->get(),
            'reports' => $reporter->reportsMade()->with(['reportType', 'driver:id,name'])->latest()->paginate(20),
        ]);
    }

    public function toggleStatus(User $reporter, AdminLogger $logger): RedirectResponse
    {
        Gate::authorize('toggleStatus', $reporter);

        $activate = ! $reporter->isActive();
        $reporter->forceFill(['account_status' => $activate ? AccountStatus::Aktif : AccountStatus::Nonaktif])->save();

        $logger->log(
            $activate ? 'reporter.activated' : 'reporter.deactivated',
            $reporter,
            ($activate ? 'Mengaktifkan kembali' : 'Menonaktifkan').' akun pelapor '.$reporter->name,
        );

        return back()->with('success', 'Akun '.$reporter->name.($activate ? ' diaktifkan kembali.' : ' dinonaktifkan.'));
    }
}
