<?php

namespace App\Broadcasting;

use Illuminate\Broadcasting\Broadcasters\PusherBroadcaster;
use Illuminate\Broadcasting\BroadcastException;
use Illuminate\Support\Facades\Log;

/**
 * Broadcaster Reverb yang tidak menggagalkan request bila server WebSocket mati.
 *
 * Event memakai ShouldBroadcastNow, jadi tanpa ini gangguan Reverb membuat pembuatan laporan,
 * pengambilan laporan, dan flush lokasi ikut gagal. Klien (dashboard, Flutter) sudah punya
 * fallback polling, sehingga event yang hilang cukup dicatat.
 */
class ResilientPusherBroadcaster extends PusherBroadcaster
{
    /**
     * @param  array<int, mixed>  $channels
     * @param  string  $event
     * @param  array<string, mixed>  $payload
     */
    public function broadcast(array $channels, $event, array $payload = []): void
    {
        try {
            parent::broadcast($channels, $event, $payload);
        } catch (BroadcastException $exception) {
            Log::warning('Broadcast realtime gagal dikirim; klien memakai polling.', [
                'event' => $event,
                'channels' => array_map('strval', $channels),
                'error' => $exception->getMessage(),
            ]);
        }
    }
}
