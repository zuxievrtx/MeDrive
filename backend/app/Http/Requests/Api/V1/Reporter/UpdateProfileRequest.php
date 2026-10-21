<?php

namespace App\Http\Requests\Api\V1\Reporter;

use App\Http\Requests\Api\V1\ApiFormRequest;

/**
 * Pelapor hanya bisa mengubah nama dan telepon; email dan role tidak ikut divalidasi sehingga diabaikan.
 */
class UpdateProfileRequest extends ApiFormRequest
{
    /**
     * @return array<string, array<int, string>>
     */
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:100'],
            'phone' => ['required', 'string', 'max:20', 'regex:/^[0-9+\-\s]{8,20}$/'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return ['name' => 'nama', 'phone' => 'nomor telepon'];
    }
}
