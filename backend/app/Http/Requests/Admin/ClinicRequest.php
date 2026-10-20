<?php

namespace App\Http\Requests\Admin;

use App\Enums\ClinicType;
use App\Models\Clinic;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class ClinicRequest extends FormRequest
{
    public function authorize(): bool
    {
        $clinic = $this->route('clinic');

        return $clinic
            ? $this->user()->can('update', $clinic)
            : $this->user()->can('create', Clinic::class);
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
            'institution_id' => ['required', 'integer', Rule::exists('institutions', 'id')],
            'code' => ['required', 'string', 'max:20', Rule::unique('clinics', 'code')->ignore($this->route('clinic'))],
            'name' => ['required', 'string', 'max:150'],
            'type' => ['required', Rule::enum(ClinicType::class)],
            'phone' => ['nullable', 'string', 'max:20'],
            'address' => ['required', 'string', 'max:255'],
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'is_active' => ['boolean'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return [
            'institution_id' => 'instansi',
            'code' => 'kode',
            'name' => 'nama',
            'type' => 'jenis',
            'address' => 'alamat',
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'latitude.required' => 'Tentukan titik lokasi klinik di peta atau isi latitude.',
            'longitude.required' => 'Tentukan titik lokasi klinik di peta atau isi longitude.',
        ];
    }
}
