<?php

namespace App\Http\Requests\Admin;

use App\Enums\LicenseClass;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password;

class UpdateDriverRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('update', $this->route('driver'));
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'email' => mb_strtolower(trim((string) $this->input('email'))),
            'employee_number' => $this->filled('employee_number') ? trim((string) $this->input('employee_number')) : null,
        ]);
    }

    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        $driverId = $this->route('driver')?->id;

        return [
            'name' => ['required', 'string', 'max:100'],
            'phone' => ['required', 'string', 'max:20', 'regex:/^[0-9+\-\s]{8,20}$/'],
            'email' => ['required', 'email', 'max:100', Rule::unique('users', 'email')->ignore($driverId)],
            'new_password' => ['nullable', 'string', Password::min(8)],
            'clinic_id' => ['required', 'integer', Rule::exists('clinics', 'id')],
            'employee_number' => [
                'nullable',
                'string',
                'max:30',
                Rule::unique('driver_profiles', 'employee_number')
                    ->where('clinic_id', $this->integer('clinic_id'))
                    ->ignore($driverId, 'user_id'),
            ],
            'license_number' => ['required', 'string', 'max:30'],
            'license_class' => ['required', Rule::enum(LicenseClass::class)],
            'license_expires_at' => ['required', 'date'],
            'photo' => ['nullable', 'image', 'mimes:jpg,jpeg,png', 'max:2048'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return [
            'clinic_id' => 'klinik',
            'employee_number' => 'nomor pegawai',
            'license_number' => 'nomor SIM',
            'license_class' => 'golongan SIM',
            'license_expires_at' => 'masa berlaku SIM',
            'new_password' => 'password baru',
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'employee_number.unique' => 'Nomor pegawai ini sudah dipakai driver lain di klinik yang sama.',
            'phone.regex' => 'Nomor telepon hanya boleh berisi angka, spasi, tanda + atau -.',
        ];
    }
}
