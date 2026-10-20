<?php

namespace App\Enums;

enum ShiftEndReason: string
{
    case SelesaiShift = 'selesai_shift';
    case Otomatis = 'otomatis';
    case DihentikanAdmin = 'dihentikan_admin';

    public function label(): string
    {
        return match ($this) {
            self::SelesaiShift => 'Selesai shift',
            self::Otomatis => 'Ditutup otomatis',
            self::DihentikanAdmin => 'Dihentikan admin',
        };
    }
}
