<?php

namespace App\Http\Requests\Admin;

use App\Enums\InstitutionType;
use App\Models\Institution;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class InstitutionRequest extends FormRequest
{
    public function authorize(): bool
    {
        $institution = $this->route('institution');

        return $institution
            ? $this->user()->can('update', $institution)
            : $this->user()->can('create', Institution::class);
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'code' => mb_strtoupper(trim((string) $this->input('code'))),
            'is_active' => $this->boolean('is_active'),
        ]);
    }

    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        return [
            'code' => ['required', 'string', 'max:20', Rule::unique('institutions', 'code')->ignore($this->route('institution'))],
            'name' => ['required', 'string', 'max:150'],
            'type' => ['required', Rule::enum(InstitutionType::class)],
            'phone' => ['nullable', 'string', 'max:20'],
            'email' => ['nullable', 'email', 'max:100'],
            'address' => ['nullable', 'string', 'max:255'],
            'is_active' => ['boolean'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return ['code' => 'kode', 'name' => 'nama', 'type' => 'jenis', 'address' => 'alamat'];
    }
}
