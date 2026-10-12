<?php

namespace App\Events;

use App\Models\Report;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

/**
 * Laporan baru masuk dari aplikasi pelapor; ditampilkan sebagai toast + badge di dashboard admin.
 */
class ReportCreated implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(public Report $report) {}

    /**
     * @return array<int, PrivateChannel>
     */
    public function broadcastOn(): array
    {
        return [new PrivateChannel('admin.reports')];
    }

    public function broadcastAs(): string
    {
        return 'ReportCreated';
    }

    /**
     * @return array<string, mixed>
     */
    public function broadcastWith(): array
    {
        $this->report->loadMissing('reportType');

        return [
            'id' => $this->report->id,
            'code' => $this->report->code,
            'address' => $this->report->shortAddress(),
            'created_at' => $this->report->created_at?->toIso8601String(),
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
