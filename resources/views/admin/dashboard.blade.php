<x-admin.layout title="Dashboard">
    <x-admin.page-header title="Ringkasan operasional" description="Kondisi laporan dan armada saat ini. Pembanding dihitung terhadap kemarin pada jam yang sama.">
        <x-slot:actions>
            <a href="{{ route('admin.tracking.index') }}" class="btn-secondary"><i class="fa-solid fa-map-location-dot" aria-hidden="true"></i> Buka Peta Live</a>
        </x-slot:actions>
    </x-admin.page-header>

    <div class="grid gap-6 xl:grid-cols-12">
        {{-- Fokus utama layar: laporan yang belum diambil driver --}}
        <section class="card overflow-hidden xl:col-span-4 xl:self-start" aria-labelledby="pending-title">
            <div class="bg-mr-600 px-5 py-4 text-white">
                <h2 id="pending-title" class="text-sm font-semibold">Laporan menunggu driver</h2>
                <div class="mt-1 flex items-end justify-between gap-3">
                    <p class="tabular text-5xl leading-none font-bold">{{ $pendingReports['current'] }}</p>
                    <p class="text-right text-xs text-white/90">Kemarin jam ini: <span class="tabular font-semibold">{{ $pendingReports['previous'] }}</span></p>
                </div>
            </div>
            @if ($latestPending->isEmpty())
                <x-admin.empty-state icon="circle-check" title="Tidak ada laporan menunggu" description="Semua laporan sudah diambil driver atau ditutup." />
            @else
                <ul class="divide-y divide-stone-100">
                    @foreach ($latestPending as $report)
                        @php $isStale = $report->created_at->diffInMinutes(now()) > config('medrive.stale_pending_minutes'); @endphp
                        <li>
                            <a href="{{ route('admin.reports.show', $report) }}" class="block px-5 py-3 hover:bg-mr-50">
                                <div class="flex items-center justify-between gap-2">
                                    <span class="tabular text-sm font-semibold">{{ $report->code }}</span>
                                    <span @class(['text-xs', 'font-semibold text-mr-700' => $isStale, 'text-stone-600' => ! $isStale])>
                                        menunggu {{ $report->created_at->diffForHumans(syntax: \Carbon\CarbonInterface::DIFF_ABSOLUTE, parts: 2) }}
                                    </span>
                                </div>
                                <div class="mt-1 flex flex-wrap items-center gap-2">
                                    <x-admin.type-badge :type="$report->reportType" />
                                    <span class="truncate text-xs text-stone-700">{{ $report->shortAddress(40) }}</span>
                                </div>
                            </a>
                        </li>
                    @endforeach
                </ul>
            @endif
        </section>

        <div class="grid gap-6 xl:col-span-8">
            <div class="grid gap-4 sm:grid-cols-3">
                <div class="card p-5">
                    <h2 class="text-sm font-medium text-stone-600">Laporan hari ini</h2>
                    <p class="tabular mt-1 text-3xl font-bold">{{ $reportsToday['current'] }}</p>
                    <x-admin.delta :current="$reportsToday['current']" :previous="$reportsToday['previous']" label="vs kemarin jam ini" />
                </div>
                <div class="card p-5">
                    <h2 class="text-sm font-medium text-stone-600">Laporan aktif</h2>
                    <p class="tabular mt-1 text-3xl font-bold">{{ $activeReports['current'] }}</p>
                    <x-admin.delta :current="$activeReports['current']" :previous="$activeReports['previous']" label="vs kemarin jam ini" />
                    <p class="mt-2 text-xs text-stone-600">
                        @foreach ($activeReports['breakdown'] as $label => $count)
                            @if ($count > 0)<span class="mr-2 whitespace-nowrap">{{ $label }} <span class="tabular font-semibold text-stone-900">{{ $count }}</span></span>@endif
                        @endforeach
                    </p>
                </div>
                <div class="card p-5">
                    <h2 class="text-sm font-medium text-stone-600">Driver aktif / ambulans siaga</h2>
                    <p class="tabular mt-1 text-3xl font-bold">{{ $fleet['drivers'] }} <span class="text-xl font-semibold text-stone-500">/</span> {{ $fleet['available'] }}</p>
                    <x-admin.delta :current="$fleet['drivers']" :previous="$fleet['drivers_previous']" label="driver vs kemarin" :higher-is-better="true" />
                    <p class="mt-2 text-xs text-stone-600">
                        Perawatan <span class="tabular font-semibold text-stone-900">{{ $fleet['maintenance'] }}</span>,
                        nonaktif <span class="tabular font-semibold text-stone-900">{{ $fleet['inactive'] }}</span>
                    </p>
                </div>
            </div>

            <section class="card p-5" aria-labelledby="trend-title" x-data="trendChart(@js($trend))">
                <div class="mb-3 flex flex-wrap items-baseline justify-between gap-2">
                    <h2 id="trend-title" class="font-semibold">Laporan 14 hari terakhir</h2>
                    <a href="{{ route('admin.statistics.index') }}" class="text-sm font-semibold text-mr-700 hover:underline">Statistik lengkap</a>
                </div>
                <div class="relative h-56">
                    <canvas x-ref="canvas" role="img" aria-label="Grafik garis jumlah laporan per hari selama 14 hari terakhir"></canvas>
                    <p x-show="error" x-cloak class="absolute inset-0 grid place-items-center text-sm text-mr-700" x-text="error"></p>
                </div>
                @if (array_sum($trend['current']) === 0)
                    <p class="mt-2 text-xs text-stone-600">Belum ada laporan dalam 14 hari terakhir.</p>
                @endif
            </section>
        </div>
    </div>

    <div class="mt-6 grid gap-6 xl:grid-cols-12">
        <section class="card overflow-hidden xl:col-span-7" aria-labelledby="map-title" x-data="trackingMap({ dataUrl: @js(route('admin.tracking.data')), compact: true })">
            <div class="flex flex-wrap items-center justify-between gap-2 border-b border-stone-100 px-5 py-3">
                <h2 id="map-title" class="font-semibold">Posisi driver aktif</h2>
                <div class="flex items-center gap-3 text-xs text-stone-600">
                    <span class="flex items-center gap-1.5"><span class="size-2.5 rounded-full bg-mr-600"></span> Menangani laporan</span>
                    <span class="flex items-center gap-1.5"><span class="size-2.5 rounded-full bg-stone-700"></span> Standby</span>
                </div>
            </div>
            <div class="relative h-80">
                <div x-ref="map" class="absolute inset-0 z-0"></div>
                <div x-show="loading" class="absolute inset-0 z-10 bg-white p-4"><div class="skeleton h-full w-full"></div></div>
                <div x-show="!loading && error" x-cloak class="absolute inset-0 z-10 grid place-items-center bg-white/90 p-6 text-center text-sm text-mr-700" x-text="error"></div>
                <div x-show="!loading && !error && drivers.length === 0" x-cloak class="absolute inset-x-4 top-4 z-10 rounded-lg bg-white/95 p-3 text-center text-sm text-stone-700 shadow">
                    Belum ada driver yang membuka shift.
                </div>
            </div>
            <p class="px-5 py-2.5 text-xs text-stone-600">
                {{ $activeDriverCount }} driver dengan shift terbuka.
                <span x-text="mode === 'realtime' ? 'Posisi diperbarui realtime.' : 'Posisi diperbarui tiap 10 detik.'"></span>
            </p>
        </section>

        <section class="card overflow-hidden xl:col-span-5" aria-labelledby="latest-title">
            <div class="flex items-center justify-between border-b border-stone-100 px-5 py-3">
                <h2 id="latest-title" class="font-semibold">Laporan terbaru</h2>
                <a href="{{ route('admin.reports.index') }}" class="text-sm font-semibold text-mr-700 hover:underline">Semua laporan</a>
            </div>
            @if ($latestReports->isEmpty())
                <x-admin.empty-state icon="file-medical" title="Belum ada laporan" description="Laporan dari aplikasi pelapor akan muncul di sini." />
            @else
                <ul class="divide-y divide-stone-100">
                    @foreach ($latestReports as $report)
                        <li>
                            <a href="{{ route('admin.reports.show', $report) }}" class="flex flex-col gap-1.5 px-5 py-3 hover:bg-stone-50">
                                <div class="flex flex-wrap items-center gap-2">
                                    <span class="tabular text-sm font-semibold">{{ $report->code }}</span>
                                    <x-admin.status-badge :status="$report->status" />
                                    <span class="ml-auto text-xs text-stone-600" title="{{ $report->created_at->translatedFormat('j F Y H:i') }}">{{ $report->created_at->diffForHumans() }}</span>
                                </div>
                                <div class="flex min-w-0 items-center gap-2">
                                    <x-admin.type-badge :type="$report->reportType" />
                                    <span class="truncate text-xs text-stone-700">{{ $report->shortAddress(44) }}</span>
                                </div>
                            </a>
                        </li>
                    @endforeach
                </ul>
            @endif
        </section>
    </div>

    <section class="card mt-6 overflow-hidden" aria-labelledby="expiry-title">
        <div class="border-b border-stone-100 px-5 py-3">
            <h2 id="expiry-title" class="font-semibold">SIM dan sertifikat yang perlu diperbarui</h2>
            <p class="text-xs text-stone-600">Sudah lewat atau kedaluwarsa dalam {{ config('medrive.expiry_warning_days') }} hari ke depan.</p>
        </div>
        @if ($expiringDocuments->isEmpty())
            <x-admin.empty-state icon="id-card" title="Semua dokumen masih berlaku" description="Tidak ada SIM atau sertifikat driver yang kedaluwarsa dalam {{ config('medrive.expiry_warning_days') }} hari ke depan." />
        @else
            <div class="relative overflow-x-auto">
                <table class="data-table">
                    <thead><tr><th>Driver</th><th>Dokumen</th><th>Berlaku sampai</th><th>Status</th></tr></thead>
                    <tbody>
                        @foreach ($expiringDocuments as $document)
                            <tr>
                                <td><a href="{{ route('admin.drivers.show', $document['driver_id']) }}" class="font-medium hover:text-mr-700">{{ $document['driver'] }}</a></td>
                                <td>{{ $document['document'] }}</td>
                                <td class="tabular">{{ $document['expires_at']->translatedFormat('j M Y') }}</td>
                                <td>
                                    @if ($document['is_expired'])
                                        <x-admin.badge tone="red">Sudah kedaluwarsa</x-admin.badge>
                                    @else
                                        <x-admin.badge tone="amber">{{ (int) now()->startOfDay()->diffInDays($document['expires_at']) }} hari lagi</x-admin.badge>
                                    @endif
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        @endif
    </section>
</x-admin.layout>
