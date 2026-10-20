<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Enums\AmbulanceStatus;
use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Admin\AmbulanceRequest;
use App\Http\Resources\AmbulanceResource;
use App\Models\Ambulance;
use App\Services\FleetService;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Validation\Rule;

/**
 * @group Admin
 */
class AmbulanceController extends ApiController
{
    public function __construct(private FleetService $fleet) {}

    public function index(Request $request): JsonResponse
    {
        Gate::authorize('viewAny', Ambulance::class);

        $filters = $request->validate([
            'q' => ['nullable', 'string', 'max:20'],
            'clinic_id' => ['nullable', 'integer'],
            'ambulance_type_id' => ['nullable', 'integer'],
            'status' => ['nullable', Rule::enum(AmbulanceStatus::class)],
        ]);

        $ambulances = Ambulance::query()
            ->with(['clinic:id,name', 'ambulanceType:id,code,name', 'openShift.driver:id,name'])
            ->when($filters['q'] ?? null, fn (Builder $query, string $search) => $query->where('plate_number', 'like', '%'.mb_strtoupper($search).'%'))
            ->when($filters['clinic_id'] ?? null, fn (Builder $query, int $clinicId) => $query->where('clinic_id', $clinicId))
            ->when($filters['ambulance_type_id'] ?? null, fn (Builder $query, int $typeId) => $query->where('ambulance_type_id', $typeId))
            ->when($filters['status'] ?? null, fn (Builder $query, string $status) => $query->where('status', $status))
            ->orderBy('plate_number')
            ->paginate(20);

        return $this->paginated($ambulances, AmbulanceResource::class);
    }

    public function store(AmbulanceRequest $request): JsonResponse
    {
        return $this->created(AmbulanceResource::make($this->fleet->createAmbulance($request->validated())));
    }

    public function show(Ambulance $ambulance): JsonResponse
    {
        Gate::authorize('update', $ambulance);

        return $this->ok(AmbulanceResource::make($ambulance->load(['clinic', 'ambulanceType', 'openShift.driver'])));
    }

    public function update(AmbulanceRequest $request, Ambulance $ambulance): JsonResponse
    {
        return $this->ok(AmbulanceResource::make($this->fleet->updateAmbulance($ambulance, $request->validated())));
    }

    public function updateStatus(Request $request, Ambulance $ambulance): JsonResponse
    {
        Gate::authorize('update', $ambulance);

        $status = AmbulanceStatus::from($request->validate(['status' => ['required', Rule::enum(AmbulanceStatus::class)]])['status']);

        return $this->ok(AmbulanceResource::make($this->fleet->changeStatus($ambulance, $status)->load(['clinic', 'ambulanceType', 'openShift.driver'])));
    }

    public function destroy(Ambulance $ambulance): JsonResponse
    {
        Gate::authorize('delete', $ambulance);

        $this->fleet->deleteAmbulance($ambulance);

        return $this->noContent();
    }
}
