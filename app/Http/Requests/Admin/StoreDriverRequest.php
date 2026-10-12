<?php

namespace App\Http\Requests\Admin;

use App\Enums\LicenseClass;
use App\Models\User;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password;

class StoreDriverRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('create', User::class);
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'email' => mb_strtolower(trim((string) $this->input('email'))),
            'employee_number' => $this->filled('employee_number') ? trim((string) $this->input('employee_number')) : null,
            'must_change_password' => $this->boolean('must_change_password'),
            'certifications' => collect($this->input('certifications', []))
                ->filter(fn ($certification): bool => is_array($certification) && filled($certification['name'] ?? null))
                ->values()
                ->all(),
        ]);
    }

    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:100'],
            'phone' => ['required', 'string', 'max:20', 'regex:/^[0-9+\-\s]{8,20}$/'],
            'email' => ['required', 'email', 'max:100', Rule::unique('users', 'email')],
            'password' => ['required', 'string', Password::min(8)],
            'must_change_password' => ['boolean'],
            'clinic_id' => ['required', 'integer', Rule::exists('clinics', 'id')],
            'employee_number' => [
                'nullable',
                'string',
                'max:30',
                Rule::unique('driver_profiles', 'employee_number')->where('clinic_id', $this->integer('clinic_id')),
            ],
            'license_number' => ['required', 'string', 'max:30'],
            'license_class' => ['required', Rule::enum(LicenseClass::class)],
            'license_expires_at' => ['required', 'date', 'after_or_equal:tomorrow'],
            'photo' => ['nullable', 'image', 'mimes:jpg,jpeg,png', 'max:2048'],
            ...DriverCertificationRequest::arrayRules('certifications.*.'),
            'certifications' => ['array', 'max:10'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return [
            ...DriverCertificationRequest::attributeNames(),
            'clinic_id' => 'klinik',
            'employee_number' => 'nomor pegawai',
            'license_number' => 'nomor SIM',
            'license_class' => 'golongan SIM',
            'license_expires_at' => 'masa berlaku SIM',
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'employee_number.unique' => 'Nomor pegawai ini sudah dipakai driver lain di klinik yang sama.',
            'license_expires_at.after_or_equal' => 'SIM harus masih berlaku minimal sampai besok.',
            'phone.regex' => 'Nomor telepon hanya boleh berisi angka, spasi, tanda + atau -.',
        ];
    }
}
