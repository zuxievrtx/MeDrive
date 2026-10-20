<?php

namespace App\Http\Resources;

use App\Models\ReportStatusLog;
use Illuminate\Http\Request;

/** @mixin ReportStatusLog */
class ReportStatusLogResource extends ApiResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'from_status' => $this->enum($this->from_status),
            'to_status' => $this->enum($this->to_status),
            'changed_by' => $this->whenLoaded('changer', fn (): ?array => $this->changer ? [
                'id' => $this->changer->id,
                'name' => $this->changer->name,
                'role' => $this->enum($this->changer->role),
            ] : null),
            'note' => $this->note,
            'created_at' => $this->date($this->created_at),
        ];
    }
}
