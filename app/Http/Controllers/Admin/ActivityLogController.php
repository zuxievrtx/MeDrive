<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\AdminActivityLog;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\View\View;

class ActivityLogController extends Controller
{
    public function __invoke(Request $request): View
    {
        Gate::authorize('viewAny', AdminActivityLog::class);

        $filters = $request->validate([
            'admin_id' => ['nullable', 'integer'],
            'module' => ['nullable', 'string', 'max:30', 'alpha_dash'],
            'from' => ['nullable', 'date'],
            'to' => ['nullable', 'date', 'after_or_equal:from'],
        ]);

        $logs = AdminActivityLog::query()
            ->with('admin:id,name')
            ->when($filters['admin_id'] ?? null, fn (Builder $query, int $adminId) => $query->where('admin_id', $adminId))
            ->when($filters['module'] ?? null, fn (Builder $query, string $module) => $query->where('action', 'like', $module.'.%'))
            ->when($filters['from'] ?? null, fn (Builder $query, string $from) => $query->where('created_at', '>=', now()->parse($from)->startOfDay()))
            ->when($filters['to'] ?? null, fn (Builder $query, string $to) => $query->where('created_at', '<=', now()->parse($to)->endOfDay()))
            ->latest()
            ->orderByDesc('id')
            ->paginate(20)
            ->withQueryString();

        $modules = AdminActivityLog::query()
            ->distinct()
            ->pluck('action')
            ->map(fn (string $action): string => strtok($action, '.'))
            ->unique()
            ->sort()
            ->values();

        return view('admin.activity-logs.index', [
            'logs' => $logs,
            'filters' => $filters,
            'admins' => User::query()->where('role', UserRole::Admin)->orderBy('name')->get(['id', 'name']),
            'modules' => $modules,
        ]);
    }
}
