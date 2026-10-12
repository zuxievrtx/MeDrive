<?php

namespace App\Support;

class Delta
{
    /**
     * Persentase perubahan dibanding periode sebelumnya; null bila periode sebelumnya nol.
     */
    public static function percent(int|float $current, int|float $previous): ?float
    {
        if ((float) $previous === 0.0) {
            return $current == 0 ? 0.0 : null;
        }

        return round((($current - $previous) / $previous) * 100, 1);
    }

    /**
     * @return array{value: int|float, previous: int|float, delta: float|null}
     */
    public static function compare(int|float $current, int|float $previous): array
    {
        return ['value' => $current, 'previous' => $previous, 'delta' => self::percent($current, $previous)];
    }
}
