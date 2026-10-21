<?php

namespace App\Http\Resources;

use App\Models\ChatMessage;
use Illuminate\Http\Request;

/** @mixin ChatMessage */
class ChatMessageResource extends ApiResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            ...$this->forBroadcast(),
            'is_mine' => $request->user()?->id === $this->sender_id,
        ];
    }

    /**
     * Payload yang sama untuk respons API dan event ChatMessageSent (tanpa konteks penerima).
     *
     * @return array<string, mixed>
     */
    public function forBroadcast(): array
    {
        return [
            'id' => $this->id,
            'report_id' => $this->report_id,
            'sender_id' => $this->sender_id,
            'sender_name' => $this->sender?->name,
            'type' => $this->type,
            'body' => $this->body,
            'image_url' => $this->file_path ? route('api.v1.media', ['type' => 'chat', 'id' => $this->id]) : null,
            'mime_type' => $this->mime_type,
            'size_kb' => $this->size_kb,
            'read_at' => $this->date($this->read_at),
            'created_at' => $this->date($this->created_at),
        ];
    }
}
