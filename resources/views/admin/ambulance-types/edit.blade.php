<x-admin.layout title="Edit jenis ambulans" :breadcrumbs="['Jenis ambulans' => route('admin.ambulance-types.index')]">
    <x-admin.page-header :title="'Edit '.$ambulanceType->name" />

    <form method="POST" action="{{ route('admin.ambulance-types.update', $ambulanceType) }}" class="card max-w-2xl space-y-5 p-6">
        @csrf
        @method('PUT')
        <div>
            <span class="form-label">Kode</span>
            <p class="tabular rounded-lg bg-stone-100 px-3 py-2 text-sm text-stone-700">{{ $ambulanceType->code }} <span class="text-xs">(tidak bisa diubah)</span></p>
        </div>
        <x-admin.field name="name" label="Nama" required>
            <input id="name" name="name" type="text" maxlength="100" required value="{{ old('name', $ambulanceType->name) }}" class="form-input">
        </x-admin.field>
        <x-admin.field name="description" label="Deskripsi">
            <textarea id="description" name="description" maxlength="255" rows="3" class="form-input py-2">{{ old('description', $ambulanceType->description) }}</textarea>
        </x-admin.field>
        <div class="flex justify-end gap-2 border-t border-stone-100 pt-5">
            <a href="{{ route('admin.ambulance-types.index') }}" class="btn-secondary">Batal</a>
            <button type="submit" class="btn-primary">Simpan perubahan</button>
        </div>
    </form>
</x-admin.layout>
