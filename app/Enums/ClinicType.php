<?php

namespace App\Enums;

enum ClinicType: string
{
    case Klinik = 'klinik';
    case Puskesmas = 'puskesmas';
    case RumahSakit = 'rumah_sakit';
    case PosAmbulans = 'pos_ambulans';

    public function label(): string
    {
        return match ($this) {
            self::Klinik => 'Klinik',
            self::Puskesmas => 'Puskesmas',
            self::RumahSakit => 'Rumah Sakit',
            self::PosAmbulans => 'Pos Ambulans',
        };
    }
}
