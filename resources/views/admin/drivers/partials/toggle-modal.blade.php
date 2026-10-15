{{-- Dipakai di scope x-data dengan objek toggle { open, id, name, active, hasShift }. Aksi lewat API. --}}
<x-admin.modal show="toggle.open" title="Ubah status akun">
    <template x-if="toggle.active && toggle.hasShift">
        <div class="mb-4 flex gap-3 rounded-lg border border-amber-300 bg-amber-50 p-3 text-sm text-amber-900">
            <i class="fa-solid fa-triangle-exclamation mt-0.5" aria-hidden="true"></i>
            <p><strong x-text="toggle.name"></strong> masih memiliki shift terbuka. Akhiri shift di tab Shift terlebih dahulu, baru akun bisa dinonaktifkan.</p>
        </div>
    </template>
    <p class="text-sm text-stone-700" x-show="toggle.active">
        Akun <strong x-text="toggle.name"></strong> akan dinonaktifkan. Driver tidak bisa login, token aplikasinya dicabut, dan tidak menerima broadcast laporan.
    </p>
    <p class="text-sm text-stone-700" x-show="!toggle.active">
        Akun <strong x-text="toggle.name"></strong> akan diaktifkan kembali.
    </p>
    <div class="mt-6 flex justify-end gap-2" x-data="{ busy: false }">
        <button type="button" class="btn-secondary" @click="toggle.open = false">Batal</button>
        <a x-show="toggle.active && toggle.hasShift" :href="`/admin/drivers/${toggle.id}?tab=shift`" class="btn-primary">Buka tab Shift</a>
        <button type="button" x-show="!(toggle.active && toggle.hasShift)" :disabled="busy" :class="toggle.active ? 'btn-danger' : 'btn-primary'"
                @click="busy = true; window.medrive.action(`/api/v1/admin/drivers/${toggle.id}/${toggle.active ? 'deactivate' : 'activate'}`, { successMessage: toggle.active ? `Akun ${toggle.name} dinonaktifkan.` : `Akun ${toggle.name} diaktifkan kembali.` }).then(() => toggle.open = false).catch(() => {}).finally(() => busy = false)"
                x-text="toggle.active ? 'Nonaktifkan akun' : 'Aktifkan akun'"></button>
    </div>
</x-admin.modal>
