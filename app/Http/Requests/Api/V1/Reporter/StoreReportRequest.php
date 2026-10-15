<?php

namespace App\Http\Requests\Api\V1\Reporter;

use App\Http\Requests\Api\V1\ApiFormRequest;
use App\Models\ReportType;
use Illuminate\Validation\Rule;

class StoreReportRequest extends ApiFormRequest
{
    private ?ReportType $reportType = null;

    public function reportType(): ReportType
    {
        return $this->reportType ??= ReportType::query()->where('code', $this->input('report_type_code'))->where('is_active', true)->firstOrFail();
    }

    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        $type = ReportType::query()->where('code', $this->input('report_type_code'))->where('is_active', true)->first();
        $maxFiles = (int) config('medrive.attachments.max_files');
        $maxKb = (int) config('medrive.attachments.max_kb');

        return [
            'report_type_code' => ['required', 'string', Rule::exists('report_types', 'code')->where('is_active', true)],
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'address' => ['nullable', 'string', 'max:255'],
            'description' => ['required', 'string', 'max:500'],
            ...$this->destinationRules($type),
            ...$this->detailRules($type),
            'photos' => ['nullable', 'array', 'max:'.$maxFiles],
            'photos.*' => ['image', 'mimes:jpg,jpeg,png', 'max:'.$maxKb],
            'death_certificate' => [Rule::prohibitedIf($type?->detailKind() !== 'funeral'), 'nullable', 'file', 'mimes:pdf,jpg,jpeg,png', 'max:'.$maxKb],
        ];
    }

    /**
     * Tujuan wajib untuk jenis requires_destination: pilih faskes terdaftar atau isi nama + koordinat.
     *
     * @return array<string, array<int, mixed>>
     */
    private function destinationRules(?ReportType $type): array
    {
        $required = (bool) $type?->requires_destination;
        $manualRequired = $required && ! $this->filled('destination_clinic_id');

        return [
            'destination_clinic_id' => ['nullable', 'integer', Rule::exists('clinics', 'id')->where('is_active', true)],
            'destination_name' => [Rule::requiredIf($manualRequired), 'nullable', 'string', 'max:150'],
            'destination_address' => ['nullable', 'string', 'max:255'],
            'destination_lat' => [Rule::requiredIf($manualRequired), 'nullable', 'numeric', 'between:-90,90', 'required_with:destination_lng'],
            'destination_lng' => [Rule::requiredIf($manualRequired), 'nullable', 'numeric', 'between:-180,180', 'required_with:destination_lat'],
        ];
    }

    /**
     * Kolom detail mengikuti tabel detail v3 sesuai jenis laporan.
     *
     * @return array<string, array<int, mixed>>
     */
    private function detailRules(?ReportType $type): array
    {
        return match ($type?->detailKind()) {
            'accident' => [
                'details.accident_type' => ['required', 'in:tunggal,tabrakan,tertabrak,lainnya'],
                'details.estimated_victim_count' => ['nullable', 'integer', 'between:1,255'],
                'details.has_trapped_victim' => ['nullable', 'boolean'],
                'details.has_fire_hazard' => ['nullable', 'boolean'],
                'details.is_road_blocked' => ['nullable', 'boolean'],
            ],
            'medical' => [
                'details.medical_category' => ['required', 'in:jantung,stroke,sesak_napas,kejang,tidak_sadar,cedera,keracunan,lainnya'],
                'details.symptom_onset_at' => ['nullable', 'date', 'before_or_equal:now'],
                'details.has_medical_history' => ['nullable', 'boolean'],
                'details.medical_history_notes' => ['nullable', 'string', 'max:255'],
            ],
            'maternity' => [
                'details.gestational_age_weeks' => ['nullable', 'integer', 'between:1,45'],
                'details.contraction_interval_minutes' => ['nullable', 'integer', 'between:0,255'],
                'details.is_water_broken' => ['nullable', 'boolean'],
                'details.has_bleeding' => ['nullable', 'boolean'],
                'details.pregnancy_number' => ['nullable', 'integer', 'between:1,30'],
            ],
            'funeral' => [
                'details.deceased_name' => ['required', 'string', 'max:100'],
                'details.pickup_place_type' => ['required', 'in:rumah_sakit,rumah_duka,lainnya'],
                'details.scheduled_pickup_at' => ['nullable', 'date', 'after_or_equal:now'],
                'details.has_death_certificate' => ['nullable', 'boolean'],
                'details.family_contact_name' => ['required', 'string', 'max:100'],
                'details.family_contact_phone' => ['required', 'string', 'max:20'],
            ],
            default => [],
        };
    }

    /**
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return [
            'report_type_code' => 'jenis laporan',
            'destination_clinic_id' => 'faskes tujuan',
            'destination_name' => 'nama tujuan',
            'destination_lat' => 'latitude tujuan',
            'destination_lng' => 'longitude tujuan',
            'photos' => 'foto',
            'photos.*' => 'foto',
            'death_certificate' => 'surat kematian',
            'details.accident_type' => 'jenis kecelakaan',
            'details.estimated_victim_count' => 'perkiraan korban',
            'details.medical_category' => 'kategori medis',
            'details.symptom_onset_at' => 'waktu gejala mulai',
            'details.gestational_age_weeks' => 'usia kehamilan',
            'details.contraction_interval_minutes' => 'jarak kontraksi',
            'details.pregnancy_number' => 'kehamilan ke-',
            'details.deceased_name' => 'nama almarhum',
            'details.pickup_place_type' => 'tempat jemput',
            'details.scheduled_pickup_at' => 'jadwal jemput',
            'details.family_contact_name' => 'nama kontak keluarga',
            'details.family_contact_phone' => 'telepon kontak keluarga',
        ];
    }
}
