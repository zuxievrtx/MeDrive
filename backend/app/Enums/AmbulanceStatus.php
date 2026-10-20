<?php

namespace App\Enums;

enum AmbulanceStatus: string
{
    case Tersedia = 'tersedia';
    case Perawatan = 'perawatan';
    case Nonaktif = 'nonaktif';

    public function label(): string
    {
        return match ($this) {
            self::Tersedia => 'Tersedia',
            self::Perawatan => 'Perawatan',
            self::Nonaktif => 'Nonaktif',
        };
    }

    public function tone(): string
    {
        return match ($this) {
            self::Tersedia => 'green',
            self::Perawatan => 'amber',
            self::Nonaktif => 'gray',
        };
    }
}
