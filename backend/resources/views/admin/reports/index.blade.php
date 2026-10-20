<x-admin.layout title="Daftar laporan" :breadcrumbs="['Laporan Darurat' => route('admin.reports.index')]">
    <div x-data="adminOptions('report_types,report_statuses,drivers,clinics')">
        <div x-data="apiList({ url: @js(route('api.v1.admin.reports.index')), filters: { q: '', type: '', status: '', from: '', to: '', driver_id: '', clinic_id: '' }, refreshOn: ['medrive:report-created', 'medrive:report-status'] })">
            <x-admin.page-header title="Daftar laporan" description="Laporan dibuat pelapor dari aplikasi dan diambil driver lewat broadcast. Admin memantau dan hanya bisa membatalkan laporan yang masih menunggu.">
                <x-slot:actions>
                    <a :href="exportUrl('/api/v1/admin/reports/export')" class="btn-secondary"><i class="fa-solid fa-file-csv" aria-hidden="true"></i> Export CSV</a>
                </x-slot:actions>
            </x-admin.page-header>

            <x-admin.api-filter-bar>
                <div>
                    <label for="q" class="form-label">Cari</label>
                    <input id="q" type="search" x-model="filters.q" placeholder="Kode, deskripsi, alamat" class="form-input">
                </div>
                <div>
                    <label for="type" class="form-label">Jenis</label>
                    <select id="type" x-model="filters.type" class="form-input">
                        <option value="">Semua jenis</option>
                        <template x-for="item in options.report_types ?? []" :key="item.id"><option :value="String(item.id)" x-text="item.name" :selected="String(item.id) === filters.type"></option></template>
                    </select>
                </div>
                <div>
                    <label for="status" class="form-label">Status</label>
                    <select id="status" x-model="filters.status" class="form-input">
                        <option value="">Semua status</option>
                        <template x-for="item in options.report_statuses ?? []" :key="item.value"><option :value="item.value" x-text="item.label" :selected="item.value === filters.status"></option></template>
                    </select>
                </div>
                <div>
                    <label for="from" class="form-label">Dari tanggal</label>
                    <input id="from" type="date" x-model="filters.from" class="form-input">
                </div>
                <div>
                    <label for="to" class="form-label">Sampai tanggal</label>
                    <input id="to" type="date" x-model="filters.to" class="form-input">
                </div>
                <div>
                    <label for="driver_id" class="form-label">Driver</label>
                    <select id="driver_id" x-model="filters.driver_id" class="form-input">
                        <option value="">Semua driver</option>
                        <template x-for="item in options.drivers ?? []" :key="item.id"><option :value="String(item.id)" x-text="item.name" :selected="String(item.id) === filters.driver_id"></option></template>
                    </select>
                </div>
                <div>
                    <label for="clinic_id" class="form-label">Klinik armada</label>
                    <select id="clinic_id" x-model="filters.clinic_id" class="form-input">
                        <option value="">Semua klinik</option>
                        <template x-for="item in options.clinics ?? []" :key="item.id"><option :value="String(item.id)" x-text="item.name" :selected="String(item.id) === filters.clinic_id"></option></template>
                    </select>
                </div>
            </x-admin.api-filter-bar>

            <div class="card overflow-hidden">
                <x-admin.api-states icon="file-medical" empty="Tidak ada laporan yang cocok" empty-description="Ubah filter atau rentang tanggal." />
                <div class="relative overflow-x-auto" x-show="rows.length > 0" :class="loading ? 'opacity-60' : ''">
                    <table class="data-table">
                        <thead><tr><th>Kode</th><th>Jenis</th><th>Status</th><th>Pelapor</th><th>Driver</th><th>Alamat</th><th>Dibuat</th><th>Respons</th></tr></thead>
                        <tbody>
                            <template x-for="row in rows" :key="row.id">
                                <tr class="cursor-pointer" :class="row.is_stale ? 'bg-amber-50 hover:bg-amber-100' : 'hover:bg-stone-50'"
                                    @click="if (!$event.target.closest('a')) window.location = `/admin/reports/${row.id}`">
                                    <td>
                                        <a :href="`/admin/reports/${row.id}`" class="tabular font-semibold whitespace-nowrap hover:text-mr-700" x-text="row.code"></a>
                                        <div x-show="row.is_stale" class="mt-1 flex items-center gap-1.5 text-xs font-semibold whitespace-nowrap text-mr-700">
                                            <span class="relative flex size-2"><span class="absolute inline-flex size-full animate-ping rounded-full bg-mr-500 opacity-75 motion-reduce:animate-none"></span><span class="relative inline-flex size-2 rounded-full bg-mr-600"></span></span>
                                            <span x-text="`Menunggu ${window.durationLabel(row.waiting_minutes)}`"></span>
                                        </div>
                                    </td>
                                    <td><x-admin.type-chip /></td>
                                    <td><x-admin.status-chip /></td>
                                    <td class="whitespace-nowrap">
                                        <div x-text="row.reporter?.name"></div>
                                        <div class="text-xs text-stone-600" x-text="row.reporter?.phone"></div>
                                    </td>
                                    <td class="whitespace-nowrap">
                                        <template x-if="row.driver">
                                            <div>
                                                <div x-text="row.driver.name"></div>
                                                <div class="tabular text-xs text-stone-600" x-text="row.ambulance?.plate_number"></div>
                                            </div>
                                        </template>
                                        <span x-show="!row.driver" class="text-xs text-stone-600">Belum ada</span>
                                    </td>
                                    <td class="max-w-56 text-stone-700" x-text="row.short_address"></td>
                                    <td class="tabular whitespace-nowrap" :title="window.timeAgo(row.created_at)" x-text="window.formatDate(row.created_at)"></td>
                                    <td class="tabular whitespace-nowrap" x-text="row.response_time_minutes !== null ? `${row.response_time_minutes} mnt` : '-'"></td>
                                </tr>
                            </template>
                        </tbody>
                    </table>
                </div>
                <x-admin.api-pagination />
            </div>
        </div>
    </div>
</x-admin.layout>
