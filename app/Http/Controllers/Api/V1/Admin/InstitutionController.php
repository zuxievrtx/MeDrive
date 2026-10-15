<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Admin\InstitutionRequest;
use App\Http\Resources\InstitutionResource;
use App\Models\Institution;
use App\Services\OrganizationService;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class InstitutionController extends ApiController
{
    public function __construct(private OrganizationService $organizations) {}

    public function index(Request $request): JsonResponse
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
            ->paginate(20);

        return $this->paginated($institutions, InstitutionResource::class);
    }

    public function store(InstitutionRequest $request): JsonResponse
    {
        return $this->created(InstitutionResource::make($this->organizations->createInstitution($request->validated())));
    }

    public function show(Institution $institution): JsonResponse
    {
        Gate::authorize('update', $institution);

        return $this->ok(InstitutionResource::make($institution->loadCount('clinics')));
    }

    public function update(InstitutionRequest $request, Institution $institution): JsonResponse
    {
        return $this->ok(InstitutionResource::make($this->organizations->updateInstitution($institution, $request->validated())));
    }

    public function destroy(Institution $institution): JsonResponse
    {
        Gate::authorize('delete', $institution);

        $this->organizations->deleteInstitution($institution);

        return $this->noContent();
    }
}
