<x-admin.layout title="Statistik dan grafik">
    <div x-data="statisticsPage({ dataUrl: @js(route('admin.statistics.data')), exportUrl: @js(route('admin.statistics.export')), initial: @js($initial) })">
        <x-admin.page-header title="Statistik dan grafik" description="Semua angka dihitung langsung dari data laporan dan dibandingkan dengan periode sebelumnya yang sama panjang.">
            <x-slot:actions>
                <a :href="exportHref" class="btn-secondary"><i class="fa-solid fa-file-csv" aria-hidden="true"></i> Export CSV</a>
            </x-slot:actions>
        </x-admin.page-header>

        <div class="card mb-6 flex flex-col gap-3 p-4 lg:flex-row lg:flex-wrap lg:items-end" role="group" aria-label="Pilih rentang waktu">
            <div class="flex flex-wrap gap-1.5" role="radiogroup" aria-label="Rentang">
                @foreach ($ranges as $key => $label)
                    <button type="button" role="radio" :aria-checked="range === @js($key)" @click="setRange(@js($key))"
                            class="btn min-h-10 border px-3"
                            :class="range === @js($key) ? 'border-mr-600 bg-mr-600 text-white' : 'border-stone-300 bg-white text-stone-800 hover:bg-mr-50'">{{ $label }}</button>
                @endforeach
            </div>
            <div x-show="range === 'year'" x-cloak class="flex items-end gap-2">
                <div>
                    <label for="year" class="form-label">Tahun</label>
                    <select id="year" x-model.number="year" @change="load()" class="form-input">
                        @foreach ($years as $year)<option value="{{ $year }}">{{ $year }}</option>@endforeach
                    </select>
                </div>
            </div>
            <form x-show="range === 'custom'" x-cloak class="flex flex-wrap items-end gap-2" @submit.prevent="load()">
                <div>
                    <label for="from" class="form-label">Dari</label>
                    <input id="from" type="date" x-model="from" required class="form-input">
                </div>
                <div>
                    <label for="to" class="form-label">Sampai</label>
                    <input id="to" type="date" x-model="to" required class="form-input">
                </div>
                <button type="submit" class="btn-primary">Terapkan</button>
            </form>
            <p class="text-sm text-stone-600 lg:ml-auto" x-show="data" x-text="data ? `${data.range.label} · per ${({ hour: 'jam', day: 'hari', month: 'bulan' })[data.range.granularity]}` : ''"></p>
        </div>

        <div x-show="error" x-cloak class="mb-6 rounded-lg border border-mr-300 bg-mr-50 p-4 text-sm text-mr-800" role="alert">
            <span x-text="error"></span>
            <button type="button" class="ml-2 font-semibold underline" @click="load()">Coba lagi</button>
        </div>

        {{-- Ringkasan dengan delta vs periode sebelumnya --}}
        <section class="mb-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-5" aria-label="Ringkasan">
            @foreach ([
                'total' => ['Total laporan', '', false],
                'completed' => ['Selesai', '', true],
                'cancelled' => ['Dibatalkan', '', false],
                'avg_response_minutes' => ['Rata-rata respons', ' menit', false],
                'avg_duration_minutes' => ['Rata-rata durasi total', ' menit', false],
            ] as $key => [$label, $unit, $higherIsBetter])
                <div class="card p-4">
                    <p class="text-sm text-stone-600">{{ $label }}</p>
                    <template x-if="loading && !data"><div class="skeleton mt-2 h-8 w-20"></div></template>
                    <template x-if="data">
                        <div>
                            <p class="tabular mt-1 text-2xl font-bold" x-text="`${data.summary.{{ $key }}.value.toLocaleString('id-ID')}{{ $unit }}`"></p>
                            <p class="mt-1 text-xs text-stone-600" x-data="{ get row() { return data.summary.{{ $key }} } }">
                                <span x-show="row.value === row.previous" class="font-semibold text-stone-700">sama</span>
                                <span x-show="row.value !== row.previous" class="font-semibold"
                                      :class="(row.value > row.previous) === @js($higherIsBetter) ? 'text-green-700' : 'text-mr-700'">
                                    <i class="fa-solid" :class="row.value > row.previous ? 'fa-arrow-trend-up' : 'fa-arrow-trend-down'" aria-hidden="true"></i>
                                    <span x-text="row.delta === null ? 'naik dari 0' : `${row.value > row.previous ? 'naik' : 'turun'} ${Math.abs(row.delta)}%`"></span>
                                </span>
                                <span x-text="`vs ${row.previous.toLocaleString('id-ID')}{{ $unit }}`"></span>
                            </p>
                        </div>
                    </template>
                </div>
            @endforeach
        </section>

        <p x-show="data && isEmpty()" x-cloak class="card mb-6 p-4 text-sm text-stone-700">
            Tidak ada laporan pada rentang ini. Grafik tetap ditampilkan kosong; pilih rentang lain untuk melihat tren.
        </p>

        <div class="grid gap-6 xl:grid-cols-12" :class="{ 'opacity-60': loading && data }">
            @php
                $charts = [
                    ['ref' => 'volume', 'title' => 'Jumlah laporan per periode', 'note' => 'Batang: periode ini. Garis putus-putus: periode sebelumnya.', 'span' => 'xl:col-span-8', 'height' => 'h-72'],
                    ['ref' => 'types', 'title' => 'Distribusi jenis laporan', 'note' => 'Warna mengikuti master jenis laporan.', 'span' => 'xl:col-span-4', 'height' => 'h-72'],
                    ['ref' => 'typeSeries', 'title' => 'Laporan per jenis per periode', 'note' => null, 'span' => 'xl:col-span-6', 'height' => 'h-72'],
                    ['ref' => 'response', 'title' => 'Waktu respons rata-rata', 'note' => 'Dalam menit, hanya laporan yang sudah diambil.', 'span' => 'xl:col-span-6', 'height' => 'h-72'],
                    ['ref' => 'drivers', 'title' => '10 driver dengan laporan terbanyak', 'note' => 'Arahkan kursor ke batang untuk rasio menang broadcast.', 'span' => 'xl:col-span-6', 'height' => 'h-80'],
                    ['ref' => 'hours', 'title' => 'Jam kejadian laporan', 'note' => 'Batang tergelap menandai jam tersibuk.', 'span' => 'xl:col-span-6', 'height' => 'h-80'],
                ];
            @endphp
            @foreach ($charts as $chart)
                <section class="card p-5 {{ $chart['span'] }}" aria-labelledby="chart-{{ $chart['ref'] }}">
                    <h2 id="chart-{{ $chart['ref'] }}" class="font-semibold">{{ $chart['title'] }}</h2>
                    @if ($chart['note'])<p class="text-xs text-stone-600">{{ $chart['note'] }}</p>@endif
                    <div class="relative mt-3 {{ $chart['height'] }}">
                        <div x-show="loading && !data" class="skeleton absolute inset-0"></div>
                        <canvas x-ref="{{ $chart['ref'] }}" role="img" aria-label="{{ $chart['title'] }}"></canvas>
                    </div>
                    @if ($chart['ref'] === 'drivers')
                        <template x-if="data && data.top_drivers.length === 0"><p class="mt-2 text-sm text-stone-600">Belum ada laporan yang ditangani driver pada rentang ini.</p></template>
                    @endif
                </section>
            @endforeach

            <section class="card p-5 xl:col-span-6" aria-labelledby="chart-org">
                <div class="flex flex-wrap items-center justify-between gap-2">
                    <h2 id="chart-org" class="font-semibold">Laporan per armada</h2>
                    <div class="inline-flex rounded-lg border border-stone-300 p-0.5" role="radiogroup" aria-label="Kelompokkan per">
                        <button type="button" role="radio" :aria-checked="orgMode === 'clinic'" @click="orgMode = 'clinic'; renderOrg()" class="min-h-9 rounded-md px-3 text-sm font-semibold" :class="orgMode === 'clinic' ? 'bg-mr-600 text-white' : 'text-stone-700'">Klinik</button>
                        <button type="button" role="radio" :aria-checked="orgMode === 'institution'" @click="orgMode = 'institution'; renderOrg()" class="min-h-9 rounded-md px-3 text-sm font-semibold" :class="orgMode === 'institution' ? 'bg-mr-600 text-white' : 'text-stone-700'">Instansi</button>
                    </div>
                </div>
                <p class="text-xs text-stone-600">Berdasarkan klinik pemilik ambulans yang menangani laporan.</p>
                <div class="relative mt-3 h-72">
                    <div x-show="loading && !data" class="skeleton absolute inset-0"></div>
                    <canvas x-ref="org" role="img" aria-label="Grafik laporan per klinik atau instansi"></canvas>
                </div>
            </section>

            <section class="card p-5 xl:col-span-6" aria-labelledby="chart-statuses">
                <h2 id="chart-statuses" class="font-semibold">Status laporan</h2>
                <div class="mt-3 grid gap-4 md:grid-cols-2">
                    <div class="relative h-64">
                        <div x-show="loading && !data" class="skeleton absolute inset-0"></div>
                        <canvas x-ref="statuses" role="img" aria-label="Diagram status laporan"></canvas>
                    </div>
                    <table class="data-table self-start">
                        <thead><tr><th>Status</th><th class="text-right">Jumlah</th></tr></thead>
                        <tbody>
                            <template x-for="status in data?.by_status ?? []" :key="status.status">
                                <tr><td><span class="mr-2 inline-block size-2.5 rounded-sm align-middle" :style="`background:${window.statusColor(status.status)}`"></span><span x-text="status.label"></span></td><td class="tabular text-right" x-text="status.total"></td></tr>
                            </template>
                        </tbody>
                        <tfoot x-show="data">
                            <tr><td class="px-3 py-2 font-semibold">Total</td><td class="tabular px-3 py-2 text-right font-semibold" x-text="data?.summary.total.value"></td></tr>
                            <tr><td class="px-3 py-2 text-stone-600">Rata-rata durasi selesai</td><td class="tabular px-3 py-2 text-right" x-text="data ? `${data.summary.avg_duration_minutes.value} menit` : ''"></td></tr>
                        </tfoot>
                    </table>
                </div>
            </section>
        </div>
    </div>
</x-admin.layout>
