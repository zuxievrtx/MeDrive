<x-admin.layout title="Instansi" :breadcrumbs="['Organisasi' => route('admin.institutions.index')]">
    <x-admin.page-header title="Instansi" description="Lembaga induk klinik dan pos ambulans: dinas kesehatan, PMI, yayasan, atau swasta.">
        <x-slot:actions><a href="{{ route('admin.institutions.create') }}" class="btn-primary"><i class="fa-solid fa-plus" aria-hidden="true"></i> Tambah instansi</a></x-slot:actions>
    </x-admin.page-header>

    <div x-data="adminOptions('institution_types')">
        <div x-data="apiList({ url: @js(route('api.v1.admin.institutions.index')), filters: { q: '', type: '', active: '' } })">
            <x-admin.api-filter-bar>
                <div>
                    <label for="q" class="form-label">Cari</label>
                    <input id="q" type="search" x-model="filters.q" placeholder="Nama atau kode" class="form-input">
                </div>
                <div>
                    <label for="type" class="form-label">Jenis</label>
                    <select id="type" x-model="filters.type" class="form-input">
                        <option value="">Semua jenis</option>
                        <template x-for="item in options.institution_types ?? []" :key="item.value"><option :value="item.value" :selected="item.value === filters.type" x-text="item.label"></option></template>
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
                <x-admin.api-states icon="building" empty="Belum ada instansi yang cocok" />
                <div class="relative overflow-x-auto" x-show="rows.length > 0" :class="loading ? 'opacity-60' : ''">
                    <table class="data-table">
                        <thead><tr><th>Kode</th><th>Nama</th><th>Jenis</th><th>Kontak</th><th>Klinik</th><th>Status</th><th><span class="sr-only">Aksi</span></th></tr></thead>
                        <tbody>
                            <template x-for="row in rows" :key="row.id">
                                <tr class="hover:bg-stone-50">
                                    <td class="tabular font-semibold whitespace-nowrap" x-text="row.code"></td>
                                    <td>
                                        <div class="font-medium" x-text="row.name"></div>
                                        <div class="text-xs text-stone-600" x-text="row.address ?? '-'"></div>
                                    </td>
                                    <td x-text="row.type?.label"></td>
                                    <td class="text-xs whitespace-nowrap">
                                        <div x-text="row.phone ?? '-'"></div>
                                        <div class="text-stone-600" x-text="row.email ?? ''"></div>
                                    </td>
                                    <td><a :href="`/admin/clinics?institution_id=${row.id}`" class="tabular font-semibold hover:text-mr-700" x-text="row.clinics_count"></a></td>
                                    <td><x-admin.active-chip /></td>
                                    <td>
                                        <div class="flex justify-end gap-1">
                                            <a :href="`/admin/institutions/${row.id}/edit`" class="btn-ghost min-h-9 px-2.5 text-xs">Edit</a>
                                            <x-admin.api-delete-button url="`/api/v1/admin/institutions/${row.id}`" name="row.name" title="Hapus instansi"
                                                note="Instansi yang masih memiliki klinik tidak bisa dihapus; nonaktifkan saja bila sudah tidak dipakai." />
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
