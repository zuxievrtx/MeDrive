<x-admin.layout title="Jenis ambulans" :breadcrumbs="['Manajemen Armada' => route('admin.drivers.index')]">
    <x-admin.page-header title="Jenis ambulans" description="Kode jenis dipakai aturan broadcast sehingga tidak bisa diubah. Jenis laporan yang dilayani diatur di Master Jenis Laporan." />

    <div class="card overflow-hidden" x-data="apiList({ url: @js(route('api.v1.admin.ambulance-types.index')), syncUrl: false })">
        <x-admin.api-states icon="tags" empty="Belum ada jenis ambulans" :rows="3" />
        <div class="relative overflow-x-auto" x-show="rows.length > 0">
            <table class="data-table">
                <thead><tr><th>Kode</th><th>Nama</th><th>Deskripsi</th><th>Melayani laporan</th><th>Armada</th><th><span class="sr-only">Aksi</span></th></tr></thead>
                <tbody>
                    <template x-for="row in rows" :key="row.id">
                        <tr>
                            <td class="tabular text-xs font-semibold whitespace-nowrap text-stone-700" x-text="row.code"></td>
                            <td class="font-medium whitespace-nowrap"><i class="fa-solid mr-1.5 text-stone-500" :class="`fa-${row.map_icon}`" aria-hidden="true"></i><span x-text="row.name"></span></td>
                            <td class="text-stone-700" x-text="row.description ?? '-'"></td>
                            <td>
                                <div class="flex flex-wrap gap-1">
                                    <template x-for="type in row.report_types" :key="type.id"><x-admin.type-chip type="type" /></template>
                                    <span x-show="row.report_types.length === 0" class="text-xs text-stone-600">Belum melayani jenis apa pun</span>
                                </div>
                            </td>
                            <td><a :href="`/admin/ambulances?ambulance_type_id=${row.id}`" class="tabular font-semibold hover:text-mr-700" x-text="row.ambulances_count"></a></td>
                            <td><a :href="`/admin/ambulance-types/${row.id}/edit`" class="btn-ghost min-h-9 px-2.5 text-xs">Edit</a></td>
                        </tr>
                    </template>
                </tbody>
            </table>
        </div>
    </div>
</x-admin.layout>
