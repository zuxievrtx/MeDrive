<?php

namespace App\Http\Resources;

use App\Models\Institution;
use Illuminate\Http\Request;

/** @mixin Institution */
class InstitutionResource extends ApiResource
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
            'type' => $this->enum($this->type),
            'phone' => $this->phone,
            'email' => $this->email,
            'address' => $this->address,
            'is_active' => (bool) $this->is_active,
            'clinics_count' => $this->whenCounted('clinics'),
        ];
    }
}
