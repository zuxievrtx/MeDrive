<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Admin\DriverCertificationRequest;
use App\Http\Resources\DriverCertificationResource;
use App\Models\DriverCertification;
use App\Models\User;
use App\Services\DriverAccountService;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Gate;

class DriverCertificationController extends ApiController
{
    public function __construct(private DriverAccountService $accounts) {}

    public function store(DriverCertificationRequest $request, User $driver): JsonResponse
    {
        $certification = $this->accounts->addCertification($driver, $request->safe()->except('file'), $request->file('file'));

        return $this->created(DriverCertificationResource::make($certification));
    }

    public function update(DriverCertificationRequest $request, DriverCertification $certification): JsonResponse
    {
        Gate::authorize('update', $certification);

        return $this->ok(DriverCertificationResource::make($this->accounts->updateCertification($certification, $request->safe()->except('file'), $request->file('file'))));
    }

    public function destroy(DriverCertification $certification): JsonResponse
    {
        Gate::authorize('delete', $certification);

        $this->accounts->deleteCertification($certification);

        return $this->noContent();
    }
}
