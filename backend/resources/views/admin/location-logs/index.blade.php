@php
    $retentionDays = config('medrive.location_log_retention_days');
@endphp
<x-admin.layout title="Log Lokasi" :breadcrumbs="['Laporan Darurat' => route('admin.reports.index')]">
    <x-admin.page-header title="Log Lokasi" description="Rute historis per driver dari log lokasi detail. Rentang maksimal {{ $retentionDays }} hari sesuai masa simpan log." />

    <div x-data="adminOptions('drivers')">
    <div x-data="locationLogMap({ routeUrl: @js(route('api.v1.admin.location-logs')), trackingUrl: @js(route('api.v1.admin.tracking.live')) })">
        <form @submit.prevent="submit()" class="card mb-4 grid gap-3 p-4 md:grid-cols-2 xl:grid-cols-[2fr_1.5fr_1.5fr_auto_auto] xl:items-end" role="search" novalidate>
            <div>
                <label for="driver_id" class="form-label">Driver</label>
                <select id="driver_id" x-model="filters.driver_id" required class="form-input" :aria-invalid="errors.driver_id ? 'true' : null">
                    <option value="">Pilih driver</option>
                    <template x-for="item in options.drivers ?? []" :key="item.id"><option :value="String(item.id)" x-text="item.name" :selected="String(item.id) === filters.driver_id"></option></template>
                </select>
                <p x-show="errors.driver_id" x-cloak class="form-error" x-text="errors.driver_id?.[0]"></p>
            </div>
            <div>
                <label for="from" class="form-label">Dari</label>
                <input id="from" type="datetime-local" x-model="filters.from" class="form-input" :aria-invalid="errors.from ? 'true' : null">
                <p x-show="errors.from" x-cloak class="form-error" x-text="errors.from?.[0]"></p>
            </div>
            <div>
                <label for="to" class="form-label">Sampai</label>
                <input id="to" type="datetime-local" x-model="filters.to" class="form-input" :aria-invalid="errors.to ? 'true' : null">
                <p x-show="errors.to" x-cloak class="form-error" x-text="errors.to?.[0]"></p>
            </div>
            <label class="inline-flex min-h-10 items-center gap-2 text-sm whitespace-nowrap">
                <input type="checkbox" x-model="filters.accurate_only" class="size-4 accent-mr-600">
                Saring akurasi &gt; 50 m
            </label>
            <button type="submit" class="btn-primary" :disabled="loading"><i class="fa-solid fa-magnifying-glass-location" aria-hidden="true"></i> Tampilkan rute</button>
        </form>

        <p x-show="report" x-cloak class="mb-4 text-sm text-stone-700">Rute difilter untuk laporan <a :href="`/admin/reports/${report?.id}`" class="tabular font-semibold text-mr-700 hover:underline" x-text="report?.code"></a>.
            <button type="button" class="font-semibold hover:underline" @click="clearReport()">Hapus filter laporan</button></p>

        <div x-show="!loaded && !loading" class="card">
            <x-admin.empty-state icon="route" title="Pilih driver untuk melihat rute" description="Default rentang adalah 1 jam terakhir. Untuk rute satu laporan, buka dari halaman detail laporan." />
        </div>

        <div x-show="loaded || loading" x-cloak>
            <div x-show="summary?.mock_points > 0" x-cloak class="mb-4 flex gap-3 rounded-lg border border-mr-300 bg-mr-50 p-4 text-sm text-mr-800" role="alert">
                <i class="fa-solid fa-triangle-exclamation mt-0.5" aria-hidden="true"></i>
                <div><strong x-text="`Terdeteksi ${summary?.mock_points} titik GPS palsu`"></strong> pada rentang ini. Titik tersebut ditandai merah di tabel dan peta; periksa perangkat driver.</div>
            </div>

            <section class="mb-4 grid gap-3 sm:grid-cols-3 xl:grid-cols-5" aria-label="Ringkasan rute">
                @foreach (['points' => 'Jumlah titik', 'distance' => 'Jarak tempuh', 'max' => 'Kecepatan maks', 'avg' => 'Kecepatan rata-rata', 'battery' => 'Baterai terakhir'] as $key => $label)
                    <div class="card p-4">
                        <p class="text-xs text-stone-600">{{ $label }}</p>
                        <p class="tabular mt-1 text-xl font-bold" x-show="!loading" x-text="stat('{{ $key }}')"></p>
                        <div class="skeleton mt-2 h-6 w-16" x-show="loading"></div>
                    </div>
                @endforeach
            </section>

            <section class="card mb-4 overflow-hidden" aria-label="Peta rute">
                <div class="flex flex-wrap items-center justify-between gap-2 border-b border-stone-100 px-4 py-3">
                    <h2 class="font-semibold" x-text="driver ? `Rute ${driver.name}` : 'Rute'"></h2>
                    <div class="flex items-center gap-3 text-xs text-stone-600">
                        <span x-show="summary?.sampled" x-cloak>Titik di peta disederhanakan agar ringan.</span>
                        <span x-show="isLive" x-cloak class="inline-flex items-center gap-1.5 font-semibold text-green-800"><span class="size-2 rounded-full bg-green-600"></span> Mode realtime <span x-text="mode === 'polling' ? '(polling)' : ''"></span></span>
                    </div>
                </div>
                <div class="relative h-[28rem]">
                    <div x-ref="map" class="absolute inset-0 z-0"></div>
                    <div x-show="loading" class="absolute inset-0 z-10 bg-white p-4"><div class="skeleton h-full w-full"></div></div>
                    <p x-show="!loading && error" x-cloak class="absolute inset-x-4 top-4 z-10 rounded-lg border border-mr-300 bg-white p-3 text-sm text-mr-700" x-text="error"></p>
                    <p x-show="!loading && !error && loaded && points.length === 0" x-cloak class="absolute inset-x-4 top-4 z-10 rounded-lg bg-white/95 p-3 text-center text-sm text-stone-700 shadow">Tidak ada titik lokasi pada rentang ini.</p>
                </div>
                <div class="flex flex-wrap items-center gap-3 border-t border-stone-100 px-4 py-3" x-show="points.length > 1">
                    <button type="button" class="btn-secondary min-w-28" @click="togglePlay()" :aria-label="playing ? 'Jeda pemutaran' : 'Putar rute'">
                        <i class="fa-solid" :class="playing ? 'fa-pause' : 'fa-play'" aria-hidden="true"></i><span x-text="playing ? 'Jeda' : 'Putar'"></span>
                    </button>
                    <label for="playback" class="sr-only">Posisi waktu</label>
                    <input id="playback" type="range" min="0" :max="points.length - 1" x-model.number="position" @input="pause(); seek()" class="min-w-40 flex-1 accent-mr-600">
                    <span class="tabular text-sm text-stone-700" x-text="current ? new Date(current.recorded_at).toLocaleString('id-ID', { timeZone: 'Asia/Jakarta' }) : ''"></span>
                    <span class="tabular text-xs text-stone-600" x-show="current" x-text="current ? `${current.speed_kmh ?? 0} km/j` : ''"></span>
                </div>
            </section>

            <template x-if="livePoints.length > 0">
                <section class="card mb-4 p-4">
                    <h2 class="mb-2 text-sm font-semibold">Titik baru (realtime)</h2>
                    <ul class="tabular space-y-1 text-xs text-stone-700">
                        <template x-for="point in livePoints.slice(0, 5)" :key="point.recorded_at">
                            <li x-text="`${new Date(point.recorded_at).toLocaleTimeString('id-ID', { timeZone: 'Asia/Jakarta' })} · ${point.lat.toFixed(6)}, ${point.lng.toFixed(6)} · ${point.speed_kmh ?? 0} km/j`"></li>
                        </template>
                    </ul>
                </section>
            </template>

            <section class="card overflow-hidden" aria-labelledby="ping-title"
                     x-data="apiList({ url: @js(route('api.v1.admin.location-logs.pings')), syncUrl: false, autoload: false })"
                     @medrive:location-range.window="filters = { ...$event.detail }; apply()">
                <h2 id="ping-title" class="border-b border-stone-100 px-4 py-3 font-semibold">Data ping</h2>
                <x-admin.api-states icon="satellite-dish" empty="Tidak ada ping pada rentang ini" empty-description="Coba perluas rentang waktu (maksimal {{ $retentionDays }} hari)." />
                <div class="relative overflow-x-auto" x-show="rows.length > 0" :class="loading ? 'opacity-60' : ''">
                    <table class="data-table">
                        <thead><tr><th>Waktu</th><th>Koordinat</th><th>Akurasi</th><th>Kecepatan</th><th>Arah</th><th>Baterai</th><th>Provider</th><th>Laporan</th><th>Catatan</th></tr></thead>
                        <tbody>
                            <template x-for="ping in rows" :key="ping.id">
                                <tr :class="ping.is_mock_location ? 'bg-mr-50' : ''">
                                    <td class="tabular whitespace-nowrap" x-text="new Date(ping.recorded_at).toLocaleString('id-ID', { timeZone: 'Asia/Jakarta', day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit' })"></td>
                                    <td class="tabular whitespace-nowrap" x-text="`${ping.latitude.toFixed(6)}, ${ping.longitude.toFixed(6)}`"></td>
                                    <td class="tabular whitespace-nowrap" :class="ping.accuracy_m > 50 ? 'font-semibold text-amber-800' : ''" x-text="ping.accuracy_m !== null ? `${ping.accuracy_m} m` : '-'"></td>
                                    <td class="tabular whitespace-nowrap" x-text="`${ping.speed_kmh ?? '-'} km/j`"></td>
                                    <td class="tabular" x-text="ping.heading !== null ? `${ping.heading}°` : '-'"></td>
                                    <td class="tabular" :class="ping.battery_level !== null && ping.battery_level < 20 ? 'font-semibold text-mr-700' : ''" x-text="ping.battery_level !== null ? `${ping.battery_level}%` : '-'"></td>
                                    <td x-text="ping.provider ?? '-'"></td>
                                    <td class="tabular">
                                        <a x-show="ping.report_id" :href="`/admin/reports/${ping.report_id}`" class="hover:text-mr-700" x-text="`#${ping.report_id}`"></a>
                                        <span x-show="!ping.report_id">-</span>
                                    </td>
                                    <td><span x-show="ping.is_mock_location"><x-admin.badge tone="red" icon="triangle-exclamation">GPS PALSU</x-admin.badge></span></td>
                                </tr>
                            </template>
                        </tbody>
                    </table>
                </div>
                <x-admin.api-pagination />
            </section>
        </div>
    </div>
    </div>
</x-admin.layout>
