<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class ReportTypeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('update', $this->route('report_type'));
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'is_active' => $this->boolean('is_active'),
            'icon' => $this->filled('icon') ? mb_strtolower(trim((string) $this->input('icon'))) : null,
            'color' => $this->filled('color') ? mb_strtoupper((string) $this->input('color')) : null,
            'ambulance_type_ids' => array_values(array_filter((array) $this->input('ambulance_type_ids', []))),
        ]);
    }

    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:100'],
            'description' => ['nullable', 'string', 'max:255'],
            'priority' => ['required', 'integer', 'between:1,5'],
            'icon' => ['nullable', 'string', 'max:50', 'regex:/^[a-z0-9-]+$/'],
            'color' => ['nullable', 'string', 'regex:/^#[0-9A-F]{6}$/'],
            'is_active' => ['boolean'],
            'sort_order' => ['required', 'integer', 'between:0,255'],
            'ambulance_type_ids' => ['array', Rule::requiredIf($this->boolean('is_active'))],
            'ambulance_type_ids.*' => ['integer', Rule::exists('ambulance_types', 'id')],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return [
            'name' => 'nama',
            'description' => 'deskripsi',
            'priority' => 'prioritas',
            'icon' => 'ikon',
            'color' => 'warna',
            'sort_order' => 'urutan',
            'ambulance_type_ids' => 'jenis ambulans',
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'ambulance_type_ids.required' => 'Jenis laporan aktif harus dilayani minimal satu jenis ambulans, kalau tidak broadcast tidak punya penerima.',
            'icon.regex' => 'Nama ikon memakai huruf kecil, angka, dan tanda hubung (nama ikon Font Awesome, mis. heart-pulse).',
            'color.regex' => 'Warna harus berupa kode hex 6 digit, mis. #B5523B.',
        ];
    }
}
