<section class="card overflow-hidden">
    <div class="border-b border-stone-100 px-5 py-3"><h2 class="font-semibold">Laporan yang ditangani</h2></div>
    @if ($reports->isEmpty())
        <x-admin.empty-state icon="file-medical" title="Belum menangani laporan" description="Laporan yang diambil driver ini akan tercantum di sini." />
    @else
        <div class="relative overflow-x-auto">
            <table class="data-table">
                <thead><tr><th>Kode</th><th>Jenis</th><th>Status</th><th>Ambulans</th><th>Dibuat</th><th>Respons</th></tr></thead>
                <tbody>
                    @foreach ($reports as $report)
                        <tr class="hover:bg-stone-50">
                            <td><a href="{{ route('admin.reports.show', $report) }}" class="tabular font-semibold whitespace-nowrap hover:text-mr-700">{{ $report->code }}</a></td>
                            <td><x-admin.type-badge :type="$report->reportType" /></td>
                            <td><x-admin.status-badge :status="$report->status" /></td>
                            <td class="tabular whitespace-nowrap">{{ $report->ambulance?->plate_number ?? '-' }}</td>
                            <td class="tabular whitespace-nowrap">{{ $report->created_at->translatedFormat('j M Y H:i') }}</td>
                            <td class="tabular whitespace-nowrap">{{ $report->response_time_minutes !== null ? $report->response_time_minutes.' menit' : '-' }}</td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
        <div class="border-t border-stone-100 px-4 py-3">{{ $reports->links() }}</div>
    @endif
</section>
