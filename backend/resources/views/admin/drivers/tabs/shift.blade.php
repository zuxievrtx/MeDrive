<section class="card overflow-hidden" x-data="apiList({ url: @js(route('api.v1.admin.drivers.shifts', $driverId)), syncUrl: false })">
    <div class="flex flex-wrap items-center justify-between gap-3 border-b border-stone-100 px-5 py-3">
        <h2 class="font-semibold">Riwayat shift</h2>
        <button type="button" x-show="driver.open_shift" class="btn-danger" @click="endShift.open = true">
            <i class="fa-solid fa-power-off" aria-hidden="true"></i> Akhiri Shift (Admin)
        </button>
    </div>
    <x-admin.api-states icon="clock" empty="Belum pernah membuka shift" empty-description="Shift dibuka driver dari aplikasi dengan memilih ambulans kliniknya." />
    <div class="relative overflow-x-auto" x-show="rows.length > 0">
        <table class="data-table">
            <thead><tr><th>Mulai</th><th>Selesai</th><th>Alasan selesai</th><th>Ambulans</th><th>Jenis</th></tr></thead>
            <tbody>
                <template x-for="row in rows" :key="row.id">
                    <tr :class="row.is_open ? 'bg-green-50/60' : ''">
                        <td class="tabular whitespace-nowrap" x-text="window.formatDate(row.started_at)"></td>
                        <td class="whitespace-nowrap">
                            <span x-show="row.is_open"><x-admin.badge tone="green" icon="circle">Masih terbuka</x-admin.badge></span>
                            <span x-show="!row.is_open" class="tabular" x-text="window.formatDate(row.ended_at)"></span>
                        </td>
                        <td x-text="row.end_reason?.label ?? '-'"></td>
                        <td class="tabular font-medium whitespace-nowrap" x-text="row.ambulance?.plate_number"></td>
                        <td class="whitespace-nowrap" x-text="row.ambulance?.ambulance_type?.name"></td>
                    </tr>
                </template>
            </tbody>
        </table>
    </div>
    <x-admin.api-pagination />
</section>
