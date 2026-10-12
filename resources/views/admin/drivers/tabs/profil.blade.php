<div class="grid gap-6 lg:grid-cols-2">
    <section class="card p-5">
        <h2 class="mb-4 font-semibold">Profil driver</h2>
        <dl class="grid grid-cols-[minmax(0,10rem)_minmax(0,1fr)] gap-x-4 gap-y-3 text-sm">
            <dt class="text-stone-600">Klinik</dt><dd>{{ $profile->clinic->name }}</dd>
            <dt class="text-stone-600">Instansi</dt><dd>{{ $profile->clinic->institution->name }}</dd>
            <dt class="text-stone-600">Nomor pegawai</dt><dd class="tabular">{{ $profile->employee_number ?? '-' }}</dd>
            <dt class="text-stone-600">Nomor SIM</dt><dd class="tabular">{{ $profile->license_number }}</dd>
            <dt class="text-stone-600">Golongan SIM</dt><dd>{{ $profile->license_class->label() }}</dd>
            <dt class="text-stone-600">SIM berlaku sampai</dt>
            <dd class="flex flex-wrap items-center gap-2">
                <span class="tabular">{{ $profile->license_expires_at->translatedFormat('j F Y') }}</span>
                @if ($profile->license_expires_at->lt(today()))
                    <x-admin.badge tone="red">Kedaluwarsa</x-admin.badge>
                @elseif ($profile->license_expires_at->lte(today()->addDays(config('medrive.expiry_warning_days'))))
                    <x-admin.badge tone="amber">Segera habis</x-admin.badge>
                @endif
            </dd>
            <dt class="text-stone-600">Sedang bertugas</dt><dd>{{ $profile->is_on_duty ? 'Ya, menangani laporan' : 'Tidak' }}</dd>
            <dt class="text-stone-600">Didaftarkan oleh</dt><dd>{{ $profile->creator?->name ?? '-' }}</dd>
            <dt class="text-stone-600">Terdaftar sejak</dt><dd>{{ $profile->created_at?->translatedFormat('j F Y H:i') }}</dd>
        </dl>
    </section>

    <section class="card p-5">
        <h2 class="mb-4 font-semibold">Akun</h2>
        <dl class="grid grid-cols-[minmax(0,10rem)_minmax(0,1fr)] gap-x-4 gap-y-3 text-sm">
            <dt class="text-stone-600">Email</dt><dd class="break-all">{{ $driver->email }}</dd>
            <dt class="text-stone-600">Telepon</dt><dd>{{ $driver->phone }}</dd>
            <dt class="text-stone-600">Status akun</dt><dd><x-admin.badge :tone="$driver->account_status->tone()">{{ $driver->account_status->label() }}</x-admin.badge></dd>
            <dt class="text-stone-600">Wajib ganti password</dt><dd>{{ $driver->must_change_password ? 'Ya, saat login berikutnya' : 'Tidak' }}</dd>
            <dt class="text-stone-600">Login terakhir</dt><dd>{{ $driver->last_login_at?->translatedFormat('j F Y H:i') ?? 'Belum pernah login' }}</dd>
        </dl>

        <h3 class="mt-6 mb-2 text-sm font-semibold">Perangkat terdaftar</h3>
        @if ($devices->isEmpty())
            <p class="text-sm text-stone-600">Belum ada perangkat. Perangkat tercatat saat driver login di aplikasi.</p>
        @else
            <ul class="divide-y divide-stone-100 rounded-lg border border-stone-200">
                @foreach ($devices as $device)
                    <li class="flex flex-wrap items-center justify-between gap-2 px-3 py-2 text-sm">
                        <span><i class="fa-solid {{ $device->platform === 'ios' ? 'fa-mobile-screen' : 'fa-mobile-screen-button' }} mr-1 text-stone-500" aria-hidden="true"></i>{{ $device->device_model ?? 'Perangkat tidak dikenal' }} <span class="text-stone-600">({{ $device->platform }}, v{{ $device->app_version ?? '-' }})</span></span>
                        <span class="text-xs text-stone-600">terakhir aktif {{ $device->last_seen_at?->diffForHumans() ?? '-' }}</span>
                    </li>
                @endforeach
            </ul>
        @endif
    </section>
</div>
