<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Api\ApiController;
use App\Http\Resources\AmbulanceTypeResource;
use App\Models\AmbulanceType;
use App\Services\FleetService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

/**
 * Edit terbatas: kode jenis dipakai aturan broadcast sehingga tidak bisa diubah.
 */
class AmbulanceTypeController extends ApiController
{
    public function index(Request $request): JsonResponse
    {
        Gate::authorize('viewAny', AmbulanceType::class);

        $types = AmbulanceType::query()->withCount('ambulances')->with('reportTypes')->orderBy('id')->get();

        return $this->ok(AmbulanceTypeResource::collection($types)->resolve($request));
    }

    public function show(AmbulanceType $ambulanceType): JsonResponse
    {
        Gate::authorize('update', $ambulanceType);

        return $this->ok(AmbulanceTypeResource::make($ambulanceType));
    }

    public function update(Request $request, AmbulanceType $ambulanceType, FleetService $fleet): JsonResponse
    {
        Gate::authorize('update', $ambulanceType);

        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'description' => ['nullable', 'string', 'max:255'],
        ], attributes: ['name' => 'nama', 'description' => 'deskripsi']);

        return $this->ok(AmbulanceTypeResource::make($fleet->updateType($ambulanceType, $data)));
    }
}
