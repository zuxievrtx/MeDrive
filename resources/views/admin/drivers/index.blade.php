<x-admin.layout title="Driver" :breadcrumbs="['Manajemen Armada' => route('admin.drivers.index')]">
    <x-admin.page-header title="Driver" description="Driver hanya bisa didaftarkan oleh admin pusat. Akun yang dibuat di sini dipakai driver untuk masuk ke aplikasi Driver.">
        <x-slot:actions>
            <a href="{{ route('admin.drivers.create') }}" class="btn-primary"><i class="fa-solid fa-user-plus" aria-hidden="true"></i> Daftarkan driver</a>
        </x-slot:actions>
    </x-admin.page-header>

    <section class="mb-4 grid gap-4 lg:grid-cols-[minmax(0,2fr)_minmax(0,1fr)]" aria-label="Ringkasan driver">
        <div class="card p-4">
            <h2 class="text-sm font-semibold">Driver per klinik</h2>
            @if ($summary['per_clinic']->isEmpty())
                <p class="mt-2 text-sm text-stone-600">Belum ada driver terdaftar.</p>
            @else
                <ul class="mt-3 flex flex-wrap gap-2">
                    @foreach ($summary['per_clinic'] as $clinic)
                        <li>
                            <a href="{{ route('admin.drivers.index', ['clinic_id' => $clinic->id]) }}" class="inline-flex min-h-9 items-center gap-2 rounded-lg border border-stone-200 px-3 text-sm hover:border-mr-300 hover:bg-mr-50">
                                {{ $clinic->name }} <span class="tabular font-bold">{{ $clinic->driver_profiles_count }}</span>
                            </a>
                        </li>
                    @endforeach
                </ul>
            @endif
        </div>
        <div class="card p-4">
            <h2 class="text-sm font-semibold">Dokumen driver</h2>
            <dl class="mt-3 grid grid-cols-2 gap-3 text-sm">
                <div>
                    <dt class="text-stone-600">SIM</dt>
                    <dd class="mt-1 flex flex-wrap gap-1.5">
                        <x-admin.badge tone="red">{{ $summary['licenses_expired'] }} kedaluwarsa</x-admin.badge>
                        <x-admin.badge tone="amber">{{ $summary['licenses_expiring'] }} &le; {{ config('medrive.expiry_warning_days') }} hari</x-admin.badge>
                    </dd>
                </div>
                <div>
                    <dt class="text-stone-600">Sertifikat</dt>
                    <dd class="mt-1 flex flex-wrap gap-1.5">
                        <x-admin.badge tone="red">{{ $summary['certifications_expired'] }} kedaluwarsa</x-admin.badge>
                        <x-admin.badge tone="amber">{{ $summary['certifications_expiring'] }} &le; {{ config('medrive.expiry_warning_days') }} hari</x-admin.badge>
                    </dd>
                </div>
            </dl>
        </div>
    </section>

    <x-admin.filter-bar :action="route('admin.drivers.index')" :reset-url="route('admin.drivers.index')">
        <div>
            <label for="q" class="form-label">Cari</label>
            <input id="q" name="q" type="search" value="{{ $filters['q'] ?? '' }}" placeholder="Nama, email, telepon, no. pegawai" class="form-input">
        </div>
        <div>
            <label for="institution_id" class="form-label">Instansi</label>
            <select id="institution_id" name="institution_id" class="form-input">
                <option value="">Semua instansi</option>
                @foreach ($institutions as $institution)
                    <option value="{{ $institution->id }}" @selected(($filters['institution_id'] ?? null) == $institution->id)>{{ $institution->name }}</option>
                @endforeach
            </select>
        </div>
        <div>
            <label for="clinic_id" class="form-label">Klinik</label>
            <select id="clinic_id" name="clinic_id" class="form-input">
                <option value="">Semua klinik</option>
                @foreach ($clinics as $clinic)
                    <option value="{{ $clinic->id }}" @selected(($filters['clinic_id'] ?? null) == $clinic->id)>{{ $clinic->labelWithInstitution() }}</option>
                @endforeach
            </select>
        </div>
        <div>
            <label for="shift" class="form-label">Status shift</label>
            <select id="shift" name="shift" class="form-input">
                <option value="">Semua</option>
                <option value="aktif" @selected(($filters['shift'] ?? null) === 'aktif')>Shift aktif</option>
                <option value="tidak" @selected(($filters['shift'] ?? null) === 'tidak')>Tidak sedang shift</option>
            </select>
        </div>
        <div>
            <label for="status" class="form-label">Status akun</label>
            <select id="status" name="status" class="form-input">
                <option value="">Semua</option>
                <option value="aktif" @selected(($filters['status'] ?? null) === 'aktif')>Aktif</option>
                <option value="nonaktif" @selected(($filters['status'] ?? null) === 'nonaktif')>Nonaktif</option>
            </select>
        </div>
    </x-admin.filter-bar>

    <div class="card overflow-hidden" x-data="{ toggle: { open: false, url: '', name: '', active: true } }"
         @driver-toggle.window="toggle = { open: true, ...$event.detail }">
        @if ($drivers->isEmpty())
            <x-admin.empty-state icon="id-card" title="Tidak ada driver yang cocok" description="Ubah filter atau daftarkan driver baru.">
                <x-slot:action><a href="{{ route('admin.drivers.create') }}" class="btn-primary">Daftarkan driver</a></x-slot:action>
            </x-admin.empty-state>
        @else
            <div class="relative overflow-x-auto">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th><x-admin.sort-link column="name" label="Driver" :sort="$sort" :direction="$direction" /></th>
                            <th><x-admin.sort-link column="clinic" label="Klinik / Instansi" :sort="$sort" :direction="$direction" /></th>
                            <th><x-admin.sort-link column="employee_number" label="No. pegawai" :sort="$sort" :direction="$direction" /></th>
                            <th><x-admin.sort-link column="license_expires_at" label="SIM" :sort="$sort" :direction="$direction" /></th>
                            <th>Shift</th>
                            <th>Akun</th>
                            <th><x-admin.sort-link column="last_login_at" label="Login terakhir" :sort="$sort" :direction="$direction" /></th>
                            <th><span class="sr-only">Aksi</span></th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($drivers as $driver)
                            @php
                                $profile = $driver->driverProfile;
                                $expiresAt = $profile->license_expires_at;
                                $isExpired = $expiresAt->lt(today());
                                $isExpiring = ! $isExpired && $expiresAt->lte(today()->addDays(config('medrive.expiry_warning_days')));
                            @endphp
                            <tr class="hover:bg-stone-50">
                                <td>
                                    <div class="flex items-center gap-3">
                                        <x-admin.avatar :user="$driver" :photo-url="$profile->photo_path ? route('admin.drivers.photo', $driver) : null" />
                                        <div class="min-w-0">
                                            <a href="{{ route('admin.drivers.show', $driver) }}" class="font-semibold whitespace-nowrap hover:text-mr-700">{{ $driver->name }}</a>
                                            <div class="text-xs whitespace-nowrap text-stone-600">{{ $driver->phone }}</div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div class="whitespace-nowrap">{{ $profile->clinic->name }}</div>
                                    <div class="text-xs whitespace-nowrap text-stone-600">{{ $profile->clinic->institution->name }}</div>
                                </td>
                                <td class="tabular whitespace-nowrap">{{ $profile->employee_number ?? '-' }}</td>
                                <td>
                                    <div class="tabular whitespace-nowrap">{{ $profile->license_number }}</div>
                                    <div class="flex flex-wrap items-center gap-1.5 text-xs text-stone-600">
                                        <span>{{ $profile->license_class->label() }}</span>
                                        <span class="tabular whitespace-nowrap">s/d {{ $expiresAt->translatedFormat('j M Y') }}</span>
                                        @if ($isExpired)
                                            <x-admin.badge tone="red">Kedaluwarsa</x-admin.badge>
                                        @elseif ($isExpiring)
                                            <x-admin.badge tone="amber">Segera habis</x-admin.badge>
                                        @endif
                                    </div>
                                </td>
                                <td>
                                    <div class="flex flex-col items-start gap-1">
                                        @if ($driver->openShift)
                                            <x-admin.badge tone="green" icon="circle">Shift aktif</x-admin.badge>
                                            @if ($profile->is_on_duty)
                                                <x-admin.badge tone="brand">Bertugas</x-admin.badge>
                                            @endif
                                            <span class="text-xs whitespace-nowrap text-stone-600">{{ $driver->openShift->ambulance->plate_number }}</span>
                                        @else
                                            <span class="text-xs text-stone-600">Tidak shift</span>
                                        @endif
                                    </div>
                                </td>
                                <td><x-admin.badge :tone="$driver->account_status->tone()">{{ $driver->account_status->label() }}</x-admin.badge></td>
                                <td class="text-xs whitespace-nowrap text-stone-700">{{ $driver->last_login_at?->diffForHumans() ?? 'Belum pernah' }}</td>
                                <td>
                                    <div class="flex items-center justify-end gap-1" x-data="{ menu: false }" @keydown.escape="menu = false" @click.outside="menu = false">
                                        <a href="{{ route('admin.drivers.show', $driver) }}" class="btn-ghost min-h-9 px-2.5 text-xs">Lihat detail</a>
                                        <div class="relative">
                                            <button type="button" class="btn-ghost min-h-9 px-2.5" @click="menu = !menu" :aria-expanded="menu" aria-label="Aksi lain untuk {{ $driver->name }}">
                                                <i class="fa-solid fa-ellipsis-vertical"></i>
                                            </button>
                                            <div x-show="menu" x-cloak x-transition class="card absolute right-0 z-20 mt-1 w-48 p-1">
                                                <a href="{{ route('admin.drivers.edit', $driver) }}" class="flex min-h-9 items-center gap-2 rounded-md px-3 text-sm hover:bg-stone-100"><i class="fa-solid fa-pen w-4 text-stone-500" aria-hidden="true"></i> Edit</a>
                                                <button type="button" class="flex min-h-9 w-full items-center gap-2 rounded-md px-3 text-sm hover:bg-stone-100"
                                                        @click="menu = false; $dispatch('driver-toggle', { url: @js(route('admin.drivers.account-status', $driver)), name: @js($driver->name), active: @js($driver->isActive()), hasShift: @js((bool) $driver->openShift), shiftUrl: @js(route('admin.drivers.show', ['driver' => $driver, 'tab' => 'shift'])) })">
                                                    <i class="fa-solid {{ $driver->isActive() ? 'fa-user-slash' : 'fa-user-check' }} w-4 text-stone-500" aria-hidden="true"></i>
                                                    {{ $driver->isActive() ? 'Nonaktifkan akun' : 'Aktifkan akun' }}
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            <div class="border-t border-stone-100 px-4 py-3">{{ $drivers->links() }}</div>
        @endif

        @include('admin.drivers.partials.toggle-modal')
    </div>
</x-admin.layout>
