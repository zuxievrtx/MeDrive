<?php

namespace App\Http\Requests\Admin;

use App\Enums\AmbulanceStatus;
use App\Models\Ambulance;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AmbulanceRequest extends FormRequest
{
    public function authorize(): bool
    {
        $ambulance = $this->route('ambulance');

        return $ambulance
            ? $this->user()->can('update', $ambulance)
            : $this->user()->can('create', Ambulance::class);
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'plate_number' => mb_strtoupper(preg_replace('/\s+/', ' ', trim((string) $this->input('plate_number')))),
        ]);
    }

    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        return [
            'clinic_id' => ['required', 'integer', Rule::exists('clinics', 'id')],
            'ambulance_type_id' => ['required', 'integer', Rule::exists('ambulance_types', 'id')],
            'plate_number' => ['required', 'string', 'max:15', 'regex:/^[A-Z]{1,2} \d{1,4}( [A-Z]{1,3})?$/', Rule::unique('ambulances', 'plate_number')->ignore($this->route('ambulance'))],
            'vehicle_name' => ['nullable', 'string', 'max:100'],
            'year' => ['nullable', 'integer', 'digits:4', 'min:1980', 'max:'.(now()->year + 1)],
            'status' => ['required', Rule::enum(AmbulanceStatus::class)],
            'notes' => ['nullable', 'string', 'max:255'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return [
            'clinic_id' => 'klinik',
            'ambulance_type_id' => 'jenis ambulans',
            'plate_number' => 'nomor polisi',
            'vehicle_name' => 'nama kendaraan',
            'year' => 'tahun',
            'notes' => 'catatan',
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'plate_number.regex' => 'Format nomor polisi seperti H 1234 AB (huruf wilayah, angka, huruf akhir).',
        ];
    }
}
