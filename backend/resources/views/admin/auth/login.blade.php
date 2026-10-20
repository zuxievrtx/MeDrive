<x-admin.auth-layout title="Masuk">
    <h1 class="text-2xl font-bold tracking-tight">Masuk ke dashboard admin</h1>
    <p class="mt-1 text-sm text-stone-600">Gunakan akun admin pusat. Akun driver dan pelapor tidak bisa masuk di sini.
    </p>

    @if ($errors->any())
        <div class="mt-6 flex gap-3 rounded-lg border border-mr-300 bg-mr-50 p-3 text-sm text-mr-800" role="alert">
            <i class="fa-solid fa-circle-exclamation mt-0.5" aria-hidden="true"></i>
            <div>{{ $errors->first() }}</div>
        </div>
    @endif

    <form method="POST" action="{{ route('admin.login.store') }}" class="mt-6 space-y-5" x-data="passwordField()">
        @csrf
        <div>
            <label for="email" class="form-label">Email</label>
            <input id="email" name="email" type="email" value="{{ old('email') }}" required autofocus
                autocomplete="username" class="form-input">
        </div>
        <div>
            <label for="password" class="form-label">Password</label>
            <div class="relative">
                <input id="password" name="password" :type="visible ? 'text' : 'password'" required
                    autocomplete="current-password" class="form-input pr-12">
                <button type="button" @click="visible = !visible"
                    class="absolute inset-y-0 right-0 grid w-11 place-items-center rounded-r-lg text-stone-600 hover:text-stone-900"
                    :aria-label="visible ? 'Sembunyikan password' : 'Tampilkan password'">
                    <i class="fa-solid" :class="visible ? 'fa-eye-slash' : 'fa-eye'"></i>
                </button>
            </div>
        </div>
        <button type="submit" class="btn-primary w-full">Masuk</button>
        <p class="text-xs text-stone-600">Setelah 5 kali gagal dalam 1 menit, percobaan masuk ditahan sementara.</p>
    </form>
</x-admin.auth-layout>
