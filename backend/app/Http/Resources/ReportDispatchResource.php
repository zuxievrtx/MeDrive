<?php

namespace App\Http\Resources;

use App\Models\ReportDispatch;
use Illuminate\Http\Request;

/** @mixin ReportDispatch */
class ReportDispatchResource extends ApiResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'report_id' => $this->report_id,
            'driver' => $this->whenLoaded('driver', fn (): array => ['id' => $this->driver->id, 'name' => $this->driver->name]),
            'plate_number' => $this->whenLoaded('shift', fn (): ?string => $this->shift?->relationLoaded('ambulance') ? $this->shift->ambulance?->plate_number : null),
            'distance_km' => (float) $this->distance_km,
            'sent_at' => $this->date($this->sent_at),
            'opened_at' => $this->date($this->opened_at),
            'responded_at' => $this->date($this->responded_at),
            'response' => $this->enum($this->response),
            'report' => ReportDetailResource::make($this->whenLoaded('report')),
        ];
    }
}
