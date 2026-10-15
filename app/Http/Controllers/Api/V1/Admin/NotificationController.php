<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Enums\ReportStatus;
use App\Http\Controllers\Api\ApiController;
use App\Models\Report;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Badge notifikasi topbar dan polling cadangan event ReportCreated.
 */
class NotificationController extends ApiController
{
    public function __invoke(Request $request): JsonResponse
    {
        $afterId = $request->integer('after_id');

        $newReports = $afterId > 0
            ? Report::query()->where('id', '>', $afterId)->with('reportType')->orderBy('id')->limit(20)->get()
            : collect();

        $latestPending = Report::query()
            ->where('status', ReportStatus::Menunggu)
            ->with('reportType')
            ->latest()
            ->limit(8)
            ->get();

        return $this->ok([
            'pending_count' => Report::query()->where('status', ReportStatus::Menunggu)->count(),
            'last_report_id' => (int) Report::query()->max('id'),
            'new_reports' => $newReports->map(fn (Report $report): array => $this->present($report))->values(),
            'latest_pending' => $latestPending->map(fn (Report $report): array => $this->present($report))->values(),
        ]);
    }

    /**
     * Bentuk sama dengan payload event ReportCreated agar toast memakai satu format.
     *
     * @return array<string, mixed>
     */
    private function present(Report $report): array
    {
        return [
            'id' => $report->id,
            'code' => $report->code,
            'address' => $report->shortAddress(),
            'age' => $report->created_at->diffForHumans(),
            'url' => route('admin.reports.show', $report),
            'type' => [
                'name' => $report->reportType->name,
                'icon' => $report->reportType->icon,
                'color' => $report->reportType->color,
                'priority' => $report->reportType->priority,
            ],
        ];
    }
}
