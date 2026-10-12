<x-admin.layout title="Log Lokasi" :breadcrumbs="['Laporan Darurat' => route('admin.reports.index')]">
    <x-admin.page-header title="Log Lokasi" description="Rute historis per driver dari log lokasi detail. Rentang maksimal {{ $retentionDays }} hari sesuai masa simpan log." />

    <form method="GET" action="{{ route('admin.location-logs.index') }}" class="card mb-4 grid gap-3 p-4 md:grid-cols-2 xl:grid-cols-[2fr_1.5fr_1.5fr_auto_auto] xl:items-end" role="search">
        @if ($report)<input type="hidden" name="report_id" value="{{ $report->id }}">@endif
        <div>
            <label for="driver_id" class="form-label">Driver</label>
            <select id="driver_id" name="driver_id" required class="form-input">
                <option value="">Pilih driver</option>
                @foreach ($drivers as $option)<option value="{{ $option->id }}" @selected(($filters['driver_id'] ?? null) == $option->id)>{{ $option->name }}</option>@endforeach
            </select>
        </div>
        <div>
            <label for="from" class="form-label">Dari</label>
            <input id="from" name="from" type="datetime-local" value="{{ $from->format('Y-m-d\TH:i') }}" min="{{ now()->subDays($retentionDays)->format('Y-m-d\TH:i') }}" class="form-input">
            @error('from')<p class="form-error">{{ $message }}</p>@enderror
        </div>
        <div>
            <label for="to" class="form-label">Sampai</label>
            <input id="to" name="to" type="datetime-local" value="{{ $to->format('Y-m-d\TH:i') }}" class="form-input">
            @error('to')<p class="form-error">{{ $message }}</p>@enderror
        </div>
        <label class="inline-flex min-h-10 items-center gap-2 text-sm whitespace-nowrap">
            <input type="checkbox" name="accurate_only" value="1" class="size-4 accent-mr-600" @checked($filters['accurate_only'] ?? false)>
            Saring akurasi &gt; 50 m
        </label>
        <button type="submit" class="btn-primary"><i class="fa-solid fa-magnifying-glass-location" aria-hidden="true"></i> Tampilkan rute</button>
    </form>

    @if ($report)
        <p class="mb-4 text-sm text-stone-700">Rute difilter untuk laporan <a href="{{ route('admin.reports.show', $report) }}" class="tabular font-semibold text-mr-700 hover:underline">{{ $report->code }}</a>.
            <a href="{{ route('admin.location-logs.index', array_filter(['driver_id' => $filters['driver_id'] ?? null])) }}" class="font-semibold hover:underline">Hapus filter laporan</a></p>
    @endif

    @if (! $driver)
        <div class="card">
            <x-admin.empty-state icon="route" title="Pilih driver untuk melihat rute" description="Default rentang adalah 1 jam terakhir. Untuk rute satu laporan, buka dari halaman detail laporan." />
        </div>
    @else
        @if ($mockCount > 0)
            <div class="mb-4 flex gap-3 rounded-lg border border-mr-300 bg-mr-50 p-4 text-sm text-mr-800" role="alert">
                <i class="fa-solid fa-triangle-exclamation mt-0.5" aria-hidden="true"></i>
                <div><strong>Terdeteksi {{ $mockCount }} titik GPS palsu</strong> pada rentang ini. Titik tersebut ditandai merah di tabel dan peta; periksa perangkat driver.</div>
            </div>
        @endif

        <div x-data="locationLogMap({
                dataUrl: @js(route('admin.location-logs.data')),
                trackingUrl: @js(route('admin.tracking.data')),
                params: @js(array_merge($filters, ['from' => $from->toDateTimeString(), 'to' => $to->toDateTimeString()])),
                live: @js($isLive),
             })">
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
                    <h2 class="font-semibold">Rute {{ $driver->name }}</h2>
                    <div class="flex items-center gap-3 text-xs text-stone-600">
                        <span x-show="summary?.sampled" x-cloak>Titik di peta disederhanakan agar ringan.</span>
                        @if ($isLive)
                            <span class="inline-flex items-center gap-1.5 font-semibold text-green-800"><span class="size-2 rounded-full bg-green-600"></span> Mode realtime <span x-text="mode === 'polling' ? '(polling)' : ''"></span></span>
                        @endif
                    </div>
                </div>
                <div class="relative h-[28rem]">
                    <div x-ref="map" class="absolute inset-0 z-0"></div>
                    <div x-show="loading" class="absolute inset-0 z-10 bg-white p-4"><div class="skeleton h-full w-full"></div></div>
                    <p x-show="!loading && error" x-cloak class="absolute inset-x-4 top-4 z-10 rounded-lg border border-mr-300 bg-white p-3 text-sm text-mr-700" x-text="error"></p>
                    <p x-show="!loading && !error && points.length === 0" x-cloak class="absolute inset-x-4 top-4 z-10 rounded-lg bg-white/95 p-3 text-center text-sm text-stone-700 shadow">Tidak ada titik lokasi pada rentang ini.</p>
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
        </div>

        <section class="card overflow-hidden" aria-labelledby="ping-title">
            <h2 id="ping-title" class="border-b border-stone-100 px-4 py-3 font-semibold">Data ping</h2>
            @if ($pings->isEmpty())
                <x-admin.empty-state icon="satellite-dish" title="Tidak ada ping pada rentang ini" description="Coba perluas rentang waktu (maksimal {{ $retentionDays }} hari)." />
            @else
                <div class="relative overflow-x-auto">
                    <table class="data-table">
                        <thead><tr><th>Waktu</th><th>Koordinat</th><th>Akurasi</th><th>Kecepatan</th><th>Arah</th><th>Baterai</th><th>Provider</th><th>Laporan</th><th>Catatan</th></tr></thead>
                        <tbody>
                            @foreach ($pings as $ping)
                                <tr @class(['bg-mr-50' => $ping->is_mock_location])>
                                    <td class="tabular whitespace-nowrap">{{ $ping->recorded_at->format('d/m/Y H:i:s') }}</td>
                                    <td class="tabular whitespace-nowrap">{{ number_format((float) $ping->latitude, 6) }}, {{ number_format((float) $ping->longitude, 6) }}</td>
                                    <td @class(['tabular whitespace-nowrap', 'font-semibold text-amber-800' => $ping->accuracy_m > 50])>{{ $ping->accuracy_m !== null ? $ping->accuracy_m.' m' : '-' }}</td>
                                    <td class="tabular whitespace-nowrap">{{ $ping->speed_kmh ?? '-' }} km/j</td>
                                    <td class="tabular">{{ $ping->heading !== null ? $ping->heading.'°' : '-' }}</td>
                                    <td @class(['tabular', 'font-semibold text-mr-700' => $ping->battery_level !== null && $ping->battery_level < 20])>{{ $ping->battery_level !== null ? $ping->battery_level.'%' : '-' }}</td>
                                    <td>{{ $ping->provider ?? '-' }}</td>
                                    <td class="tabular">{{ $ping->report_id ? '#'.$ping->report_id : '-' }}</td>
                                    <td>@if ($ping->is_mock_location)<x-admin.badge tone="red" icon="triangle-exclamation">GPS PALSU</x-admin.badge>@endif</td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
                <div class="border-t border-stone-100 px-4 py-3">{{ $pings->links() }}</div>
            @endif
        </section>
    @endif
</x-admin.layout>
