<x-admin.layout title="Master jenis laporan">
    <x-admin.page-header title="Master jenis laporan" description="Aturan tiap jenis laporan, termasuk jenis ambulans yang menerima broadcast. Warna dan ikon di sini dipakai di seluruh dashboard." />

    <div class="card overflow-hidden" x-data="apiList({ url: @js(route('api.v1.admin.report-types.index')), syncUrl: false })">
        <x-admin.api-states icon="list-check" empty="Belum ada jenis laporan" :rows="4" />
        <div class="relative overflow-x-auto" x-show="rows.length > 0">
            <table class="data-table">
                <thead><tr><th>Urutan</th><th>Jenis</th><th>Warna</th><th>Prioritas</th><th>Darurat</th><th>Wajib tujuan</th><th>Dilayani ambulans</th><th>Laporan</th><th>Status</th><th><span class="sr-only">Aksi</span></th></tr></thead>
                <tbody>
                    <template x-for="row in rows" :key="row.id">
                        <tr>
                            <td class="tabular" x-text="row.sort_order"></td>
                            <td>
                                <x-admin.type-chip type="row" />
                                <div class="mt-1 max-w-xs text-xs text-stone-600" x-text="row.description"></div>
                            </td>
                            <td><span class="tabular inline-flex items-center gap-2 text-xs"><span class="size-5 rounded border border-stone-300" :style="`background:${row.color ?? '#57534e'}`"></span><span x-text="row.color ?? '-'"></span></span></td>
                            <td><span class="inline-flex rounded-md px-2 py-0.5 text-xs font-semibold ring-1 ring-inset" :class="window.badgeTone(row.priority === 1 ? 'red' : 'gray')" x-text="`P${row.priority}`"></span></td>
                            <td x-text="row.is_emergency ? 'Ya' : 'Tidak, bisa dijadwalkan'"></td>
                            <td x-text="row.requires_destination ? 'Ya' : 'Tidak'"></td>
                            <td>
                                <ul class="space-y-0.5 text-xs">
                                    <template x-for="type in row.ambulance_types" :key="type.id"><li class="whitespace-nowrap" x-text="type.name"></li></template>
                                    <li x-show="row.ambulance_types.length === 0" class="font-semibold text-mr-700">Belum ada penerima</li>
                                </ul>
                            </td>
                            <td class="tabular" x-text="row.reports_count"></td>
                            <td><x-admin.active-chip /></td>
                            <td><a :href="`/admin/report-types/${row.id}/edit`" class="btn-ghost min-h-9 px-2.5 text-xs">Edit</a></td>
                        </tr>
                    </template>
                </tbody>
            </table>
        </div>
    </div>
</x-admin.layout>
