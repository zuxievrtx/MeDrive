<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Admin\ReportTypeRequest;
use App\Http\Resources\ReportTypeResource;
use App\Models\ReportType;
use App\Services\ReportTypeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

/**
 * @group Admin
 */
class ReportTypeController extends ApiController
{
    public function index(Request $request): JsonResponse
    {
        Gate::authorize('viewAny', ReportType::class);

        $types = ReportType::query()->with('ambulanceTypes')->withCount('reports')->orderBy('sort_order')->get();

        return $this->ok(ReportTypeResource::collection($types)->resolve($request));
    }

    public function show(ReportType $reportType): JsonResponse
    {
        Gate::authorize('update', $reportType);

        return $this->ok(ReportTypeResource::make($reportType->load('ambulanceTypes')));
    }

    public function update(ReportTypeRequest $request, ReportType $reportType, ReportTypeService $service): JsonResponse
    {
        $data = $request->validated();
        $ambulanceTypeIds = array_map('intval', $data['ambulance_type_ids'] ?? []);
        unset($data['ambulance_type_ids']);

        return $this->ok(ReportTypeResource::make($service->update($reportType, $data, $ambulanceTypeIds)));
    }
}
