<?php

namespace App\Http\Resources;

use App\Models\ReportType;
use App\Support\Color;
use Illuminate\Http\Request;

/** @mixin ReportType */
class ReportTypeResource extends ApiResource
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
            'priority' => $this->priority,
            'is_emergency' => (bool) $this->is_emergency,
            'requires_destination' => (bool) $this->requires_destination,
            'icon' => $this->icon,
            'color' => $this->color,
            'text_color' => Color::readableTextOn($this->color),
            'is_active' => (bool) $this->is_active,
            'sort_order' => $this->sort_order,
            'ambulance_types' => AmbulanceTypeResource::collection($this->whenLoaded('ambulanceTypes')),
            'reports_count' => $this->whenCounted('reports'),
        ];
    }
}
