<x-admin.layout title="Dashboard">
    <div x-data="dashboardPage({ url: @js(route('api.v1.admin.dashboard.summary')) })">
        <x-admin.page-header title="Ringkasan operasional" description="Kondisi laporan dan armada saat ini. Pembanding dihitung terhadap kemarin pada jam yang sama.">
            <x-slot:actions>
                <a href="{{ route('admin.tracking.index') }}" class="btn-secondary"><i class="fa-solid fa-map-location-dot" aria-hidden="true"></i> Buka Peta Live</a>
            </x-slot:actions>
        </x-admin.page-header>

        <div x-show="error" x-cloak class="mb-6 flex flex-wrap items-center gap-3 rounded-lg border border-mr-300 bg-mr-50 p-4 text-sm text-mr-800" role="alert">
            <span x-text="error"></span>
            <button type="button" class="font-semibold underline" @click="load()">Coba lagi</button>
        </div>

        <div class="grid gap-6 xl:grid-cols-12">
            {{-- Fokus utama layar: laporan yang belum diambil driver --}}
            <section class="card overflow-hidden xl:col-span-4 xl:self-start" aria-labelledby="pending-title">
                <div class="bg-mr-600 px-5 py-4 text-white">
                    <h2 id="pending-title" class="text-sm font-semibold">Laporan menunggu driver</h2>
                    <div class="mt-1 flex items-end justify-between gap-3">
                        <p class="tabular text-5xl leading-none font-bold" x-text="data?.cards.pending_reports.value ?? '-'"></p>
                        <p class="text-right text-xs text-white/90">Kemarin jam ini: <span class="tabular font-semibold" x-text="data?.cards.pending_reports.previous ?? '-'"></span></p>
                    </div>
                </div>
                <template x-if="loading"><x-admin.skeleton-rows :rows="3" /></template>
                <template x-if="!loading && data && data.latest_pending.length === 0">
                    <x-admin.empty-state icon="circle-check" title="Tidak ada laporan menunggu" description="Semua laporan sudah diambil driver atau ditutup." />
                </template>
                <ul class="divide-y divide-stone-100">
                    <template x-for="row in data?.latest_pending ?? []" :key="row.id">
                        <li>
                            <a :href="`/admin/reports/${row.id}`" class="block px-5 py-3 hover:bg-mr-50">
                                <div class="flex items-center justify-between gap-2">
                                    <span class="tabular text-sm font-semibold" x-text="row.code"></span>
                                    <span class="text-xs" :class="row.is_stale ? 'font-semibold text-mr-700' : 'text-stone-600'" x-text="`menunggu ${window.durationLabel(row.waiting_minutes)}`"></span>
                                </div>
                                <div class="mt-1 flex flex-wrap items-center gap-2">
                                    <x-admin.type-chip />
                                    <span class="truncate text-xs text-stone-700" x-text="row.short_address"></span>
                                </div>
                            </a>
                        </li>
                    </template>
                </ul>
            </section>

            <div class="grid gap-6 xl:col-span-8">
                <div class="grid gap-4 sm:grid-cols-3">
                    @foreach ([
                        ['key' => 'reports_today', 'label' => 'Laporan hari ini', 'compare' => 'vs kemarin jam ini', 'good' => false],
                        ['key' => 'active_reports', 'label' => 'Laporan aktif', 'compare' => 'vs kemarin jam ini', 'good' => false],
                    ] as $card)
                        <div class="card p-5">
                            <h2 class="text-sm font-medium text-stone-600">{{ $card['label'] }}</h2>
                            <div x-show="loading" class="skeleton mt-2 h-8 w-16"></div>
                            <template x-if="data">
                                <div>
                                    <p class="tabular mt-1 text-3xl font-bold" x-text="data.cards.{{ $card['key'] }}.value"></p>
                                    <p class="mt-2 flex flex-wrap items-center gap-1 text-xs text-stone-600" x-data="{ get d() { return delta(data.cards.{{ $card['key'] }}, @js($card['good'])) } }">
                                        <span class="font-semibold" :class="d.tone"><i class="fa-solid" :class="d.icon" aria-hidden="true"></i> <span x-text="d.label"></span></span>
                                        <span x-text="`{{ $card['compare'] }} (${data.cards.{{ $card['key'] }}.previous})`"></span>
                                    </p>
                                    @if ($card['key'] === 'active_reports')
                                        <p class="mt-2 text-xs text-stone-600">
                                            <template x-for="[label, count] in Object.entries(data.cards.active_reports.breakdown).filter(([, count]) => count > 0)" :key="label">
                                                <span class="mr-2 whitespace-nowrap"><span x-text="label"></span> <span class="tabular font-semibold text-stone-900" x-text="count"></span></span>
                                            </template>
                                        </p>
                                    @endif
                                </div>
                            </template>
                        </div>
                    @endforeach
                    <div class="card p-5">
                        <h2 class="text-sm font-medium text-stone-600">Driver aktif / ambulans siaga</h2>
                        <div x-show="loading" class="skeleton mt-2 h-8 w-16"></div>
                        <template x-if="data">
                            <div>
                                <p class="tabular mt-1 text-3xl font-bold"><span x-text="data.cards.fleet.drivers"></span> <span class="text-xl font-semibold text-stone-500">/</span> <span x-text="data.cards.fleet.available"></span></p>
                                <p class="mt-2 flex flex-wrap items-center gap-1 text-xs text-stone-600"
                                   x-data="{ get d() { return delta({ value: data.cards.fleet.drivers, previous: data.cards.fleet.drivers_previous, delta: data.cards.fleet.drivers_delta }, true) } }">
                                    <span class="font-semibold" :class="d.tone"><i class="fa-solid" :class="d.icon" aria-hidden="true"></i> <span x-text="d.label"></span></span>
                                    <span x-text="`driver vs kemarin (${data.cards.fleet.drivers_previous})`"></span>
                                </p>
                                <p class="mt-2 text-xs text-stone-600">
                                    Perawatan <span class="tabular font-semibold text-stone-900" x-text="data.cards.fleet.maintenance"></span>,
                                    nonaktif <span class="tabular font-semibold text-stone-900" x-text="data.cards.fleet.inactive"></span>
                                </p>
                            </div>
                        </template>
                    </div>
                </div>

                <section class="card p-5" aria-labelledby="trend-title" x-data="trendChart()">
                    <div class="mb-3 flex flex-wrap items-baseline justify-between gap-2">
                        <h2 id="trend-title" class="font-semibold">Laporan 14 hari terakhir</h2>
                        <a href="{{ route('admin.statistics.index') }}" class="text-sm font-semibold text-mr-700 hover:underline">Statistik lengkap</a>
                    </div>
                    <div class="relative h-56">
                        <div x-show="loading" class="skeleton absolute inset-0"></div>
                        <canvas x-ref="canvas" role="img" aria-label="Grafik garis jumlah laporan per hari selama 14 hari terakhir"></canvas>
                        <p x-show="error" x-cloak class="absolute inset-0 grid place-items-center text-sm text-mr-700" x-text="error"></p>
                    </div>
                    <p x-show="empty" x-cloak class="mt-2 text-xs text-stone-600">Belum ada laporan dalam 14 hari terakhir.</p>
                </section>
            </div>
        </div>

        <div class="mt-6 grid gap-6 xl:grid-cols-12">
            <section class="card overflow-hidden xl:col-span-7" aria-labelledby="map-title" x-data="trackingMap({ dataUrl: @js(route('api.v1.admin.tracking.live')), compact: true })">
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
                    <span x-text="`${drivers.length} driver dengan shift terbuka.`"></span>
                    <span x-text="mode === 'realtime' ? 'Posisi diperbarui realtime.' : 'Posisi diperbarui tiap 10 detik.'"></span>
                </p>
            </section>

            <div class="grid gap-6 xl:col-span-5">
                <x-admin.escalation-panel />

                <section class="card overflow-hidden" aria-labelledby="latest-title">
                    <div class="flex items-center justify-between border-b border-stone-100 px-5 py-3">
                        <h2 id="latest-title" class="font-semibold">Laporan terbaru</h2>
                        <a href="{{ route('admin.reports.index') }}" class="text-sm font-semibold text-mr-700 hover:underline">Semua laporan</a>
                    </div>
                    <template x-if="loading"><x-admin.skeleton-rows :rows="4" /></template>
                    <template x-if="!loading && data && data.latest_reports.length === 0">
                        <x-admin.empty-state icon="file-medical" title="Belum ada laporan" description="Laporan dari aplikasi pelapor akan muncul di sini." />
                    </template>
                    <ul class="divide-y divide-stone-100">
                        <template x-for="row in data?.latest_reports ?? []" :key="row.id">
                            <li>
                                <a :href="`/admin/reports/${row.id}`" class="flex flex-col gap-1.5 px-5 py-3 hover:bg-stone-50">
                                    <div class="flex flex-wrap items-center gap-2">
                                        <span class="tabular text-sm font-semibold" x-text="row.code"></span>
                                        <x-admin.status-chip />
                                        <span class="ml-auto text-xs text-stone-600" :title="window.formatDate(row.created_at)" x-text="window.timeAgo(row.created_at)"></span>
                                    </div>
                                    <div class="flex min-w-0 items-center gap-2">
                                        <x-admin.type-chip />
                                        <span class="truncate text-xs text-stone-700" x-text="row.short_address"></span>
                                    </div>
                                </a>
                            </li>
                        </template>
                    </ul>
                </section>
            </div>
        </div>

        <section class="card mt-6 overflow-hidden" aria-labelledby="expiry-title">
            <div class="border-b border-stone-100 px-5 py-3">
                <h2 id="expiry-title" class="font-semibold">SIM dan sertifikat yang perlu diperbarui</h2>
                <p class="text-xs text-stone-600">Sudah lewat atau kedaluwarsa dalam {{ config('medrive.expiry_warning_days') }} hari ke depan.</p>
            </div>
            <template x-if="loading"><x-admin.skeleton-rows :rows="2" /></template>
            <template x-if="!loading && data && data.expiring_documents.length === 0">
                <x-admin.empty-state icon="id-card" title="Semua dokumen masih berlaku" description="Tidak ada SIM atau sertifikat driver yang kedaluwarsa dalam {{ config('medrive.expiry_warning_days') }} hari ke depan." />
            </template>
            <div class="relative overflow-x-auto" x-show="data && data.expiring_documents.length > 0" x-cloak>
                <table class="data-table">
                    <thead><tr><th>Driver</th><th>Dokumen</th><th>Berlaku sampai</th><th>Status</th></tr></thead>
                    <tbody>
                        <template x-for="doc in data?.expiring_documents ?? []" :key="`${doc.driver_id}-${doc.document}`">
                            <tr>
                                <td><a :href="`/admin/drivers/${doc.driver_id}`" class="font-medium hover:text-mr-700" x-text="doc.driver"></a></td>
                                <td x-text="doc.document"></td>
                                <td class="tabular" x-text="window.formatDay(doc.expires_at)"></td>
                                <td>
                                    <span class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold ring-1 ring-inset"
                                          :class="window.badgeTone(doc.is_expired ? 'red' : 'amber')"
                                          x-text="doc.is_expired ? 'Sudah kedaluwarsa' : `${doc.days_left} hari lagi`"></span>
                                </td>
                            </tr>
                        </template>
                    </tbody>
                </table>
            </div>
        </section>
    </div>
</x-admin.layout>
