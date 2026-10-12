<x-admin.modal show="toggle.open" title="Ubah status akun pelapor">
    <p class="text-sm text-stone-700" x-show="toggle.active">Akun <strong x-text="toggle.name"></strong> akan dinonaktifkan dan tidak bisa membuat laporan baru dari aplikasi.</p>
    <p class="text-sm text-stone-700" x-show="!toggle.active">Akun <strong x-text="toggle.name"></strong> akan diaktifkan kembali.</p>
    <form method="POST" :action="toggle.url" class="mt-6 flex justify-end gap-2">
        @csrf
        @method('PATCH')
        <button type="button" class="btn-secondary" @click="toggle.open = false">Batal</button>
        <button type="submit" :class="toggle.active ? 'btn-danger' : 'btn-primary'" x-text="toggle.active ? 'Nonaktifkan akun' : 'Aktifkan akun'"></button>
    </form>
</x-admin.modal>
