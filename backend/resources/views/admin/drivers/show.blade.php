@php
    $tabs = ['profil' => 'Profil', 'sertifikat' => 'Sertifikat', 'shift' => 'Shift', 'laporan' => 'Laporan', 'lokasi' => 'Lokasi'];
    $initialTab = array_key_exists(request('tab'), $tabs) ? request('tab') : 'profil';
@endphp
<x-admin.layout title="Detail driver" :breadcrumbs="['Driver' => route('admin.drivers.index')]">
    <div x-data="driverDetail({ url: @js(route('api.v1.admin.drivers.show', $driverId)), driverId: {{ $driverId }}, tab: @js($initialTab) })">
        <template x-if="credentials">
            <section class="card mb-6 border-mr-300 p-5" aria-labelledby="credentials-title">
                <div class="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
                    <div>
                        <h2 id="credentials-title" class="font-bold text-mr-800"><i class="fa-solid fa-key mr-1" aria-hidden="true"></i> Kredensial akun driver</h2>
                        <p class="mt-1 text-sm text-stone-700">Serahkan ke driver sekarang. Password ini <strong>hanya ditampilkan sekali</strong> dan hilang saat halaman dimuat ulang.</p>
                    </div>
                    <button type="button" class="btn-primary" @click="copyCredentials()">
                        <i class="fa-solid" :class="copied ? 'fa-check' : 'fa-copy'" aria-hidden="true"></i>
                        <span x-text="copied ? 'Tersalin' : 'Salin kredensial'"></span>
                    </button>
                </div>
                <dl class="mt-4 grid gap-3 rounded-lg bg-stone-50 p-4 text-sm sm:grid-cols-2">
                    <div><dt class="text-stone-600">Email</dt><dd class="font-semibold break-all" x-text="credentials.email"></dd></div>
                    <div><dt class="text-stone-600">Password sementara</dt><dd class="tabular font-semibold break-all" x-text="credentials.password"></dd></div>
                </dl>
            </section>
        </template>

        <template x-if="loading"><div class="card mb-6"><x-admin.skeleton-rows :rows="4" /></div></template>
        <div x-show="error" x-cloak class="mb-6 flex items-center gap-3 rounded-lg border border-mr-300 bg-mr-50 p-4 text-sm text-mr-800" role="alert">
            <span x-text="error"></span><button type="button" class="font-semibold underline" @click="load()">Coba lagi</button>
        </div>

        <template x-if="driver">
            <div>
                <section class="card mb-6 p-5">
                    <div class="flex flex-col gap-5 md:flex-row md:items-center">
                        <template x-if="profile.photo_url"><img :src="profile.photo_url" :alt="`Foto ${driver.name}`" class="size-24 shrink-0 rounded-full object-cover ring-1 ring-stone-200"></template>
                        <template x-if="!profile.photo_url"><span class="grid size-24 shrink-0 place-items-center rounded-full bg-mr-50 text-2xl font-bold text-mr-800 ring-1 ring-mr-300" aria-hidden="true" x-text="driver.initials"></span></template>
                        <div class="min-w-0 flex-1">
                            <div class="flex flex-wrap items-center gap-2">
                                <h1 class="text-2xl font-bold tracking-tight" x-text="driver.name"></h1>
                                <span class="inline-flex rounded-md px-2 py-0.5 text-xs font-semibold ring-1 ring-inset" :class="window.badgeTone(driver.account_status.tone)" x-text="`Akun ${driver.account_status.label.toLowerCase()}`"></span>
                                <template x-if="driver.open_shift"><x-admin.badge tone="green" icon="circle">Shift aktif</x-admin.badge></template>
                                <template x-if="driver.open_shift && profile.is_on_duty"><x-admin.badge tone="brand">Bertugas</x-admin.badge></template>
                            </div>
                            <p class="mt-1 text-sm text-stone-700"><span x-text="profile.clinic?.name"></span> <span class="text-stone-500">/</span> <span x-text="profile.clinic?.institution?.name"></span></p>
                            <p class="mt-1 flex flex-wrap gap-x-4 gap-y-1 text-sm text-stone-600">
                                <a :href="`tel:${driver.phone}`" class="hover:text-mr-700"><i class="fa-solid fa-phone mr-1" aria-hidden="true"></i><span x-text="driver.phone"></span></a>
                                <a :href="`mailto:${driver.email}`" class="hover:text-mr-700"><i class="fa-solid fa-envelope mr-1" aria-hidden="true"></i><span x-text="driver.email"></span></a>
                            </p>
                        </div>
                        <div class="flex flex-wrap gap-2">
                            <a href="{{ route('admin.drivers.edit', $driverId) }}" class="btn-secondary"><i class="fa-solid fa-pen" aria-hidden="true"></i> Edit</a>
                            <button type="button" class="btn-secondary" @click="reset.open = true"><i class="fa-solid fa-key" aria-hidden="true"></i> Reset password</button>
                            <button type="button" :class="driver.account_status.value === 'aktif' ? 'btn-danger' : 'btn-primary'" @click="toggle.open = true"
                                    x-text="driver.account_status.value === 'aktif' ? 'Nonaktifkan' : 'Aktifkan'"></button>
                        </div>
                    </div>
                </section>

                <nav class="mb-4 overflow-x-auto border-b border-stone-200" aria-label="Tab detail driver">
                    <ul class="flex min-w-max gap-1" role="tablist">
                        @foreach ($tabs as $key => $label)
                            <li>
                                <button type="button" role="tab" @click="tab = '{{ $key }}'" :aria-selected="tab === '{{ $key }}'"
                                        class="inline-flex min-h-11 items-center border-b-2 px-4 text-sm font-semibold"
                                        :class="tab === '{{ $key }}' ? 'border-mr-600 text-mr-700' : 'border-transparent text-stone-600 hover:text-stone-900'">{{ $label }}</button>
                            </li>
                        @endforeach
                    </ul>
                </nav>

                <div x-show="tab === 'profil'">@include('admin.drivers.tabs.profil')</div>
                <div x-show="tab === 'sertifikat'" x-cloak>@include('admin.drivers.tabs.sertifikat')</div>
                <template x-if="tab === 'shift'">@include('admin.drivers.tabs.shift')</template>
                <template x-if="tab === 'laporan'">@include('admin.drivers.tabs.laporan')</template>
                <template x-if="tab === 'lokasi'">@include('admin.drivers.tabs.lokasi')</template>
            </div>
        </template>

        {{-- Modal aksi --}}
        <x-admin.modal show="toggle.open" title="Ubah status akun">
            <template x-if="driver && driver.account_status.value === 'aktif' && driver.open_shift">
                <div class="mb-4 flex gap-3 rounded-lg border border-amber-300 bg-amber-50 p-3 text-sm text-amber-900">
                    <i class="fa-solid fa-triangle-exclamation mt-0.5" aria-hidden="true"></i>
                    <p>Driver masih memiliki shift terbuka. Akhiri shift di tab Shift terlebih dahulu, baru akun bisa dinonaktifkan.</p>
                </div>
            </template>
            <p class="text-sm text-stone-700" x-show="driver?.account_status.value === 'aktif'">Akun akan dinonaktifkan. Driver tidak bisa login, token aplikasinya dicabut, dan tidak menerima broadcast laporan.</p>
            <p class="text-sm text-stone-700" x-show="driver?.account_status.value !== 'aktif'">Akun akan diaktifkan kembali.</p>
            <div class="mt-6 flex justify-end gap-2">
                <button type="button" class="btn-secondary" @click="toggle.open = false">Batal</button>
                <button type="button" x-show="driver?.account_status.value === 'aktif' && driver?.open_shift" class="btn-primary" @click="toggle.open = false; tab = 'shift'">Buka tab Shift</button>
                <button type="button" x-show="!(driver?.account_status.value === 'aktif' && driver?.open_shift)" :class="driver?.account_status.value === 'aktif' ? 'btn-danger' : 'btn-primary'"
                        @click="toggleStatus()" x-text="driver?.account_status.value === 'aktif' ? 'Nonaktifkan akun' : 'Aktifkan akun'"></button>
            </div>
        </x-admin.modal>

        <x-admin.modal show="reset.open" title="Reset password driver">
            <p class="text-sm text-stone-700">Password baru dibuat acak dan ditampilkan sekali. Driver wajib menggantinya saat login berikutnya, dan semua sesi aplikasi driver ini dikeluarkan.</p>
            <div class="mt-6 flex justify-end gap-2">
                <button type="button" class="btn-secondary" @click="reset.open = false">Batal</button>
                <button type="button" class="btn-danger" :disabled="reset.submitting" @click="resetPassword()">Reset password</button>
            </div>
        </x-admin.modal>

        <x-admin.modal show="endShift.open" title="Akhiri shift driver">
            <p class="text-sm text-stone-700">Shift akan ditutup dengan alasan <strong>dihentikan admin</strong>. Driver tidak lagi menerima broadcast laporan sampai membuka shift baru.</p>
            <template x-if="profile.is_on_duty">
                <div class="mt-3 flex gap-2 rounded-lg border border-amber-300 bg-amber-50 p-3 text-sm text-amber-900">
                    <i class="fa-solid fa-triangle-exclamation mt-0.5" aria-hidden="true"></i>
                    <p>Driver sedang menangani laporan. Status laporan tidak diubah oleh aksi ini.</p>
                </div>
            </template>
            <div class="mt-6 flex justify-end gap-2">
                <button type="button" class="btn-secondary" @click="endShift.open = false">Batal</button>
                <button type="button" class="btn-danger" @click="confirmEndShift()">Akhiri shift</button>
            </div>
        </x-admin.modal>

        <x-admin.modal show="cert.open" title="Sertifikat driver">
            <form @submit.prevent="saveCert($event)" class="space-y-4" novalidate>
                @foreach ([
                    ['name', 'Nama sertifikat', 'text', true],
                    ['certificate_number', 'Nomor', 'text', false],
                    ['issuer', 'Penerbit', 'text', false],
                    ['issued_at', 'Tanggal terbit', 'date', true],
                    ['expires_at', 'Kedaluwarsa', 'date', false],
                ] as [$field, $label, $type, $required])
                    <div>
                        <label for="cert-{{ $field }}" class="form-label">{{ $label }} @if ($required)<span class="text-mr-700" aria-hidden="true">*</span>@endif</label>
                        <input id="cert-{{ $field }}" name="{{ $field }}" type="{{ $type }}" x-model="cert.data.{{ $field }}" @if ($required) required @endif
                               @if ($field === 'issued_at') max="{{ today()->toDateString() }}" @endif class="form-input">
                        <p class="form-error" x-show="cert.errors.{{ $field }}" x-text="cert.errors.{{ $field }}?.[0]"></p>
                    </div>
                @endforeach
                <div>
                    <label for="cert-file" class="form-label">Berkas <span x-show="cert.mode === 'edit'">pengganti </span>(PDF/JPG/PNG, maks 5 MB)</label>
                    <input id="cert-file" name="file" type="file" accept=".pdf,image/jpeg,image/png" class="block w-full text-sm file:mr-3 file:min-h-10 file:rounded-lg file:border-0 file:bg-stone-100 file:px-4 file:text-sm file:font-semibold">
                    <p class="form-error" x-show="cert.errors.file" x-text="cert.errors.file?.[0]"></p>
                </div>
                <div class="flex justify-end gap-2">
                    <button type="button" class="btn-secondary" @click="cert.open = false">Batal</button>
                    <button type="submit" class="btn-primary" :disabled="cert.submitting" x-text="cert.mode === 'edit' ? 'Simpan perubahan' : 'Simpan sertifikat'"></button>
                </div>
            </form>
        </x-admin.modal>

        <x-admin.modal show="removeCert.open" title="Hapus sertifikat">
            <p class="text-sm text-stone-700">Sertifikat <strong x-text="removeCert.item?.name"></strong> beserta berkasnya akan dihapus permanen.</p>
            <div class="mt-6 flex justify-end gap-2">
                <button type="button" class="btn-secondary" @click="removeCert.open = false">Batal</button>
                <button type="button" class="btn-danger" @click="deleteCert()">Hapus sertifikat</button>
            </div>
        </x-admin.modal>
    </div>
</x-admin.layout>
