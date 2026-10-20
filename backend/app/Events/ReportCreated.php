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
 * Laporan baru masuk dari aplikasi pelapor; ditampilkan sebagai toast + badge di dashboard admin.
 * Dikirim setelah transaksi commit agar dashboard tidak menerima laporan yang batal tersimpan.
 */
class ReportCreated implements ShouldBroadcastNow, ShouldDispatchAfterCommit
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(public Report $report) {}

    /**
     * @return array<int, PrivateChannel>
     */
    public function broadcastOn(): array
    {
        return [new PrivateChannel('admin')];
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
            'status' => $this->report->status?->value ?? 'menunggu',
            'type' => [
                'name' => $this->report->reportType?->name,
                'icon' => $this->report->reportType?->icon,
                'color' => $this->report->reportType?->color,
                'priority' => $this->report->reportType?->priority,
            ],
        ];
    }
}
