<?php

namespace App\Support;

use Illuminate\Support\Facades\DB;

/**
 * Ekspresi SQL yang berbeda antara MySQL (produksi) dan SQLite (test) untuk agregasi GROUP BY.
 */
class Sql
{
    public static function isSqlite(): bool
    {
        return DB::connection()->getDriverName() === 'sqlite';
    }

    /**
     * Bucket waktu: 'hour' => Y-m-d H:00, 'day' => Y-m-d, 'month' => Y-m.
     */
    public static function bucket(string $column, string $granularity): string
    {
        $formats = [
            'hour' => ['%Y-%m-%d %H:00', '%Y-%m-%d %H:00'],
            'day' => ['%Y-%m-%d', '%Y-%m-%d'],
            'month' => ['%Y-%m', '%Y-%m'],
        ];

        [$mysqlFormat, $sqliteFormat] = $formats[$granularity];

        return self::isSqlite()
            ? "strftime('{$sqliteFormat}', {$column})"
            : "DATE_FORMAT({$column}, '{$mysqlFormat}')";
    }

    public static function hourOf(string $column): string
    {
        return self::isSqlite()
            ? "CAST(strftime('%H', {$column}) AS INTEGER)"
            : "HOUR({$column})";
    }

    public static function secondsBetween(string $start, string $end): string
    {
        return self::isSqlite()
            ? "((julianday({$end}) - julianday({$start})) * 86400)"
            : "TIMESTAMPDIFF(SECOND, {$start}, {$end})";
    }
}
