@props(['url', 'name', 'title' => 'Hapus data', 'description' => null])
<div x-data="{ open: false }" class="inline">
    <button type="button" class="btn-ghost min-h-9 px-2.5 text-xs text-mr-700" @click="open = true">Hapus</button>
    <x-admin.modal show="open" :title="$title">
        <p class="text-sm text-stone-700">{{ $description ?? "Data {$name} akan dihapus permanen." }}</p>
        <form method="POST" action="{{ $url }}" class="mt-6 flex justify-end gap-2">
            @csrf
            @method('DELETE')
            <button type="button" class="btn-secondary" @click="open = false">Batal</button>
            <button type="submit" class="btn-danger">Hapus</button>
        </form>
    </x-admin.modal>
</div>
