<x-admin.layout title="Pengguna pelapor" :breadcrumbs="['Sistem' => route('admin.activity-logs.index')]">
    <x-admin.page-header title="Pengguna pelapor" description="Akun masyarakat yang mendaftar dari aplikasi Pelapor. Admin hanya bisa menonaktifkan atau mengaktifkan kembali." />

    <div x-data="reporterToggle()">
        <div x-data="apiList({ url: @js(route('api.v1.admin.users.index')), filters: { q: '', status: '' } })">
            <x-admin.api-filter-bar>
                <div>
                    <label for="q" class="form-label">Cari</label>
                    <input id="q" type="search" x-model="filters.q" placeholder="Nama, email, telepon" class="form-input">
                </div>
                <div>
                    <label for="status" class="form-label">Status akun</label>
                    <select id="status" x-model="filters.status" class="form-input">
                        <option value="">Semua</option>
                        <option value="aktif">Aktif</option>
                        <option value="nonaktif">Nonaktif</option>
                    </select>
                </div>
            </x-admin.api-filter-bar>

            <div class="card overflow-hidden">
                <x-admin.api-states icon="users" empty="Tidak ada pelapor yang cocok" />
                <div class="relative overflow-x-auto" x-show="rows.length > 0" :class="loading ? 'opacity-60' : ''">
                    <table class="data-table">
                        <thead><tr><th>Pelapor</th><th>Email</th><th>Status</th><th>Perangkat</th><th>Laporan dibuat</th><th>Login terakhir</th><th><span class="sr-only">Aksi</span></th></tr></thead>
                        <tbody>
                            <template x-for="row in rows" :key="row.id">
                                <tr class="hover:bg-stone-50">
                                    <td>
                                        <div class="flex items-center gap-3">
                                            <span class="grid size-8 shrink-0 place-items-center rounded-full bg-mr-50 text-xs font-bold text-mr-800 ring-1 ring-mr-300" aria-hidden="true" x-text="row.initials"></span>
                                            <div>
                                                <a :href="`/admin/users/${row.id}`" class="font-semibold whitespace-nowrap hover:text-mr-700" x-text="row.name"></a>
                                                <div class="text-xs text-stone-600" x-text="row.phone"></div>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="break-all" x-text="row.email"></td>
                                    <td><x-admin.status-chip status="row.account_status" /></td>
                                    <td class="whitespace-nowrap">
                                        <span class="tabular font-semibold" x-text="row.devices_count"></span>
                                        <div x-show="row.devices_last_seen_at" class="text-xs text-stone-600" x-text="`aktif ${window.timeAgo(row.devices_last_seen_at)}`"></div>
                                    </td>
                                    <td><a :href="`/admin/users/${row.id}`" class="tabular font-semibold hover:text-mr-700" x-text="row.reports_made_count"></a></td>
                                    <td class="text-xs whitespace-nowrap text-stone-700" x-text="row.last_login_at ? window.timeAgo(row.last_login_at) : 'Belum tercatat'"></td>
                                    <td>
                                        <div class="flex justify-end gap-1">
                                            <a :href="`/admin/users/${row.id}`" class="btn-ghost min-h-9 px-2.5 text-xs">Detail</a>
                                            <button type="button" class="btn-ghost min-h-9 px-2.5 text-xs" @click="openToggle(row)"
                                                    x-text="row.account_status.value === 'aktif' ? 'Nonaktifkan' : 'Aktifkan'"></button>
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

        @include('admin.users.partials.toggle-modal')
    </div>
</x-admin.layout>
