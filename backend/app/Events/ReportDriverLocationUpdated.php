<?php

namespace App\Events;

use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;

/**
 * Posisi ambulans untuk pelapor pemilik laporan aktif (kanal report.{id}). Payload sengaja minimal;
 * aplikasi menginterpolasi marker di antara dua update agar gerakan tetap halus.
 */
class ReportDriverLocationUpdated implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets;

    /**
     * @param  array{lat: float, lng: float, heading: ?int, speed_kmh: ?float, updated_at: string}  $location
     */
    public function __construct(public int $reportId, public array $location) {}

    /**
     * @return array<int, PrivateChannel>
     */
    public function broadcastOn(): array
    {
        return [new PrivateChannel('report.'.$this->reportId)];
    }

    public function broadcastAs(): string
    {
        return 'DriverLocationUpdated';
    }

    /**
     * @return array<string, mixed>
     */
    public function broadcastWith(): array
    {
        return $this->location;
    }
}
