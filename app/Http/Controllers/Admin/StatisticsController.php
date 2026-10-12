<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Report;
use App\Services\StatisticsService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Validation\Rule;
use Illuminate\View\View;
use Symfony\Component\HttpFoundation\StreamedResponse;

class StatisticsController extends Controller
{
    public function index(Request $request): View
    {
        Gate::authorize('viewAny', Report::class);

        $firstReportAt = Report::query()->min('created_at');
        $firstYear = $firstReportAt ? (int) substr((string) $firstReportAt, 0, 4) : now()->year;

        return view('admin.statistics.index', [
            'ranges' => StatisticsService::RANGES,
            'years' => range(now()->year, min($firstYear, now()->year)),
            'initial' => [
                'range' => array_key_exists($request->query('range'), StatisticsService::RANGES) ? $request->query('range') : '7d',
                'year' => (int) $request->query('year', now()->year),
                'from' => $request->query('from', now()->subDays(13)->toDateString()),
                'to' => $request->query('to', now()->toDateString()),
            ],
        ]);
    }

    public function data(Request $request, StatisticsService $statistics): JsonResponse
    {
        Gate::authorize('viewAny', Report::class);

        return response()->json($statistics->forRange($this->validated($request))->payload());
    }

    /**
     * Export ringkasan dan data per periode sesuai rentang yang sedang dipilih.
     */
    public function export(Request $request, StatisticsService $statistics): StreamedResponse
    {
        Gate::authorize('export', Report::class);

        $data = $statistics->forRange($this->validated($request))->build();
        $filename = 'statistik-medrive-'.now()->format('Ymd-His').'.csv';

        return response()->streamDownload(function () use ($data): void {
            $output = fopen('php://output', 'w');
            fwrite($output, "\xEF\xBB\xBF");

            fputcsv($output, ['Statistik laporan Medrive', $data['range']['label']]);
            fputcsv($output, ['Ringkasan', 'Periode ini', 'Periode sebelumnya', 'Perubahan (%)']);
            foreach ([
                'total' => 'Total laporan',
                'completed' => 'Selesai',
                'cancelled' => 'Dibatalkan',
                'avg_response_minutes' => 'Rata-rata waktu respons (menit)',
                'avg_duration_minutes' => 'Rata-rata durasi total (menit)',
            ] as $key => $label) {
                $row = $data['summary'][$key];
                fputcsv($output, [$label, $row['value'], $row['previous'], $row['delta'] ?? '']);
            }

            fputcsv($output, []);
            fputcsv($output, [
                'Periode',
                'Jumlah laporan',
                'Periode sebelumnya',
                ...array_map(fn (array $type): string => $type['name'], $data['by_type_series']),
                'Rata-rata dibuat sampai diambil (menit)',
                'Rata-rata diambil sampai tiba (menit)',
            ]);

            foreach ($data['labels'] as $index => $label) {
                fputcsv($output, [
                    $label,
                    $data['series']['current'][$index],
                    $data['series']['previous'][$index],
                    ...array_map(fn (array $type): int => $type['data'][$index], $data['by_type_series']),
                    $data['response_times']['taken'][$index],
                    $data['response_times']['arrived'][$index],
                ]);
            }

            fclose($output);
        }, $filename, ['Content-Type' => 'text/csv; charset=UTF-8']);
    }

    /**
     * @return array{range: string, year?: int, from?: string, to?: string}
     */
    private function validated(Request $request): array
    {
        return $request->validate([
            'range' => ['required', Rule::in(array_keys(StatisticsService::RANGES))],
            'year' => ['required_if:range,year', 'nullable', 'integer', 'between:2000,'.now()->year],
            'from' => ['required_if:range,custom', 'nullable', 'date'],
            'to' => ['required_if:range,custom', 'nullable', 'date', 'after_or_equal:from'],
        ], attributes: ['from' => 'tanggal mulai', 'to' => 'tanggal selesai', 'year' => 'tahun']);
    }
}
