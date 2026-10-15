<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Enums\AccountStatus;
use App\Http\Controllers\Api\ApiController;
use App\Http\Resources\UserResource;
use App\Models\User;
use App\Services\ReporterAccountService;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Validation\Rule;

/**
 * Pengguna pelapor: daftar, ringkasan perangkat/laporan, dan aktif/nonaktif akun.
 *
 * @group Admin
 */
class ReporterController extends ApiController
{
    public function index(Request $request): JsonResponse
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
            ->paginate(20);

        return $this->paginated($reporters, UserResource::class);
    }

    public function show(User $reporter): JsonResponse
    {
        Gate::authorize('view', $reporter);

        return $this->ok(UserResource::make($reporter->load(['devices' => fn ($query) => $query->latest('last_seen_at')])->loadCount('reportsMade')));
    }

    public function update(Request $request, User $reporter, ReporterAccountService $accounts): JsonResponse
    {
        Gate::authorize('toggleStatus', $reporter);

        $status = AccountStatus::from($request->validate(['account_status' => ['required', Rule::enum(AccountStatus::class)]])['account_status']);

        return $this->ok(UserResource::make($accounts->setStatus($reporter, $status)));
    }
}
