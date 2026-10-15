@props(['url', 'name', 'title' => 'Hapus data', 'note' => null])
{{-- Tombol hapus untuk baris apiList. url & name berupa ekspresi JS. Penolakan FK (409) tampil sebagai toast. --}}
<div x-data="{ open: false, busy: false }" class="inline">
    <button type="button" class="btn-ghost min-h-9 px-2.5 text-xs text-mr-700" @click="open = true">Hapus</button>
    <x-admin.modal show="open" :title="$title">
        <p class="text-sm text-stone-700"><span x-text="`Data ${ {!! $name !!} } akan dihapus permanen.`"></span> {{ $note }}</p>
        <div class="mt-6 flex justify-end gap-2">
            <button type="button" class="btn-secondary" @click="open = false">Batal</button>
            <button type="button" class="btn-danger" :disabled="busy"
                    @click="busy = true; window.medrive.action({!! $url !!}, { method: 'DELETE', successMessage: `${ {!! $name !!} } dihapus.` }).catch(() => {}).finally(() => { busy = false; open = false })">Hapus</button>
        </div>
    </x-admin.modal>
</div>
