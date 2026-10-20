<x-admin.layout title="Driver" :breadcrumbs="['Manajemen Armada' => route('admin.drivers.index')]">
    <x-admin.page-header title="Driver" description="Driver hanya bisa didaftarkan oleh admin pusat. Akun yang dibuat di sini dipakai driver untuk masuk ke aplikasi Driver.">
        <x-slot:actions>
            <a href="{{ route('admin.drivers.create') }}" class="btn-primary"><i class="fa-solid fa-user-plus" aria-hidden="true"></i> Daftarkan driver</a>
        </x-slot:actions>
    </x-admin.page-header>

    <div x-data="adminOptions('clinics,institutions')">
        <div x-data="{ toggle: { open: false } }" @driver-toggle.window="toggle = { open: true, ...$event.detail }">
        <div x-data="apiList({ url: @js(route('api.v1.admin.drivers.index')), filters: { q: '', institution_id: '', clinic_id: '', shift: '', status: '', sort: 'name', direction: 'asc' } })">
            <section class="mb-4 grid gap-4 lg:grid-cols-[minmax(0,2fr)_minmax(0,1fr)]" aria-label="Ringkasan driver">
                <div class="card p-4">
                    <h2 class="text-sm font-semibold">Driver per klinik</h2>
                    <div x-show="!meta" class="skeleton mt-3 h-9 w-2/3"></div>
                    <p x-show="meta && meta.summary.per_clinic.length === 0" x-cloak class="mt-2 text-sm text-stone-600">Belum ada driver terdaftar.</p>
                    <ul class="mt-3 flex flex-wrap gap-2">
                        <template x-for="clinic in meta?.summary.per_clinic ?? []" :key="clinic.id">
                            <li>
                                <button type="button" @click="filters.clinic_id = String(clinic.id); apply()"
                                        class="inline-flex min-h-9 items-center gap-2 rounded-lg border border-stone-200 px-3 text-sm hover:border-mr-300 hover:bg-mr-50">
                                    <span x-text="clinic.name"></span> <span class="tabular font-bold" x-text="clinic.drivers"></span>
                                </button>
                            </li>
                        </template>
                    </ul>
                </div>
                <div class="card p-4">
                    <h2 class="text-sm font-semibold">Dokumen driver</h2>
                    <dl class="mt-3 grid grid-cols-2 gap-3 text-sm">
                        <div>
                            <dt class="text-stone-600">SIM</dt>
                            <dd class="mt-1 flex flex-wrap gap-1.5">
                                <x-admin.badge tone="red"><span x-text="meta?.summary.licenses_expired ?? '-'"></span> kedaluwarsa</x-admin.badge>
                                <x-admin.badge tone="amber"><span x-text="meta?.summary.licenses_expiring ?? '-'"></span> &le; {{ config('medrive.expiry_warning_days') }} hari</x-admin.badge>
                            </dd>
                        </div>
                        <div>
                            <dt class="text-stone-600">Sertifikat</dt>
                            <dd class="mt-1 flex flex-wrap gap-1.5">
                                <x-admin.badge tone="red"><span x-text="meta?.summary.certifications_expired ?? '-'"></span> kedaluwarsa</x-admin.badge>
                                <x-admin.badge tone="amber"><span x-text="meta?.summary.certifications_expiring ?? '-'"></span> &le; {{ config('medrive.expiry_warning_days') }} hari</x-admin.badge>
                            </dd>
                        </div>
                    </dl>
                </div>
            </section>

            <x-admin.api-filter-bar>
                <div>
                    <label for="q" class="form-label">Cari</label>
                    <input id="q" type="search" x-model="filters.q" placeholder="Nama, email, telepon, no. pegawai" class="form-input">
                </div>
                <div>
                    <label for="institution_id" class="form-label">Instansi</label>
                    <select id="institution_id" x-model="filters.institution_id" class="form-input">
                        <option value="">Semua instansi</option>
                        <template x-for="item in options.institutions ?? []" :key="item.id"><option :value="String(item.id)" x-text="item.name" :selected="String(item.id) === filters.institution_id"></option></template>
                    </select>
                </div>
                <div>
                    <label for="clinic_id" class="form-label">Klinik</label>
                    <select id="clinic_id" x-model="filters.clinic_id" class="form-input">
                        <option value="">Semua klinik</option>
                        <template x-for="item in options.clinics ?? []" :key="item.id"><option :value="String(item.id)" x-text="item.label" :selected="String(item.id) === filters.clinic_id"></option></template>
                    </select>
                </div>
                <div>
                    <label for="shift" class="form-label">Status shift</label>
                    <select id="shift" x-model="filters.shift" class="form-input">
                        <option value="">Semua</option>
                        <option value="aktif">Shift aktif</option>
                        <option value="tidak">Tidak sedang shift</option>
                    </select>
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
                <x-admin.api-states icon="id-card" empty="Tidak ada driver yang cocok" empty-description="Ubah filter atau daftarkan driver baru." />
                <div class="relative overflow-x-auto" x-show="rows.length > 0" :class="loading ? 'opacity-60' : ''">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th><x-admin.api-sort column="name" label="Driver" /></th>
                                <th><x-admin.api-sort column="clinic" label="Klinik / Instansi" /></th>
                                <th><x-admin.api-sort column="employee_number" label="No. pegawai" /></th>
                                <th><x-admin.api-sort column="license_expires_at" label="SIM" /></th>
                                <th>Shift</th>
                                <th>Akun</th>
                                <th><x-admin.api-sort column="last_login_at" label="Login terakhir" /></th>
                                <th><span class="sr-only">Aksi</span></th>
                            </tr>
                        </thead>
                        <tbody>
                            <template x-for="row in rows" :key="row.id">
                                <tr class="hover:bg-stone-50">
                                    <td>
                                        <div class="flex items-center gap-3">
                                            <template x-if="row.driver_profile.photo_url"><img :src="row.driver_profile.photo_url" :alt="`Foto ${row.name}`" loading="lazy" class="size-10 shrink-0 rounded-full object-cover ring-1 ring-stone-200"></template>
                                            <template x-if="!row.driver_profile.photo_url"><span class="grid size-10 shrink-0 place-items-center rounded-full bg-mr-50 text-sm font-bold text-mr-800 ring-1 ring-mr-300" aria-hidden="true" x-text="row.initials"></span></template>
                                            <div class="min-w-0">
                                                <a :href="`/admin/drivers/${row.id}`" class="font-semibold whitespace-nowrap hover:text-mr-700" x-text="row.name"></a>
                                                <div class="text-xs whitespace-nowrap text-stone-600" x-text="row.phone"></div>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="whitespace-nowrap" x-text="row.driver_profile.clinic?.name"></div>
                                        <div class="text-xs whitespace-nowrap text-stone-600" x-text="row.driver_profile.clinic?.institution?.name"></div>
                                    </td>
                                    <td class="tabular whitespace-nowrap" x-text="row.driver_profile.employee_number ?? '-'"></td>
                                    <td>
                                        <div class="tabular whitespace-nowrap" x-text="row.driver_profile.license_number"></div>
                                        <div class="flex flex-wrap items-center gap-1.5 text-xs text-stone-600">
                                            <span x-text="row.driver_profile.license_class?.label"></span>
                                            <span class="tabular whitespace-nowrap" x-text="`s/d ${window.formatDay(row.driver_profile.license_expires_at)}`"></span>
                                            <span x-show="row.driver_profile.license_expiry_state === 'expired'" class="inline-flex rounded-md px-2 py-0.5 text-xs font-semibold ring-1 ring-inset" :class="window.badgeTone('red')">Kedaluwarsa</span>
                                            <span x-show="row.driver_profile.license_expiry_state === 'expiring'" class="inline-flex rounded-md px-2 py-0.5 text-xs font-semibold ring-1 ring-inset" :class="window.badgeTone('amber')">Segera habis</span>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="flex flex-col items-start gap-1">
                                            <template x-if="row.open_shift">
                                                <div class="flex flex-col items-start gap-1">
                                                    <x-admin.badge tone="green" icon="circle">Shift aktif</x-admin.badge>
                                                    <span x-show="row.driver_profile.is_on_duty"><x-admin.badge tone="brand">Bertugas</x-admin.badge></span>
                                                    <span class="text-xs whitespace-nowrap text-stone-600" x-text="row.open_shift.ambulance?.plate_number"></span>
                                                </div>
                                            </template>
                                            <span x-show="!row.open_shift" class="text-xs text-stone-600">Tidak shift</span>
                                        </div>
                                    </td>
                                    <td><x-admin.status-chip status="row.account_status" /></td>
                                    <td class="text-xs whitespace-nowrap text-stone-700" x-text="row.last_login_at ? window.timeAgo(row.last_login_at) : 'Belum pernah'"></td>
                                    <td>
                                        <div class="flex items-center justify-end gap-1" x-data="{ menu: false }" @keydown.escape="menu = false" @click.outside="menu = false">
                                            <a :href="`/admin/drivers/${row.id}`" class="btn-ghost min-h-9 px-2.5 text-xs">Lihat detail</a>
                                            <div class="relative">
                                                <button type="button" class="btn-ghost min-h-9 px-2.5" @click="menu = !menu" :aria-expanded="menu" :aria-label="`Aksi lain untuk ${row.name}`">
                                                    <i class="fa-solid fa-ellipsis-vertical"></i>
                                                </button>
                                                <div x-show="menu" x-cloak x-transition class="card absolute right-0 z-20 mt-1 w-48 p-1">
                                                    <a :href="`/admin/drivers/${row.id}/edit`" class="flex min-h-9 items-center gap-2 rounded-md px-3 text-sm hover:bg-stone-100"><i class="fa-solid fa-pen w-4 text-stone-500" aria-hidden="true"></i> Edit</a>
                                                    <button type="button" class="flex min-h-9 w-full items-center gap-2 rounded-md px-3 text-sm hover:bg-stone-100"
                                                            @click="menu = false; $dispatch('driver-toggle', { id: row.id, name: row.name, active: row.account_status.value === 'aktif', hasShift: Boolean(row.open_shift) })">
                                                        <i class="fa-solid w-4 text-stone-500" :class="row.account_status.value === 'aktif' ? 'fa-user-slash' : 'fa-user-check'" aria-hidden="true"></i>
                                                        <span x-text="row.account_status.value === 'aktif' ? 'Nonaktifkan akun' : 'Aktifkan akun'"></span>
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            </template>
                        </tbody>
                    </table>
                </div>
                <x-admin.api-pagination />
            </div>

            @include('admin.drivers.partials.toggle-modal')
        </div>
        </div>
    </div>
</x-admin.layout>
