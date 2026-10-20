<?php

namespace App\Events;

use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;

/**
 * Posisi terbaru driver untuk Peta Live. Dikirim oleh pipeline lokasi (Redis buffer) setiap ping diterima,
 * sehingga dashboard tidak perlu membaca driver_location_logs untuk tampilan real-time.
 */
class DriverLocationUpdated implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets;

    /**
     * @param  array{
     *     driver_id: int,
     *     name: string,
     *     plate_number: ?string,
     *     ambulance_type: ?string,
     *     lat: float,
     *     lng: float,
     *     speed_kmh: ?float,
     *     heading: ?int,
     *     battery_level: ?int,
     *     accuracy_m: ?float,
     *     is_on_duty: bool,
     *     report_code: ?string,
     *     report_status: ?string,
     *     recorded_at: string
     * }  $payload
     */
    public function __construct(public array $payload) {}

    /**
     * @return array<int, PrivateChannel>
     */
    public function broadcastOn(): array
    {
        return [new PrivateChannel('admin.tracking')];
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
        return $this->payload;
    }
}
