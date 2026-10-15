<x-admin.layout title="Detail pelapor" :breadcrumbs="['Pengguna pelapor' => route('admin.users.index')]">
    <div x-data="{ reporter: null, loading: true, error: null,
                   async load() {
                       try { this.reporter = await window.medrive.getData(@js(route('api.v1.admin.users.show', $reporterId)), {}, { silent: true }); this.error = null; }
                       catch (error) { this.error = error.message; }
                       finally { this.loading = false; }
                   } }"
         x-init="load()" @reporter-updated="reporter = { ...reporter, ...$event.detail }">
        <template x-if="loading">
            <div class="card mb-6 flex items-center gap-4 p-5" aria-busy="true"><div class="skeleton size-14 rounded-full"></div><div class="flex-1 space-y-2"><div class="skeleton h-6 w-48"></div><div class="skeleton h-4 w-72"></div></div></div>
        </template>
        <template x-if="!loading && error">
            <div class="card mb-6 flex flex-col items-center px-6 py-10 text-center" role="alert">
                <p class="text-sm font-semibold" x-text="error"></p>
                <button type="button" class="btn-secondary mt-4" @click="loading = true; load()">Muat ulang</button>
            </div>
        </template>

        <div x-data="reporterToggle()" x-show="reporter" x-cloak>
            <section class="card mb-6 flex flex-col gap-4 p-5 md:flex-row md:items-center">
                <span class="grid size-14 shrink-0 place-items-center rounded-full bg-mr-50 text-lg font-bold text-mr-800 ring-1 ring-mr-300" aria-hidden="true" x-text="reporter?.initials"></span>
                <div class="min-w-0 flex-1">
                    <div class="flex flex-wrap items-center gap-2">
                        <h1 class="text-2xl font-bold tracking-tight" x-text="reporter?.name"></h1>
                        <span class="inline-flex rounded-md px-2 py-0.5 text-xs font-semibold ring-1 ring-inset" :class="window.badgeTone(reporter?.account_status?.tone)" x-text="`Akun ${(reporter?.account_status?.label ?? '').toLowerCase()}`"></span>
                    </div>
                    <p class="mt-1 text-sm text-stone-600" x-text="`${reporter?.phone} · ${reporter?.email} · terdaftar ${window.formatDay(reporter?.created_at)}`"></p>
                </div>
                <button type="button" :class="reporter?.account_status?.value === 'aktif' ? 'btn-danger' : 'btn-primary'" @click="openToggle(reporter)"
                        x-text="reporter?.account_status?.value === 'aktif' ? 'Nonaktifkan akun' : 'Aktifkan akun'"></button>
            </section>
            @include('admin.users.partials.toggle-modal')
        </div>

        <div x-show="reporter" x-cloak class="grid gap-6 xl:grid-cols-[minmax(0,2fr)_minmax(0,1fr)]">
            <section class="card overflow-hidden" x-data="apiList({ url: @js(route('api.v1.admin.reports.index')), filters: { reporter_id: @js((string) $reporterId) }, syncUrl: false })">
                <h2 class="border-b border-stone-100 px-5 py-3 font-semibold">Riwayat laporan</h2>
                <x-admin.api-states icon="file-medical" empty="Belum pernah membuat laporan" :rows="3" />
                <div class="relative overflow-x-auto" x-show="rows.length > 0" :class="loading ? 'opacity-60' : ''">
                    <table class="data-table">
                        <thead><tr><th>Kode</th><th>Jenis</th><th>Status</th><th>Driver</th><th>Dibuat</th></tr></thead>
                        <tbody>
                            <template x-for="row in rows" :key="row.id">
                                <tr>
                                    <td><a :href="`/admin/reports/${row.id}`" class="tabular font-semibold whitespace-nowrap hover:text-mr-700" x-text="row.code"></a></td>
                                    <td><x-admin.type-chip /></td>
                                    <td><x-admin.status-chip /></td>
                                    <td class="whitespace-nowrap" x-text="row.driver?.name ?? '-'"></td>
                                    <td class="tabular whitespace-nowrap" x-text="window.formatDate(row.created_at)"></td>
                                </tr>
                            </template>
                        </tbody>
                    </table>
                </div>
                <x-admin.api-pagination />
            </section>

            <section class="card p-5">
                <h2 class="mb-3 font-semibold">Perangkat</h2>
                <p x-show="(reporter?.devices ?? []).length === 0" class="text-sm text-stone-600">Belum ada perangkat terdaftar.</p>
                <ul class="space-y-3">
                    <template x-for="device in reporter?.devices ?? []" :key="device.id">
                        <li class="rounded-lg border border-stone-200 p-3 text-sm">
                            <div class="font-medium" x-text="device.device_model ?? 'Perangkat tidak dikenal'"></div>
                            <div class="text-xs text-stone-600" x-text="`${(device.platform ?? '').charAt(0).toUpperCase()}${(device.platform ?? '').slice(1)} · aplikasi v${device.app_version ?? '-'}`"></div>
                            <div class="text-xs text-stone-600" x-text="`Terakhir aktif ${device.last_seen_at ? window.formatDate(device.last_seen_at) : '-'}`"></div>
                        </li>
                    </template>
                </ul>
            </section>
        </div>
    </div>
</x-admin.layout>
