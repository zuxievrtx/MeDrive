<?php

namespace App\Events;

use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;

/**
 * Tanda baca: semua pesan lawan bicara sampai last_read_id sudah dibaca reader_id.
 */
class ChatMessageRead implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets;

    public function __construct(
        public int $reportId,
        public int $readerId,
        public int $lastReadId,
        public string $readAt,
    ) {}

    /**
     * @return array<int, PrivateChannel>
     */
    public function broadcastOn(): array
    {
        return [new PrivateChannel('chat.'.$this->reportId)];
    }

    public function broadcastAs(): string
    {
        return 'ChatMessageRead';
    }

    /**
     * @return array{report_id: int, reader_id: int, last_read_id: int, read_at: string}
     */
    public function broadcastWith(): array
    {
        return [
            'report_id' => $this->reportId,
            'reader_id' => $this->readerId,
            'last_read_id' => $this->lastReadId,
            'read_at' => $this->readAt,
        ];
    }
}
