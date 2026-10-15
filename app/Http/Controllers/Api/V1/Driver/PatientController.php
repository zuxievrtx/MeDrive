<?php

namespace App\Http\Controllers\Api\V1\Driver;

use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Api\V1\Driver\PatientRequest;
use App\Http\Resources\ReportPatientResource;
use App\Models\Report;
use App\Models\ReportPatient;
use App\Services\ReportService;
use Illuminate\Http\JsonResponse;

class PatientController extends ApiController
{
    public function __construct(private ReportService $reports) {}

    public function store(PatientRequest $request, Report $report): JsonResponse
    {
        return $this->created(ReportPatientResource::make($this->reports->addPatient($report, $request->user(), $request->validated())));
    }

    public function update(PatientRequest $request, ReportPatient $patient): JsonResponse
    {
        return $this->ok(ReportPatientResource::make($this->reports->updatePatient($patient, $request->user(), $request->validated())));
    }
}
