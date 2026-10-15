<?php

namespace App\Http\Requests\Api\V1\Driver;

use App\Http\Requests\Api\V1\ApiFormRequest;

class HandlingPhotosRequest extends ApiFormRequest
{
    /**
     * @return array<string, array<int, string>>
     */
    public function rules(): array
    {
        return [
            'photos' => ['required', 'array', 'min:1', 'max:'.(int) config('medrive.attachments.max_files')],
            'photos.*' => ['image', 'mimes:jpg,jpeg,png', 'max:'.(int) config('medrive.attachments.max_kb')],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return ['photos' => 'foto', 'photos.*' => 'foto'];
    }
}
