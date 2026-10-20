<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Api\ApiController;
use App\Http\Resources\ActivityLogResource;
use App\Models\AdminActivityLog;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

/**
 * Log aktivitas admin: hanya baca.
 *
 * @group Admin
 */
class ActivityLogController extends ApiController
{
    public function __invoke(Request $request): JsonResponse
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
            ->paginate(20);

        return $this->paginated($logs, ActivityLogResource::class);
    }
}
