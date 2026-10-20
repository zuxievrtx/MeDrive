<?php

namespace App\Enums;

enum InstitutionType: string
{
    case Pemerintah = 'pemerintah';
    case Swasta = 'swasta';
    case Sosial = 'sosial';

    public function label(): string
    {
        return ucfirst($this->value);
    }
}
