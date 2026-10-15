<?php

namespace App\Http\Resources;

use BackedEnum;
use DateTimeInterface;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Dasar resource API: format tanggal ISO 8601 dan enum sebagai { value, label, tone }.
 */
abstract class ApiResource extends JsonResource
{
    protected function date(?DateTimeInterface $value): ?string
    {
        return $value?->format(DATE_ATOM);
    }

    protected function day(?DateTimeInterface $value): ?string
    {
        return $value?->format('Y-m-d');
    }

    /**
     * @return array{value: string, label: string, tone?: string}|null
     */
    protected function enum(?BackedEnum $value): ?array
    {
        if ($value === null) {
            return null;
        }

        $payload = ['value' => (string) $value->value, 'label' => method_exists($value, 'label') ? $value->label() : (string) $value->value];

        if (method_exists($value, 'tone')) {
            $payload['tone'] = $value->tone();
        }

        return $payload;
    }
}
