<?php

namespace App\Services;

use App\Models\AdminActivityLog;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\Request;

/**
 * Mencatat setiap aksi tulis admin ke admin_activity_logs dengan format aksi {modul}.{verb}.
 */
class AdminLogger
{
    public function __construct(private Request $request) {}

    public function log(string $action, Model $subject, string $description): AdminActivityLog
    {
        return AdminActivityLog::create([
            'admin_id' => $this->request->user()?->getKey(),
            'action' => $action,
            'subject_type' => $subject->getTable(),
            'subject_id' => $subject->getKey(),
            'description' => mb_substr($description, 0, 255),
            'ip_address' => $this->request->ip(),
        ]);
    }

    /**
     * Ringkas perubahan atribut menjadi "field: lama -> baru" untuk deskripsi log.
     *
     * @param  array<string, mixed>  $original
     * @param  array<string, mixed>  $changes
     */
    public static function describeChanges(array $original, array $changes): string
    {
        return collect($changes)
            ->except(['updated_at', 'password'])
            ->map(function (mixed $value, string $field) use ($original): string {
                return $field.': '.self::stringify($original[$field] ?? null).' -> '.self::stringify($value);
            })
            ->implode('; ');
    }

    private static function stringify(mixed $value): string
    {
        return match (true) {
            $value === null || $value === '' => 'kosong',
            is_bool($value) => $value ? 'ya' : 'tidak',
            $value instanceof \BackedEnum => (string) $value->value,
            $value instanceof \DateTimeInterface => $value->format('Y-m-d'),
            default => (string) $value,
        };
    }
}
