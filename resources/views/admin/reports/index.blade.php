<x-admin.layout title="Daftar laporan" :breadcrumbs="['Laporan Darurat' => route('admin.reports.index')]">
    <x-admin.page-header title="Daftar laporan" description="Laporan dibuat pelapor dari aplikasi dan diambil driver lewat broadcast. Admin memantau dan hanya bisa membatalkan laporan yang masih menunggu.">
        <x-slot:actions>
            <a href="{{ route('admin.reports.export', request()->query()) }}" class="btn-secondary"><i class="fa-solid fa-file-csv" aria-hidden="true"></i> Export CSV</a>
        </x-slot:actions>
    </x-admin.page-header>

    <x-admin.filter-bar :action="route('admin.reports.index')" :reset-url="route('admin.reports.index')">
        <div>
            <label for="q" class="form-label">Cari</label>
            <input id="q" name="q" type="search" value="{{ $filters['q'] ?? '' }}" placeholder="Kode, deskripsi, alamat" class="form-input">
        </div>
        <div>
            <label for="type" class="form-label">Jenis</label>
            <select id="type" name="type" class="form-input">
                <option value="">Semua jenis</option>
                @foreach ($reportTypes as $type)<option value="{{ $type->id }}" @selected(($filters['type'] ?? null) == $type->id)>{{ $type->name }}</option>@endforeach
            </select>
        </div>
        <div>
            <label for="status" class="form-label">Status</label>
            <select id="status" name="status" class="form-input">
                <option value="">Semua status</option>
                @foreach ($statuses as $status)<option value="{{ $status->value }}" @selected(($filters['status'] ?? null) === $status->value)>{{ $status->label() }}</option>@endforeach
            </select>
        </div>
        <div>
            <label for="from" class="form-label">Dari tanggal</label>
            <input id="from" name="from" type="date" value="{{ $filters['from'] ?? '' }}" class="form-input">
        </div>
        <div>
            <label for="to" class="form-label">Sampai tanggal</label>
            <input id="to" name="to" type="date" value="{{ $filters['to'] ?? '' }}" class="form-input">
            @error('to')<p class="form-error">{{ $message }}</p>@enderror
        </div>
        <div>
            <label for="driver_id" class="form-label">Driver</label>
            <select id="driver_id" name="driver_id" class="form-input">
                <option value="">Semua driver</option>
                @foreach ($drivers as $driver)<option value="{{ $driver->id }}" @selected(($filters['driver_id'] ?? null) == $driver->id)>{{ $driver->name }}</option>@endforeach
            </select>
        </div>
        <div>
            <label for="clinic_id" class="form-label">Klinik armada</label>
            <select id="clinic_id" name="clinic_id" class="form-input">
                <option value="">Semua klinik</option>
                @foreach ($clinics as $clinic)<option value="{{ $clinic->id }}" @selected(($filters['clinic_id'] ?? null) == $clinic->id)>{{ $clinic->name }}</option>@endforeach
            </select>
        </div>
    </x-admin.filter-bar>

    <div class="card overflow-hidden">
        @if ($reports->isEmpty())
            <x-admin.empty-state icon="file-medical" title="Tidak ada laporan yang cocok" description="Ubah filter atau rentang tanggal." />
        @else
            <div class="relative overflow-x-auto">
                <table class="data-table">
                    <thead><tr><th>Kode</th><th>Jenis</th><th>Status</th><th>Pelapor</th><th>Driver</th><th>Alamat</th><th>Dibuat</th><th>Respons</th></tr></thead>
                    <tbody>
                        @foreach ($reports as $report)
                            @php
                                $waitingMinutes = $report->status === \App\Enums\ReportStatus::Menunggu ? (int) $report->created_at->diffInMinutes(now()) : null;
                                $isStale = $waitingMinutes !== null && $waitingMinutes > config('medrive.stale_pending_minutes');
                            @endphp
                            <tr @class(['cursor-pointer', 'bg-amber-50 hover:bg-amber-100' => $isStale, 'hover:bg-stone-50' => ! $isStale])
                                onclick="if (!event.target.closest('a')) window.location = '{{ route('admin.reports.show', $report) }}'">
                                <td>
                                    <a href="{{ route('admin.reports.show', $report) }}" class="tabular font-semibold whitespace-nowrap hover:text-mr-700">{{ $report->code }}</a>
                                    @if ($isStale)
                                        <div class="mt-1 flex items-center gap-1.5 text-xs font-semibold whitespace-nowrap text-mr-700">
                                            <span class="relative flex size-2"><span class="absolute inline-flex size-full animate-ping rounded-full bg-mr-500 opacity-75 motion-reduce:animate-none"></span><span class="relative inline-flex size-2 rounded-full bg-mr-600"></span></span>
                                            Menunggu {{ $report->created_at->diffForHumans(syntax: \Carbon\CarbonInterface::DIFF_ABSOLUTE, parts: 2) }}
                                        </div>
                                    @endif
                                </td>
                                <td><x-admin.type-badge :type="$report->reportType" /></td>
                                <td><x-admin.status-badge :status="$report->status" /></td>
                                <td class="whitespace-nowrap">
                                    <div>{{ $report->reporter->name }}</div>
                                    <div class="text-xs text-stone-600">{{ $report->reporter->phone }}</div>
                                </td>
                                <td class="whitespace-nowrap">
                                    @if ($report->driver)
                                        <div>{{ $report->driver->name }}</div>
                                        <div class="tabular text-xs text-stone-600">{{ $report->ambulance?->plate_number }}</div>
                                    @else
                                        <span class="text-xs text-stone-600">Belum ada</span>
                                    @endif
                                </td>
                                <td class="max-w-56 text-stone-700">{{ $report->shortAddress(60) }}</td>
                                <td class="tabular whitespace-nowrap" title="{{ $report->created_at->diffForHumans() }}">{{ $report->created_at->translatedFormat('j M Y H:i') }}</td>
                                <td class="tabular whitespace-nowrap">{{ $report->response_time_minutes !== null ? $report->response_time_minutes.' mnt' : '-' }}</td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            <div class="border-t border-stone-100 px-4 py-3">{{ $reports->links() }}</div>
        @endif
    </div>
</x-admin.layout>
