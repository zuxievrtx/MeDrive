<?php

namespace App\Http\Controllers\Api\V1\Driver;

use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Api\V1\Driver\HandlingPhotosRequest;
use App\Http\Resources\ReportAttachmentResource;
use App\Models\Report;
use App\Services\ReportService;
use Illuminate\Http\JsonResponse;

/**
 * Foto penanganan dari driver (type foto_penanganan).
 */
class AttachmentController extends ApiController
{
    public function __invoke(HandlingPhotosRequest $request, Report $report, ReportService $reports): JsonResponse
    {
        $attachments = $reports->addHandlingPhotos($report, $request->user(), $request->file('photos'));

        return $this->created(ReportAttachmentResource::collection($attachments)->resolve($request));
    }
}
