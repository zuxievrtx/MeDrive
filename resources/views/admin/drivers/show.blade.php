@php
    $tabs = ['profil' => 'Profil', 'sertifikat' => 'Sertifikat', 'shift' => 'Shift', 'laporan' => 'Laporan', 'lokasi' => 'Lokasi'];
    $photoUrl = $profile->photo_path ? route('admin.drivers.photo', $driver) : null;
@endphp
<x-admin.layout :title="$driver->name" :breadcrumbs="['Driver' => route('admin.drivers.index')]">
    @if ($credentials)
        <section class="card mb-6 border-mr-300 p-5" x-data="copyText" aria-labelledby="credentials-title">
            <div class="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
                <div>
                    <h2 id="credentials-title" class="font-bold text-mr-800"><i class="fa-solid fa-key mr-1" aria-hidden="true"></i> Kredensial akun driver</h2>
                    <p class="mt-1 text-sm text-stone-700">Serahkan ke driver sekarang. Password ini <strong>hanya ditampilkan sekali</strong> dan tidak bisa dilihat lagi setelah halaman dimuat ulang.</p>
                </div>
                <button type="button" class="btn-primary" @click="copy(@js("Email: {$credentials['email']}\nPassword: {$credentials['password']}"))">
                    <i class="fa-solid" :class="copied ? 'fa-check' : 'fa-copy'" aria-hidden="true"></i>
                    <span x-text="copied ? 'Tersalin' : 'Salin kredensial'"></span>
                </button>
            </div>
            <dl class="mt-4 grid gap-3 rounded-lg bg-stone-50 p-4 text-sm sm:grid-cols-2">
                <div><dt class="text-stone-600">Email</dt><dd class="font-semibold break-all">{{ $credentials['email'] }}</dd></div>
                <div><dt class="text-stone-600">Password sementara</dt><dd class="tabular font-semibold break-all">{{ $credentials['password'] }}</dd></div>
            </dl>
        </section>
    @endif

    <div x-data="{ toggle: { open: false, url: '', name: '', active: true, hasShift: false, shiftUrl: '' } }" @driver-toggle.window="toggle = { open: true, ...$event.detail }">
        <section class="card mb-6 p-5">
            <div class="flex flex-col gap-5 md:flex-row md:items-center">
                <x-admin.avatar :user="$driver" size="xl" :photo-url="$photoUrl" />
                <div class="min-w-0 flex-1">
                    <div class="flex flex-wrap items-center gap-2">
                        <h1 class="text-2xl font-bold tracking-tight">{{ $driver->name }}</h1>
                        <x-admin.badge :tone="$driver->account_status->tone()">Akun {{ mb_strtolower($driver->account_status->label()) }}</x-admin.badge>
                        @if ($driver->openShift)
                            <x-admin.badge tone="green" icon="circle">Shift aktif</x-admin.badge>
                            @if ($profile->is_on_duty)<x-admin.badge tone="brand">Bertugas</x-admin.badge>@endif
                        @endif
                    </div>
                    <p class="mt-1 text-sm text-stone-700">{{ $profile->clinic->name }} <span class="text-stone-500">/</span> {{ $profile->clinic->institution->name }}</p>
                    <p class="mt-1 flex flex-wrap gap-x-4 gap-y-1 text-sm text-stone-600">
                        <a href="tel:{{ $driver->phone }}" class="hover:text-mr-700"><i class="fa-solid fa-phone mr-1" aria-hidden="true"></i>{{ $driver->phone }}</a>
                        <a href="mailto:{{ $driver->email }}" class="hover:text-mr-700"><i class="fa-solid fa-envelope mr-1" aria-hidden="true"></i>{{ $driver->email }}</a>
                    </p>
                </div>
                <div class="flex flex-wrap gap-2">
                    <a href="{{ route('admin.drivers.edit', $driver) }}" class="btn-secondary"><i class="fa-solid fa-pen" aria-hidden="true"></i> Edit</a>
                    <button type="button" class="{{ $driver->isActive() ? 'btn-danger' : 'btn-primary' }}"
                            @click="$dispatch('driver-toggle', { url: @js(route('admin.drivers.account-status', $driver)), name: @js($driver->name), active: @js($driver->isActive()), hasShift: @js((bool) $driver->openShift), shiftUrl: @js(route('admin.drivers.show', ['driver' => $driver, 'tab' => 'shift'])) })">
                        {{ $driver->isActive() ? 'Nonaktifkan' : 'Aktifkan' }}
                    </button>
                </div>
            </div>
        </section>

        @include('admin.drivers.partials.toggle-modal')
    </div>

    <nav class="mb-4 overflow-x-auto border-b border-stone-200" aria-label="Tab detail driver">
        <ul class="flex min-w-max gap-1">
            @foreach ($tabs as $key => $label)
                <li>
                    <a href="{{ route('admin.drivers.show', ['driver' => $driver, 'tab' => $key]) }}"
                       @class([
                           'inline-flex min-h-11 items-center border-b-2 px-4 text-sm font-semibold',
                           'border-mr-600 text-mr-700' => $tab === $key,
                           'border-transparent text-stone-600 hover:text-stone-900' => $tab !== $key,
                       ])
                       @if ($tab === $key) aria-current="page" @endif>{{ $label }}</a>
                </li>
            @endforeach
        </ul>
    </nav>

    @include('admin.drivers.tabs.'.$tab)
</x-admin.layout>
