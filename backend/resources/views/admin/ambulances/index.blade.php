<x-admin.layout title="Ambulans" :breadcrumbs="['Manajemen Armada' => route('admin.drivers.index')]">
    <x-admin.page-header title="Ambulans" description="Ambulans berstatus tersedia bisa dipilih driver klinik yang sama saat membuka shift.">
        <x-slot:actions><a href="{{ route('admin.ambulances.create') }}" class="btn-primary"><i class="fa-solid fa-plus" aria-hidden="true"></i> Tambah ambulans</a></x-slot:actions>
    </x-admin.page-header>

    <div x-data="adminOptions('clinics,ambulance_types,ambulance_statuses')">
        <div x-data="apiList({ url: @js(route('api.v1.admin.ambulances.index')), filters: { q: '', clinic_id: '', ambulance_type_id: '', status: '' } })">
            <x-admin.api-filter-bar>
                <div>
                    <label for="q" class="form-label">Nomor polisi</label>
                    <input id="q" type="search" x-model="filters.q" placeholder="H 1234" class="form-input uppercase">
                </div>
                <div>
                    <label for="clinic_id" class="form-label">Klinik</label>
                    <select id="clinic_id" x-model="filters.clinic_id" class="form-input">
                        <option value="">Semua klinik</option>
                        <template x-for="item in options.clinics ?? []" :key="item.id"><option :value="String(item.id)" :selected="String(item.id) === filters.clinic_id" x-text="item.name"></option></template>
                    </select>
                </div>
                <div>
                    <label for="ambulance_type_id" class="form-label">Jenis</label>
                    <select id="ambulance_type_id" x-model="filters.ambulance_type_id" class="form-input">
                        <option value="">Semua jenis</option>
                        <template x-for="item in options.ambulance_types ?? []" :key="item.id"><option :value="String(item.id)" :selected="String(item.id) === filters.ambulance_type_id" x-text="item.name"></option></template>
                    </select>
                </div>
                <div>
                    <label for="status" class="form-label">Status</label>
                    <select id="status" x-model="filters.status" class="form-input">
                        <option value="">Semua status</option>
                        <template x-for="item in options.ambulance_statuses ?? []" :key="item.value"><option :value="item.value" :selected="item.value === filters.status" x-text="item.label"></option></template>
                    </select>
                </div>
            </x-admin.api-filter-bar>

            <div class="card overflow-hidden">
                <x-admin.api-states icon="truck-medical" empty="Belum ada ambulans yang cocok" />
                <div class="relative overflow-x-auto" x-show="rows.length > 0" :class="loading ? 'opacity-60' : ''">
                    <table class="data-table">
                        <thead><tr><th>Nomor polisi</th><th>Kendaraan</th><th>Jenis</th><th>Klinik</th><th>Status</th><th>Pemakaian</th><th><span class="sr-only">Aksi</span></th></tr></thead>
                        <tbody>
                            <template x-for="row in rows" :key="row.id">
                                <tr class="hover:bg-stone-50">
                                    <td class="tabular font-semibold whitespace-nowrap" x-text="row.plate_number"></td>
                                    <td>
                                        <div x-text="row.vehicle_name ?? '-'"></div>
                                        <div class="text-xs text-stone-600" x-text="row.year ?? 'Tahun tidak diisi'"></div>
                                    </td>
                                    <td class="whitespace-nowrap" x-text="row.ambulance_type?.name"></td>
                                    <td class="whitespace-nowrap" x-text="row.clinic?.name"></td>
                                    <td>
                                        <div class="flex items-center gap-2">
                                            <x-admin.status-chip />
                                            <label class="sr-only" :for="`status-${row.id}`" x-text="`Ubah status ${row.plate_number}`"></label>
                                            <select :id="`status-${row.id}`" class="form-input min-h-8 w-auto py-0 text-xs" :disabled="row.in_use"
                                                    :title="row.in_use ? 'Sedang dipakai shift aktif' : null"
                                                    @change="window.medrive.action(`/api/v1/admin/ambulances/${row.id}/status`, { method: 'PATCH', body: { status: $event.target.value }, successMessage: `Status ${row.plate_number} diperbarui.` }).catch(() => { $event.target.value = row.status.value })">
                                                <template x-for="item in options.ambulance_statuses ?? []" :key="item.value"><option :value="item.value" :selected="item.value === row.status.value" x-text="item.label"></option></template>
                                            </select>
                                        </div>
                                    </td>
                                    <td>
                                        <template x-if="row.in_use">
                                            <div>
                                                <x-admin.badge tone="blue" icon="user">Sedang dipakai</x-admin.badge>
                                                <div class="mt-1 text-xs text-stone-700" x-text="row.used_by?.name"></div>
                                            </div>
                                        </template>
                                        <span x-show="!row.in_use" class="text-xs text-stone-600">Tidak dipakai</span>
                                    </td>
                                    <td>
                                        <div class="flex justify-end gap-1">
                                            <a :href="`/admin/ambulances/${row.id}/edit`" class="btn-ghost min-h-9 px-2.5 text-xs">Edit</a>
                                            <x-admin.api-delete-button url="`/api/v1/admin/ambulances/${row.id}`" name="row.plate_number" title="Hapus ambulans"
                                                note="Ambulans yang sudah punya riwayat shift atau laporan tidak bisa dihapus; ubah statusnya menjadi nonaktif." />
                                        </div>
                                    </td>
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
