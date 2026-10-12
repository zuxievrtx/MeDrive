<?php

namespace App\Enums;

enum AccountStatus: string
{
    case Aktif = 'aktif';
    case Nonaktif = 'nonaktif';

    public function label(): string
    {
        return match ($this) {
            self::Aktif => 'Aktif',
            self::Nonaktif => 'Nonaktif',
        };
    }

    public function tone(): string
    {
        return match ($this) {
            self::Aktif => 'green',
            self::Nonaktif => 'gray',
        };
    }
}
