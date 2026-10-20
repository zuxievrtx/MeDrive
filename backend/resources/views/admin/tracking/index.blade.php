<x-admin.layout title="Peta Live" :breadcrumbs="['Laporan Darurat' => route('admin.reports.index')]">
    <div x-data="adminOptions('clinics,ambulance_types')">
    <div x-data="trackingMap({ dataUrl: @js(route('api.v1.admin.tracking.live')) })" @medrive:end-shift.window="openEndShift($event.detail)">
        <x-admin.page-header title="Peta Live" description="Posisi driver dengan shift terbuka dari lokasi terakhir dan event realtime. Driver tanpa update lebih dari {{ config('medrive.signal_lost_seconds') }} detik ditandai sinyal hilang.">
            <x-slot:actions>
                <span class="inline-flex items-center gap-2 text-sm text-stone-700" role="status">
                    <span class="size-2.5 rounded-full" :class="mode === 'realtime' ? 'bg-green-600' : 'bg-amber-500'"></span>
                    <span x-text="mode === 'realtime' ? 'Realtime terhubung' : 'Polling tiap 10 detik'"></span>
                </span>
                <button type="button" class="btn-secondary" @click="fitAll()"><i class="fa-solid fa-expand" aria-hidden="true"></i> Tampilkan semua</button>
            </x-slot:actions>
        </x-admin.page-header>

        <div class="card mb-4 grid gap-3 p-4 sm:grid-cols-3 lg:items-end" role="search" aria-label="Filter peta">
            <div>
                <label for="filter-clinic" class="form-label">Klinik</label>
                <select id="filter-clinic" x-model="filters.clinic" @change="redraw()" class="form-input">
                    <option value="">Semua klinik</option>
                    <template x-for="item in options.clinics ?? []" :key="item.id"><option :value="String(item.id)" x-text="item.name"></option></template>
                </select>
            </div>
            <div>
                <label for="filter-type" class="form-label">Jenis ambulans</label>
                <select id="filter-type" x-model="filters.type" @change="redraw()" class="form-input">
                    <option value="">Semua jenis</option>
                    <template x-for="item in options.ambulance_types ?? []" :key="item.id"><option :value="String(item.id)" x-text="item.name"></option></template>
                </select>
            </div>
            <label class="inline-flex min-h-10 items-center gap-3 text-sm">
                <input type="checkbox" x-model="filters.onDutyOnly" @change="redraw()" class="size-4 accent-mr-600">
                Hanya yang sedang bertugas
            </label>
        </div>

        <x-admin.escalation-panel class="mb-4" />

        <div class="grid gap-4 xl:grid-cols-[minmax(0,1fr)_22rem]">
            <section class="card relative h-[min(70vh,44rem)] min-h-96 overflow-hidden" aria-label="Peta posisi driver">
                <div x-ref="map" class="absolute inset-0 z-0"></div>
                <div x-show="loading" class="absolute inset-0 z-10 bg-white p-4"><div class="skeleton h-full w-full"></div></div>
                <div x-show="!loading && error" x-cloak class="absolute inset-x-4 top-4 z-10 rounded-lg border border-mr-300 bg-white p-3 text-sm text-mr-700 shadow" x-text="error"></div>
                <div x-show="followId" x-cloak class="absolute bottom-4 left-1/2 z-[500] -translate-x-1/2">
                    <button type="button" class="btn-secondary shadow" @click="stopFollow()"><i class="fa-solid fa-location-crosshairs" aria-hidden="true"></i> Berhenti mengikuti</button>
                </div>
                <div class="absolute right-3 bottom-3 z-[400] rounded-lg bg-white/95 px-3 py-2 text-xs shadow">
                    <div class="flex items-center gap-2"><span class="size-2.5 rounded-full bg-mr-600"></span> Menangani laporan</div>
                    <div class="flex items-center gap-2"><span class="size-2.5 rounded-full bg-stone-700"></span> Standby</div>
                    <div class="flex items-center gap-2"><span class="size-2.5 rounded-full bg-stone-400"></span> Sinyal hilang</div>
                </div>
            </section>

            <aside class="card flex max-h-[min(70vh,44rem)] min-h-64 flex-col overflow-hidden" aria-labelledby="driver-list-title">
                <div class="border-b border-stone-100 px-4 py-3">
                    <h2 id="driver-list-title" class="font-semibold">Driver aktif <span class="tabular text-stone-600" x-text="`(${visibleDrivers.length})`"></span></h2>
                </div>
                <div class="flex-1 overflow-y-auto">
                    <template x-if="loading"><x-admin.skeleton-rows :rows="5" /></template>
                    <template x-if="!loading && visibleDrivers.length === 0">
                        <p class="p-4 text-sm text-stone-600">Tidak ada driver aktif yang cocok dengan filter.</p>
                    </template>
                    <ul class="divide-y divide-stone-100">
                        <template x-for="driver in visibleDrivers" :key="driver.driver_id">
                            <li>
                                <button type="button" @click="focus(driver)"
                                        class="block w-full px-4 py-3 text-left hover:bg-stone-50"
                                        :class="{ 'bg-mr-50': selectedId === driver.driver_id, 'opacity-60': isStale(driver) }">
                                    <div class="flex items-center justify-between gap-2">
                                        <span class="font-semibold" x-text="driver.name"></span>
                                        <span class="text-xs font-semibold" :class="driver.is_on_duty ? 'text-mr-700' : 'text-stone-600'" x-text="driver.is_on_duty ? 'Bertugas' : 'Standby'"></span>
                                    </div>
                                    <div class="tabular text-xs text-stone-700"><span x-text="driver.plate_number"></span> · <span x-text="driver.ambulance_type"></span></div>
                                    <div x-show="driver.report_code" class="text-xs text-stone-700">Menangani <span class="tabular font-semibold" x-text="driver.report_code"></span></div>
                                    <div class="mt-1 flex flex-wrap gap-x-3 text-xs text-stone-600">
                                        <span class="tabular"><i class="fa-solid fa-gauge mr-1" aria-hidden="true"></i><span x-text="driver.speed_kmh ?? 0"></span> km/j</span>
                                        <span class="tabular" :class="driver.battery_level !== null && driver.battery_level < 20 ? 'font-semibold text-mr-700' : ''">
                                            <i class="fa-solid mr-1" :class="driver.battery_level !== null && driver.battery_level < 20 ? 'fa-battery-quarter' : 'fa-battery-three-quarters'" aria-hidden="true"></i>
                                            <span x-text="driver.battery_level !== null ? `${driver.battery_level}%` : 'menunggu ping'"></span>
                                            <span x-show="driver.battery_level !== null && driver.battery_level < 20">rendah</span>
                                        </span>
                                        <span x-show="driver.is_mock_location" class="font-semibold text-mr-700"><i class="fa-solid fa-location-crosshairs mr-1" aria-hidden="true"></i>lokasi palsu</span>
                                        <span :class="isStale(driver) ? 'font-semibold text-mr-700' : ''" x-text="isStale(driver) ? `sinyal hilang, ${agoLabel(driver.recorded_at)}` : `update ${agoLabel(driver.recorded_at)}`" :data-tick="tick"></span>
                                    </div>
                                </button>
                            </li>
                        </template>
                    </ul>
                </div>
            </aside>
        </div>

        <x-admin.modal show="endShift.open" title="Akhiri shift driver">
            <p class="text-sm text-stone-700">Shift <strong x-text="endShift.name"></strong> akan ditutup dengan alasan <strong>dihentikan admin</strong>. Laporan yang sedang ditangani tidak diubah.</p>
            <div class="mt-6 flex justify-end gap-2">
                <button type="button" class="btn-secondary" @click="endShift.open = false">Batal</button>
                <button type="button" class="btn-danger" :disabled="endShift.submitting" @click="confirmEndShift()">Akhiri shift</button>
            </div>
        </x-admin.modal>
    </div>
    </div>
</x-admin.layout>
