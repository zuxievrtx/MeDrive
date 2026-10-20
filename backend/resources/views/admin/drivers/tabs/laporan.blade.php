<section class="card overflow-hidden" x-data="apiList({ url: @js(route('api.v1.admin.drivers.reports', $driverId)), syncUrl: false })">
    <div class="border-b border-stone-100 px-5 py-3"><h2 class="font-semibold">Laporan yang ditangani</h2></div>
    <x-admin.api-states icon="file-medical" empty="Belum menangani laporan" empty-description="Laporan yang diambil driver ini akan tercantum di sini." />
    <div class="relative overflow-x-auto" x-show="rows.length > 0">
        <table class="data-table">
            <thead><tr><th>Kode</th><th>Jenis</th><th>Status</th><th>Ambulans</th><th>Dibuat</th><th>Respons</th></tr></thead>
            <tbody>
                <template x-for="row in rows" :key="row.id">
                    <tr class="hover:bg-stone-50">
                        <td><a :href="`/admin/reports/${row.id}`" class="tabular font-semibold whitespace-nowrap hover:text-mr-700" x-text="row.code"></a></td>
                        <td><x-admin.type-chip /></td>
                        <td><x-admin.status-chip /></td>
                        <td class="tabular whitespace-nowrap" x-text="row.ambulance?.plate_number ?? '-'"></td>
                        <td class="tabular whitespace-nowrap" x-text="window.formatDate(row.created_at)"></td>
                        <td class="tabular whitespace-nowrap" x-text="row.response_time_minutes !== null ? `${row.response_time_minutes} menit` : '-'"></td>
                    </tr>
                </template>
            </tbody>
        </table>
    </div>
    <x-admin.api-pagination />
</section>
