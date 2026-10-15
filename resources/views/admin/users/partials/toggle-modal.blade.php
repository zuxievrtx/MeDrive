{{-- Dipakai di scope x-data yang punya toggle { open, id, name, active, submitting } dan submitToggle(). --}}
<x-admin.modal show="toggle.open" title="Ubah status akun pelapor">
    <p class="text-sm text-stone-700" x-show="toggle.active">Akun <strong x-text="toggle.name"></strong> akan dinonaktifkan dan tidak bisa membuat laporan baru dari aplikasi.</p>
    <p class="text-sm text-stone-700" x-show="!toggle.active">Akun <strong x-text="toggle.name"></strong> akan diaktifkan kembali.</p>
    <div class="mt-6 flex justify-end gap-2">
        <button type="button" class="btn-secondary" @click="toggle.open = false">Batal</button>
        <button type="button" :class="toggle.active ? 'btn-danger' : 'btn-primary'" :disabled="toggle.submitting" @click="submitToggle()" x-text="toggle.active ? 'Nonaktifkan akun' : 'Aktifkan akun'"></button>
    </div>
</x-admin.modal>
