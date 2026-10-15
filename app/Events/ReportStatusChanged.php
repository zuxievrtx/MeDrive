<?php

namespace App\Events;

use App\Models\Report;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Contracts\Events\ShouldDispatchAfterCommit;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

/**
 * Setiap transisi status laporan: pelapor (kanal report.{id}) langsung tahu ambulans
 * dalam perjalanan / tiba, dan dashboard admin memperbarui daftar.
 */
class ReportStatusChanged implements ShouldBroadcastNow, ShouldDispatchAfterCommit
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(public Report $report, public ?string $fromStatus) {}

    /**
     * @return array<int, PrivateChannel>
     */
    public function broadcastOn(): array
    {
        return [new PrivateChannel('report.'.$this->report->id), new PrivateChannel('admin')];
    }

    public function broadcastAs(): string
    {
        return 'ReportStatusChanged';
    }

    /**
     * @return array<string, mixed>
     */
    public function broadcastWith(): array
    {
        $this->report->loadMissing(['driver:id,name,phone', 'ambulance:id,plate_number']);

        return [
            'id' => $this->report->id,
            'code' => $this->report->code,
            'from_status' => $this->fromStatus,
            'status' => $this->report->status->value,
            'status_label' => $this->report->status->label(),
            'driver' => $this->report->driver ? ['id' => $this->report->driver->id, 'name' => $this->report->driver->name, 'phone' => $this->report->driver->phone] : null,
            'ambulance' => $this->report->ambulance ? ['plate_number' => $this->report->ambulance->plate_number] : null,
            'taken_at' => $this->report->taken_at?->toIso8601String(),
            'arrived_at' => $this->report->arrived_at?->toIso8601String(),
            'completed_at' => $this->report->completed_at?->toIso8601String(),
            'changed_at' => now()->toIso8601String(),
        ];
    }
}
