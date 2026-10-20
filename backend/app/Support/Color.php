<?php

namespace App\Support;

class Color
{
    /**
     * Pilih teks putih atau gelap yang kontrasnya memenuhi WCAG di atas warna latar (hex).
     */
    public static function readableTextOn(?string $hex): string
    {
        $hex = ltrim($hex ?: '#57534e', '#');

        if (strlen($hex) !== 6 || ! ctype_xdigit($hex)) {
            return '#ffffff';
        }

        $channel = function (int $value): float {
            $value /= 255;

            return $value <= 0.03928 ? $value / 12.92 : (($value + 0.055) / 1.055) ** 2.4;
        };

        $luminance = 0.2126 * $channel(hexdec(substr($hex, 0, 2)))
            + 0.7152 * $channel(hexdec(substr($hex, 2, 2)))
            + 0.0722 * $channel(hexdec(substr($hex, 4, 2)));

        return $luminance > 0.4 ? '#1c1917' : '#ffffff';
    }
}
