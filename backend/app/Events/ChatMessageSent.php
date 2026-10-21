<?php

namespace App\Events;

use App\Http\Resources\ChatMessageResource;
use App\Models\ChatMessage;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;

/**
 * Pesan chat baru untuk kedua peserta (kanal chat.{report_id}). Admin tidak bisa subscribe kanal ini.
 */
class ChatMessageSent implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets;

    public function __construct(public ChatMessage $message) {}

    /**
     * @return array<int, PrivateChannel>
     */
    public function broadcastOn(): array
    {
        return [new PrivateChannel('chat.'.$this->message->report_id)];
    }

    public function broadcastAs(): string
    {
        return 'ChatMessageSent';
    }

    /**
     * @return array<string, mixed>
     */
    public function broadcastWith(): array
    {
        return ChatMessageResource::make($this->message)->forBroadcast();
    }
}
