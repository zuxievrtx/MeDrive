<?php

namespace App\Http\Requests\Api\V1\Driver;

use App\Http\Requests\Api\V1\ApiFormRequest;

class OpenShiftRequest extends ApiFormRequest
{
    /**
     * @return array<string, array<int, string>>
     */
    public function rules(): array
    {
        return ['ambulance_id' => ['required', 'integer']];
    }

    /**
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return ['ambulance_id' => 'ambulans'];
    }
}
