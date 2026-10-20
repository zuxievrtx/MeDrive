<?php

namespace App\Support;

use Illuminate\Support\Str;

class Label
{
    /**
     * Nilai ENUM snake_case menjadi label baca, mis. "sesak_napas" menjadi "Sesak napas".
     */
    public static function humanize(?string $value): string
    {
        return $value === null || $value === '' ? '-' : Str::ucfirst(str_replace('_', ' ', $value));
    }

    public static function yesNo(?bool $value): string
    {
        return match ($value) {
            true => 'Ya',
            false => 'Tidak',
            null => 'Tidak diketahui',
        };
    }
}
