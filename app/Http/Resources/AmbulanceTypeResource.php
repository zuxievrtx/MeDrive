<?php

namespace App\Http\Resources;

use App\Models\AmbulanceType;
use Illuminate\Http\Request;

/** @mixin AmbulanceType */
class AmbulanceTypeResource extends ApiResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'code' => $this->code,
            'name' => $this->name,
            'description' => $this->description,
            'map_icon' => $this->mapIcon(),
            'report_types' => ReportTypeResource::collection($this->whenLoaded('reportTypes')),
            'ambulances_count' => $this->whenCounted('ambulances'),
        ];
    }
}
