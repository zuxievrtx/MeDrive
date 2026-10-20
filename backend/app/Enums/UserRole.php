<?php

namespace App\Enums;

enum UserRole: string
{
    case Pelapor = 'pelapor';
    case Driver = 'driver';
    case Admin = 'admin';

    public function label(): string
    {
        return match ($this) {
            self::Pelapor => 'Pelapor',
            self::Driver => 'Driver',
            self::Admin => 'Admin',
        };
    }
}
