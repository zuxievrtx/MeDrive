<?php

namespace App\Enums;

enum DispatchResponse: string
{
    case Menunggu = 'menunggu';
    case Diambil = 'diambil';
    case KalahCepat = 'kalah_cepat';
    case Diabaikan = 'diabaikan';
    case Kedaluwarsa = 'kedaluwarsa';

    public function label(): string
    {
        return match ($this) {
            self::Menunggu => 'Menunggu',
            self::Diambil => 'Diambil',
            self::KalahCepat => 'Kalah cepat',
            self::Diabaikan => 'Diabaikan',
            self::Kedaluwarsa => 'Kedaluwarsa',
        };
    }

    public function tone(): string
    {
        return match ($this) {
            self::Menunggu => 'amber',
            self::Diambil => 'green',
            self::KalahCepat => 'gray',
            self::Diabaikan => 'amber',
            self::Kedaluwarsa => 'red',
        };
    }
}
