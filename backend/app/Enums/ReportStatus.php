<?php

namespace App\Enums;

enum ReportStatus: string
{
    case Menunggu = 'menunggu';
    case Diambil = 'diambil';
    case DalamPerjalanan = 'dalam_perjalanan';
    case TibaDiLokasi = 'tiba_di_lokasi';
    case MengantarPasien = 'mengantar_pasien';
    case Selesai = 'selesai';
    case Dibatalkan = 'dibatalkan';

    public function label(): string
    {
        return match ($this) {
            self::Menunggu => 'Menunggu',
            self::Diambil => 'Diambil',
            self::DalamPerjalanan => 'Dalam Perjalanan',
            self::TibaDiLokasi => 'Tiba di Lokasi',
            self::MengantarPasien => 'Mengantar Pasien',
            self::Selesai => 'Selesai',
            self::Dibatalkan => 'Dibatalkan',
        };
    }

    public function tone(): string
    {
        return match ($this) {
            self::Menunggu => 'amber',
            self::Diambil => 'blue',
            self::DalamPerjalanan => 'violet',
            self::TibaDiLokasi => 'cyan',
            self::MengantarPasien => 'teal',
            self::Selesai => 'green',
            self::Dibatalkan => 'gray',
        };
    }

    /**
     * Status setelah diambil driver dan sebelum selesai.
     *
     * @return list<self>
     */
    public static function active(): array
    {
        return [self::Diambil, self::DalamPerjalanan, self::TibaDiLokasi, self::MengantarPasien];
    }

    /**
     * @return list<string>
     */
    public static function activeValues(): array
    {
        return array_map(fn (self $status): string => $status->value, self::active());
    }
}
