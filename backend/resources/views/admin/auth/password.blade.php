@if ($isForced)
    <x-admin.auth-layout title="Ganti password">
        <h1 class="text-2xl font-bold tracking-tight">Ganti password terlebih dahulu</h1>
        <p class="mt-1 mb-6 text-sm text-stone-600">Akun ini ditandai wajib ganti password. Halaman lain baru bisa dibuka
            setelah password diganti.</p>
        @include('admin.auth.password-form')
        <form method="POST" action="{{ route('admin.logout') }}" class="mt-4">
            @csrf
            <button type="submit" class="btn-ghost px-0 text-sm text-stone-700">Keluar</button>
        </form>
    </x-admin.auth-layout>
@else
    <x-admin.layout title="Ganti password">
        <x-admin.page-header title="Ganti password"
            description="Password disimpan dalam bentuk hash bcrypt dan tidak pernah ditampilkan." />
        <div class="card max-w-xl p-6">
            @include('admin.auth.password-form')
        </div>
    </x-admin.layout>
@endif
