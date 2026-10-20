<?php

namespace App\Http\Resources;

use App\Models\AdminActivityLog;
use Illuminate\Http\Request;

/** @mixin AdminActivityLog */
class ActivityLogResource extends ApiResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'admin' => $this->whenLoaded('admin', fn (): ?array => $this->admin ? ['id' => $this->admin->id, 'name' => $this->admin->name] : null),
            'action' => $this->action,
            'module' => $this->module(),
            'verb' => explode('.', $this->action, 2)[1] ?? '',
            'subject_type' => $this->subject_type,
            'subject_id' => $this->subject_id,
            'description' => $this->description,
            'ip_address' => $this->ip_address,
            'created_at' => $this->date($this->created_at),
        ];
    }
}
