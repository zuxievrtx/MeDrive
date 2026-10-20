<x-admin.layout title="Klinik" :breadcrumbs="['Organisasi' => route('admin.institutions.index')]">
    <x-admin.page-header title="Klinik" description="Klinik, puskesmas, rumah sakit, dan pos ambulans tempat driver dan ambulans bernaung. Klinik juga muncul sebagai pilihan faskes tujuan di aplikasi pelapor.">
        <x-slot:actions><a href="{{ route('admin.clinics.create') }}" class="btn-primary"><i class="fa-solid fa-plus" aria-hidden="true"></i> Tambah klinik</a></x-slot:actions>
    </x-admin.page-header>

    <div x-data="adminOptions('institutions,clinic_types')">
        <div x-data="apiList({ url: @js(route('api.v1.admin.clinics.index')), filters: { q: '', institution_id: '', type: '', active: '' } })">
            <x-admin.api-filter-bar>
                <div>
                    <label for="q" class="form-label">Cari</label>
                    <input id="q" type="search" x-model="filters.q" placeholder="Nama, kode, alamat" class="form-input">
                </div>
                <div>
                    <label for="institution_id" class="form-label">Instansi</label>
                    <select id="institution_id" x-model="filters.institution_id" class="form-input">
                        <option value="">Semua instansi</option>
                        <template x-for="item in options.institutions ?? []" :key="item.id"><option :value="String(item.id)" :selected="String(item.id) === filters.institution_id" x-text="item.name"></option></template>
                    </select>
                </div>
                <div>
                    <label for="type" class="form-label">Jenis</label>
                    <select id="type" x-model="filters.type" class="form-input">
                        <option value="">Semua jenis</option>
                        <template x-for="item in options.clinic_types ?? []" :key="item.value"><option :value="item.value" :selected="item.value === filters.type" x-text="item.label"></option></template>
                    </select>
                </div>
                <div>
                    <label for="active" class="form-label">Status</label>
                    <select id="active" x-model="filters.active" class="form-input">
                        <option value="">Semua</option>
                        <option value="1">Aktif</option>
                        <option value="0">Nonaktif</option>
                    </select>
                </div>
            </x-admin.api-filter-bar>

            <div class="card overflow-hidden">
                <x-admin.api-states icon="house-medical" empty="Belum ada klinik yang cocok" />
                <div class="relative overflow-x-auto" x-show="rows.length > 0" :class="loading ? 'opacity-60' : ''">
                    <table class="data-table">
                        <thead><tr><th>Kode</th><th>Klinik</th><th>Instansi</th><th>Jenis</th><th>Koordinat</th><th>Driver</th><th>Ambulans</th><th>Status</th><th><span class="sr-only">Aksi</span></th></tr></thead>
                        <tbody>
                            <template x-for="row in rows" :key="row.id">
                                <tr class="hover:bg-stone-50">
                                    <td class="tabular font-semibold whitespace-nowrap" x-text="row.code"></td>
                                    <td>
                                        <div class="font-medium" x-text="row.name"></div>
                                        <div class="text-xs text-stone-600" x-text="row.address"></div>
                                    </td>
                                    <td class="whitespace-nowrap" x-text="row.institution?.name"></td>
                                    <td class="whitespace-nowrap" x-text="row.type?.label"></td>
                                    <td class="tabular text-xs whitespace-nowrap">
                                        <a :href="`https://www.openstreetmap.org/?mlat=${row.latitude}&mlon=${row.longitude}#map=17/${row.latitude}/${row.longitude}`" target="_blank" rel="noopener" class="hover:text-mr-700"
                                           x-text="`${row.latitude.toFixed(5)}, ${row.longitude.toFixed(5)}`"></a>
                                    </td>
                                    <td><a :href="`/admin/drivers?clinic_id=${row.id}`" class="tabular font-semibold hover:text-mr-700" x-text="row.driver_profiles_count"></a></td>
                                    <td><a :href="`/admin/ambulances?clinic_id=${row.id}`" class="tabular font-semibold hover:text-mr-700" x-text="row.ambulances_count"></a></td>
                                    <td><x-admin.active-chip /></td>
                                    <td>
                                        <div class="flex justify-end gap-1">
                                            <a :href="`/admin/clinics/${row.id}/edit`" class="btn-ghost min-h-9 px-2.5 text-xs">Edit</a>
                                            <x-admin.api-delete-button url="`/api/v1/admin/clinics/${row.id}`" name="row.name" title="Hapus klinik"
                                                note="Klinik yang masih memiliki driver atau ambulans tidak bisa dihapus; nonaktifkan saja bila sudah tidak dipakai." />
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
