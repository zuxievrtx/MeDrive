<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Validation\Rules\Password;

class ChangePasswordRequest extends ApiFormRequest
{
    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        return [
            'current_password' => ['required', 'string', 'current_password:sanctum'],
            'password' => ['required', 'string', 'confirmed', 'different:current_password', Password::min(8)],
        ];
    }
}
