<?php

namespace App\Events;

use App\Models\Report;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

/**
 * Laporan belum diambil sehingga broadcast diperluas ke ronde berikutnya. Saat ronde terakhir
 * (seluruh area) juga lewat tanpa pengambil, is_final = true dan dashboard menyalakan alarm.
 */
class DispatchEscalated implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(
        public Report $report,
        public int $round,
        public ?float $radiusKm,
        public int $recipients,
        public bool $isFinal = false,
    ) {}

    /**
     * @return array<int, PrivateChannel>
     */
    public function broadcastOn(): array
    {
        return [new PrivateChannel('admin')];
    }

    public function broadcastAs(): string
    {
        return 'DispatchEscalated';
    }

    /**
     * @return array<string, mixed>
     */
    public function broadcastWith(): array
    {
        $this->report->loadMissing('reportType:id,name,icon,color,priority');

        return [
            'id' => $this->report->id,
            'code' => $this->report->code,
            'round' => $this->round,
            'total_rounds' => count(config('medrive.dispatch.radius_rounds_km')),
            'radius_km' => $this->radiusKm,
            'recipients' => $this->recipients,
            'is_final' => $this->isFinal,
            'address' => $this->report->shortAddress(),
            'waiting_minutes' => (int) $this->report->created_at->diffInMinutes(now()),
            'url' => route('admin.reports.show', $this->report),
            'type' => [
                'name' => $this->report->reportType?->name,
                'icon' => $this->report->reportType?->icon,
                'color' => $this->report->reportType?->color,
                'priority' => $this->report->reportType?->priority,
            ],
        ];
    }
}
