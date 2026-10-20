<?php

namespace App\Http\Resources;

use App\Models\ReportPatient;
use App\Support\Label;
use Illuminate\Http\Request;

/** @mixin ReportPatient */
class ReportPatientResource extends ApiResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'gender' => $this->gender,
            'age_estimate' => $this->age_estimate,
            'consciousness' => ['value' => $this->consciousness, 'label' => Label::humanize($this->consciousness)],
            'is_breathing' => $this->is_breathing,
            'condition_note' => $this->condition_note,
            'handed_over_to' => $this->handed_over_to,
            'handed_over_at' => $this->date($this->handed_over_at),
        ];
    }
}
