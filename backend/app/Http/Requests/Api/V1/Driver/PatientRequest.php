<?php

namespace App\Http\Requests\Api\V1\Driver;

use App\Http\Requests\Api\V1\ApiFormRequest;

class PatientRequest extends ApiFormRequest
{
    /**
     * @return array<string, array<int, string>>
     */
    public function rules(): array
    {
        return [
            'name' => ['nullable', 'string', 'max:100'],
            'gender' => ['nullable', 'in:L,P'],
            'age_estimate' => ['nullable', 'integer', 'between:0,130'],
            'consciousness' => ['nullable', 'in:sadar,tidak_sadar,tidak_diketahui'],
            'is_breathing' => ['nullable', 'boolean'],
            'condition_note' => ['nullable', 'string', 'max:255'],
            'handed_over_to' => ['nullable', 'string', 'max:150'],
            'handed_over_at' => ['nullable', 'date', 'before_or_equal:now'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return [
            'gender' => 'jenis kelamin',
            'age_estimate' => 'perkiraan usia',
            'consciousness' => 'kesadaran',
            'is_breathing' => 'status napas',
            'condition_note' => 'kondisi',
            'handed_over_to' => 'diserahkan kepada',
            'handed_over_at' => 'waktu serah terima',
        ];
    }
}
