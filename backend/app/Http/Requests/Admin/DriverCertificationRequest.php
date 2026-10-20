<?php

namespace App\Http\Requests\Admin;

use App\Models\DriverCertification;
use Illuminate\Foundation\Http\FormRequest;

class DriverCertificationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('create', DriverCertification::class);
    }

    /**
     * Aturan satu sertifikat; dipakai ulang oleh form tambah driver (prefix certifications.*.).
     *
     * @return array<string, array<int, string>>
     */
    public static function arrayRules(string $prefix = ''): array
    {
        return [
            $prefix.'name' => ['required', 'string', 'max:100'],
            $prefix.'certificate_number' => ['nullable', 'string', 'max:50'],
            $prefix.'issuer' => ['nullable', 'string', 'max:150'],
            $prefix.'issued_at' => ['required', 'date', 'before_or_equal:today'],
            $prefix.'expires_at' => ['nullable', 'date', 'after:'.$prefix.'issued_at'],
            $prefix.'file' => ['nullable', 'file', 'mimes:pdf,jpg,jpeg,png', 'max:5120'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public static function attributeNames(): array
    {
        return [
            'name' => 'nama sertifikat',
            'certificate_number' => 'nomor sertifikat',
            'issuer' => 'penerbit',
            'issued_at' => 'tanggal terbit',
            'expires_at' => 'tanggal kedaluwarsa',
            'file' => 'berkas sertifikat',
            'certifications.*.name' => 'nama sertifikat',
            'certifications.*.certificate_number' => 'nomor sertifikat',
            'certifications.*.issuer' => 'penerbit',
            'certifications.*.issued_at' => 'tanggal terbit',
            'certifications.*.expires_at' => 'tanggal kedaluwarsa',
            'certifications.*.file' => 'berkas sertifikat',
        ];
    }

    /**
     * @return array<string, array<int, string>>
     */
    public function rules(): array
    {
        return self::arrayRules();
    }

    /**
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return self::attributeNames();
    }
}
