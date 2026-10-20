@php
    $moduleLabels = ['driver' => 'Driver', 'certification' => 'Sertifikat', 'shift' => 'Shift', 'ambulance' => 'Ambulans', 'ambulance_type' => 'Jenis ambulans',
        'institution' => 'Instansi', 'clinic' => 'Klinik', 'report' => 'Laporan', 'report_type' => 'Jenis laporan', 'reporter' => 'Pelapor', 'admin' => 'Admin'];
    $verbTones = ['created' => 'green', 'updated' => 'blue', 'status_changed' => 'violet', 'deleted' => 'red', 'deactivated' => 'gray', 'activated' => 'teal', 'cancelled' => 'amber', 'ended' => 'amber', 'password_reset' => 'amber'];
@endphp
<x-admin.layout title="Log aktivitas admin" :breadcrumbs="['Sistem' => route('admin.activity-logs.index')]">
    <x-admin.page-header title="Log aktivitas admin" description="Jejak semua aksi tulis di dashboard admin. Hanya bisa dibaca, tidak bisa diubah atau dihapus." />

    <div x-data="{ moduleLabels: @js($moduleLabels), verbTones: @js($verbTones) }">
    <div x-data="adminOptions('admins,activity_modules')">
        <div x-data="apiList({ url: @js(route('api.v1.admin.activity-logs')), filters: { admin_id: '', module: '', from: '', to: '' } })">
            <x-admin.api-filter-bar>
                <div>
                    <label for="admin_id" class="form-label">Admin</label>
                    <select id="admin_id" x-model="filters.admin_id" class="form-input">
                        <option value="">Semua admin</option>
                        <template x-for="item in options.admins ?? []" :key="item.id"><option :value="String(item.id)" x-text="item.name" :selected="String(item.id) === filters.admin_id"></option></template>
                    </select>
                </div>
                <div>
                    <label for="module" class="form-label">Kategori aksi</label>
                    <select id="module" x-model="filters.module" class="form-input">
                        <option value="">Semua kategori</option>
                        <template x-for="item in options.activity_modules ?? []" :key="item"><option :value="item" x-text="moduleLabels[item] ?? item" :selected="item === filters.module"></option></template>
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
            </x-admin.api-filter-bar>

            <div class="card overflow-hidden">
                <x-admin.api-states icon="clock-rotate-left" empty="Belum ada aktivitas yang cocok" />
                <div class="relative overflow-x-auto" x-show="rows.length > 0" :class="loading ? 'opacity-60' : ''">
                    <table class="data-table">
                        <thead><tr><th>Waktu</th><th>Admin</th><th>Aksi</th><th>Objek</th><th>Deskripsi</th><th>IP</th></tr></thead>
                        <tbody>
                            <template x-for="log in rows" :key="log.id">
                                <tr>
                                    <td class="tabular whitespace-nowrap" :title="window.timeAgo(log.created_at)" x-text="window.formatDate(log.created_at, { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit' })"></td>
                                    <td class="whitespace-nowrap" x-text="log.admin?.name ?? 'Admin terhapus'"></td>
                                    <td><span class="inline-flex rounded-md px-2 py-0.5 text-xs font-semibold whitespace-nowrap ring-1 ring-inset" :class="window.badgeTone(verbTones[log.verb] ?? 'gray')" x-text="log.action"></span></td>
                                    <td class="tabular text-xs whitespace-nowrap text-stone-700" x-text="`${log.subject_type}#${log.subject_id}`"></td>
                                    <td class="min-w-64" x-text="log.description"></td>
                                    <td class="tabular text-xs whitespace-nowrap text-stone-600" x-text="log.ip_address ?? '-'"></td>
                                </tr>
                            </template>
                        </tbody>
                    </table>
                </div>
                <x-admin.api-pagination />
            </div>
        </div>
    </div>
    </div>
</x-admin.layout>
