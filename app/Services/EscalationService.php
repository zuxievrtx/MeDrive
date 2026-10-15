<?php

namespace App\Services;

use App\Enums\DispatchResponse;
use App\Enums\ReportStatus;
use App\Events\DispatchEscalated;
use App\Models\Report;
use App\Models\ReportDispatch;
use Illuminate\Support\Collection;

/**
 * Dijalankan scheduler tiap menit: laporan yang masih menunggu setelah jeda ronde diperluas radiusnya.
 * Admin tetap tidak menugaskan manual; peringatan hanya memberi tahu bahwa laporan butuh perhatian.
 */
class EscalationService
{
    public function __construct(private DispatchService $dispatch, private DispatchState $state) {}

    /**
     * @return array{escalated: int, alarmed: int, ignored: int}
     */
    public function run(): array
    {
        $result = ['escalated' => 0, 'alarmed' => 0, 'ignored' => $this->markIgnoredOffers()];

        $reports = Report::query()
            ->where('status', ReportStatus::Menunggu->value)
            ->where('created_at', '>=', now()->subHours((int) config('medrive.dispatch.escalation_lookback_hours')))
            ->with('reportType')
            ->get();

        foreach ($reports as $report) {
            $outcome = $this->escalate($report);

            if ($outcome !== null) {
                $result[$outcome]++;
            }
        }

        return $result;
    }

    /**
     * @return 'escalated'|'alarmed'|null
     */
    public function escalate(Report $report): ?string
    {
        $state = $this->state->get($report->id);

        if ($state === null) {
            // Belum pernah dibroadcast (atau cache hilang): mulai ulang dari ronde yang belum dikirim.
            $this->dispatch->advance($report, ReportDispatch::query()->where('report_id', $report->id)->exists() ? 2 : 1);

            return 'escalated';
        }

        if ($state['alarmed']) {
            return null;
        }

        $dueAt = $state['started_at'] + $report->reportType->roundIntervalSeconds();

        if (now()->getTimestamp() < $dueAt) {
            return null;
        }

        if ($state['round'] >= $this->dispatch->totalRounds()) {
            $this->state->markAlarmed($report->id);
            DispatchEscalated::dispatch($report, $state['round'], null, 0, true);

            return 'alarmed';
        }

        $this->expirePendingOffers($report);
        $this->dispatch->advance($report, $state['round'] + 1);

        return 'escalated';
    }

    /**
     * Laporan yang masih menunggu setelah semua ronde selesai (untuk panel alarm dashboard).
     *
     * @return Collection<int, Report>
     */
    public function alarmedReports(): Collection
    {
        return Report::query()
            ->where('status', ReportStatus::Menunggu->value)
            ->with('reportType:id,name,icon,color,priority')
            ->latest()
            ->limit(50)
            ->get()
            ->filter(fn (Report $report): bool => (bool) ($this->state->get($report->id)['alarmed'] ?? false))
            ->values();
    }

    /**
     * @return array{round: int, started_at: int, alarmed: bool}|null
     */
    public function stateFor(Report $report): ?array
    {
        return $this->state->get($report->id);
    }

    private function expirePendingOffers(Report $report): void
    {
        ReportDispatch::query()
            ->where('report_id', $report->id)
            ->where('response', DispatchResponse::Menunggu->value)
            ->update(['response' => DispatchResponse::Kedaluwarsa->value]);
    }

    /**
     * Tawaran yang tidak direspons sampai laporan diambil driver lain atau dibatalkan dicatat sebagai diabaikan.
     */
    private function markIgnoredOffers(): int
    {
        return ReportDispatch::query()
            ->where('response', DispatchResponse::Menunggu->value)
            ->whereHas('report', fn ($query) => $query->where('status', '!=', ReportStatus::Menunggu->value))
            ->update(['response' => DispatchResponse::Diabaikan->value]);
    }
}
