<x-admin.layout :title="$reporter->name" :breadcrumbs="['Pengguna pelapor' => route('admin.users.index')]">
    <div x-data="{ toggle: { open: false, url: '', name: '', active: true } }">
        <section class="card mb-6 flex flex-col gap-4 p-5 md:flex-row md:items-center">
            <x-admin.avatar :user="$reporter" size="lg" />
            <div class="min-w-0 flex-1">
                <div class="flex flex-wrap items-center gap-2">
                    <h1 class="text-2xl font-bold tracking-tight">{{ $reporter->name }}</h1>
                    <x-admin.badge :tone="$reporter->account_status->tone()">Akun {{ mb_strtolower($reporter->account_status->label()) }}</x-admin.badge>
                </div>
                <p class="mt-1 text-sm text-stone-600">{{ $reporter->phone }} · {{ $reporter->email }} · terdaftar {{ $reporter->created_at?->translatedFormat('j M Y') }}</p>
            </div>
            <button type="button" class="{{ $reporter->isActive() ? 'btn-danger' : 'btn-primary' }}"
                    @click="toggle = { open: true, url: @js(route('admin.users.account-status', $reporter)), name: @js($reporter->name), active: @js($reporter->isActive()) }">
                {{ $reporter->isActive() ? 'Nonaktifkan akun' : 'Aktifkan akun' }}
            </button>
        </section>
        @include('admin.users.partials.toggle-modal')
    </div>

    <div class="grid gap-6 xl:grid-cols-[minmax(0,2fr)_minmax(0,1fr)]">
        <section class="card overflow-hidden">
            <h2 class="border-b border-stone-100 px-5 py-3 font-semibold">Riwayat laporan</h2>
            @if ($reports->isEmpty())
                <x-admin.empty-state icon="file-medical" title="Belum pernah membuat laporan" />
            @else
                <div class="relative overflow-x-auto">
                    <table class="data-table">
                        <thead><tr><th>Kode</th><th>Jenis</th><th>Status</th><th>Driver</th><th>Dibuat</th></tr></thead>
                        <tbody>
                            @foreach ($reports as $report)
                                <tr>
                                    <td><a href="{{ route('admin.reports.show', $report) }}" class="tabular font-semibold whitespace-nowrap hover:text-mr-700">{{ $report->code }}</a></td>
                                    <td><x-admin.type-badge :type="$report->reportType" /></td>
                                    <td><x-admin.status-badge :status="$report->status" /></td>
                                    <td class="whitespace-nowrap">{{ $report->driver?->name ?? '-' }}</td>
                                    <td class="tabular whitespace-nowrap">{{ $report->created_at->translatedFormat('j M Y H:i') }}</td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
                <div class="border-t border-stone-100 px-4 py-3">{{ $reports->links() }}</div>
            @endif
        </section>

        <section class="card p-5">
            <h2 class="mb-3 font-semibold">Perangkat</h2>
            @if ($devices->isEmpty())
                <p class="text-sm text-stone-600">Belum ada perangkat terdaftar.</p>
            @else
                <ul class="space-y-3">
                    @foreach ($devices as $device)
                        <li class="rounded-lg border border-stone-200 p-3 text-sm">
                            <div class="font-medium">{{ $device->device_model ?? 'Perangkat tidak dikenal' }}</div>
                            <div class="text-xs text-stone-600">{{ ucfirst($device->platform) }} · aplikasi v{{ $device->app_version ?? '-' }}</div>
                            <div class="text-xs text-stone-600">Terakhir aktif {{ $device->last_seen_at?->translatedFormat('j M Y H:i') ?? '-' }}</div>
                        </li>
                    @endforeach
                </ul>
            @endif
        </section>
    </div>
</x-admin.layout>
