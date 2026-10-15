<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Admin\ClinicRequest;
use App\Http\Resources\ClinicResource;
use App\Models\Clinic;
use App\Services\OrganizationService;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class ClinicController extends ApiController
{
    public function __construct(private OrganizationService $organizations) {}

    public function index(Request $request): JsonResponse
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
            ->paginate(20);

        return $this->paginated($clinics, ClinicResource::class);
    }

    public function store(ClinicRequest $request): JsonResponse
    {
        return $this->created(ClinicResource::make($this->organizations->createClinic($request->validated())));
    }

    public function show(Clinic $clinic): JsonResponse
    {
        Gate::authorize('update', $clinic);

        return $this->ok(ClinicResource::make($clinic->load('institution')->loadCount(['driverProfiles', 'ambulances'])));
    }

    public function update(ClinicRequest $request, Clinic $clinic): JsonResponse
    {
        return $this->ok(ClinicResource::make($this->organizations->updateClinic($clinic, $request->validated())));
    }

    public function destroy(Clinic $clinic): JsonResponse
    {
        Gate::authorize('delete', $clinic);

        $this->organizations->deleteClinic($clinic);

        return $this->noContent();
    }
}
