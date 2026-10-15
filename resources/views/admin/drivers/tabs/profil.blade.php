<div class="grid gap-6 lg:grid-cols-2">
    <section class="card p-5">
        <h2 class="mb-4 font-semibold">Profil driver</h2>
        <dl class="grid grid-cols-[minmax(0,10rem)_minmax(0,1fr)] gap-x-4 gap-y-3 text-sm">
            <dt class="text-stone-600">Klinik</dt><dd x-text="profile.clinic?.name"></dd>
            <dt class="text-stone-600">Instansi</dt><dd x-text="profile.clinic?.institution?.name"></dd>
            <dt class="text-stone-600">Nomor pegawai</dt><dd class="tabular" x-text="profile.employee_number ?? '-'"></dd>
            <dt class="text-stone-600">Nomor SIM</dt><dd class="tabular" x-text="profile.license_number"></dd>
            <dt class="text-stone-600">Golongan SIM</dt><dd x-text="profile.license_class?.label"></dd>
            <dt class="text-stone-600">SIM berlaku sampai</dt>
            <dd class="flex flex-wrap items-center gap-2">
                <span class="tabular" x-text="window.formatDay(profile.license_expires_at)"></span>
                <span x-show="profile.license_expiry_state === 'expired'" class="inline-flex rounded-md px-2 py-0.5 text-xs font-semibold ring-1 ring-inset" :class="window.badgeTone('red')">Kedaluwarsa</span>
                <span x-show="profile.license_expiry_state === 'expiring'" class="inline-flex rounded-md px-2 py-0.5 text-xs font-semibold ring-1 ring-inset" :class="window.badgeTone('amber')">Segera habis</span>
            </dd>
            <dt class="text-stone-600">Sedang bertugas</dt><dd x-text="profile.is_on_duty ? 'Ya, menangani laporan' : 'Tidak'"></dd>
            <dt class="text-stone-600">Didaftarkan oleh</dt><dd x-text="profile.created_by?.name ?? '-'"></dd>
            <dt class="text-stone-600">Terdaftar sejak</dt><dd x-text="window.formatDate(profile.created_at)"></dd>
        </dl>
    </section>

    <section class="card p-5">
        <h2 class="mb-4 font-semibold">Akun</h2>
        <dl class="grid grid-cols-[minmax(0,10rem)_minmax(0,1fr)] gap-x-4 gap-y-3 text-sm">
            <dt class="text-stone-600">Email</dt><dd class="break-all" x-text="driver.email"></dd>
            <dt class="text-stone-600">Telepon</dt><dd x-text="driver.phone"></dd>
            <dt class="text-stone-600">Status akun</dt><dd><x-admin.status-chip status="driver.account_status" /></dd>
            <dt class="text-stone-600">Wajib ganti password</dt><dd x-text="driver.must_change_password ? 'Ya, saat login berikutnya' : 'Tidak'"></dd>
            <dt class="text-stone-600">Login terakhir</dt><dd x-text="driver.last_login_at ? window.formatDate(driver.last_login_at) : 'Belum pernah login'"></dd>
        </dl>

        <h3 class="mt-6 mb-2 text-sm font-semibold">Perangkat terdaftar</h3>
        <p x-show="(driver.devices ?? []).length === 0" class="text-sm text-stone-600">Belum ada perangkat. Perangkat tercatat saat driver login dan mendaftarkan FCM di aplikasi.</p>
        <ul x-show="(driver.devices ?? []).length > 0" class="divide-y divide-stone-100 rounded-lg border border-stone-200">
            <template x-for="device in driver.devices ?? []" :key="device.id">
                <li class="flex flex-wrap items-center justify-between gap-2 px-3 py-2 text-sm">
                    <span><i class="fa-solid fa-mobile-screen-button mr-1 text-stone-500" aria-hidden="true"></i><span x-text="device.device_model ?? 'Perangkat tidak dikenal'"></span> <span class="text-stone-600" x-text="`(${device.platform}, v${device.app_version ?? '-'})`"></span></span>
                    <span class="text-xs text-stone-600" x-text="`terakhir aktif ${device.last_seen_at ? window.timeAgo(device.last_seen_at) : '-'}`"></span>
                </li>
            </template>
        </ul>
    </section>
</div>
