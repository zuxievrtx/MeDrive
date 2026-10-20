<?php

namespace App\Enums;

enum LicenseClass: string
{
    case A = 'A';
    case AUmum = 'A_umum';
    case B1 = 'B1';
    case B1Umum = 'B1_umum';
    case B2 = 'B2';
    case B2Umum = 'B2_umum';

    public function label(): string
    {
        return str_replace('_umum', ' Umum', $this->value);
    }
}
