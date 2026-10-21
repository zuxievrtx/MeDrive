<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Pesan chat pelapor ↔ driver. Immutable: tidak ada edit/hapus, hanya read_at yang berubah.
 */
class ChatMessage extends Model
{
    public const UPDATED_AT = null;

    public const TYPE_TEXT = 'text';

    public const TYPE_IMAGE = 'image';

    protected $fillable = ['report_id', 'sender_id', 'type', 'body', 'file_path', 'mime_type', 'size_kb', 'read_at'];

    protected function casts(): array
    {
        return [
            'size_kb' => 'integer',
            'read_at' => 'datetime',
            'created_at' => 'datetime',
        ];
    }

    /**
     * @return BelongsTo<Report, $this>
     */
    public function report(): BelongsTo
    {
        return $this->belongsTo(Report::class);
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sender_id');
    }
}
