@php $isEdit = $institution->exists; @endphp
<x-admin.layout :title="$isEdit ? 'Edit instansi' : 'Tambah instansi'" :breadcrumbs="['Instansi' => route('admin.institutions.index')]">
    <x-admin.page-header :title="$isEdit ? 'Edit '.$institution->name : 'Tambah instansi'" />

    <form method="POST" action="{{ $isEdit ? route('admin.institutions.update', $institution) : route('admin.institutions.store') }}" class="card max-w-3xl space-y-5 p-6">
        @csrf
        @if ($isEdit) @method('PUT') @endif
        <div class="grid gap-5 md:grid-cols-[minmax(0,1fr)_minmax(0,2fr)]">
            <x-admin.field name="code" label="Kode" required hint="Unik, contoh: DINKES-SMG">
                <input id="code" name="code" type="text" maxlength="20" required value="{{ old('code', $institution->code) }}" class="form-input uppercase">
            </x-admin.field>
            <x-admin.field name="name" label="Nama instansi" required>
                <input id="name" name="name" type="text" maxlength="150" required value="{{ old('name', $institution->name) }}" class="form-input">
            </x-admin.field>
        </div>
        <div class="grid gap-5 md:grid-cols-3">
            <x-admin.field name="type" label="Jenis" required>
                <select id="type" name="type" required class="form-input">
                    <option value="">Pilih jenis</option>
                    @foreach ($types as $type)<option value="{{ $type->value }}" @selected(old('type', $institution->type?->value) === $type->value)>{{ $type->label() }}</option>@endforeach
                </select>
            </x-admin.field>
            <x-admin.field name="phone" label="Telepon">
                <input id="phone" name="phone" type="tel" maxlength="20" value="{{ old('phone', $institution->phone) }}" class="form-input">
            </x-admin.field>
            <x-admin.field name="email" label="Email">
                <input id="email" name="email" type="email" maxlength="100" value="{{ old('email', $institution->email) }}" class="form-input">
            </x-admin.field>
        </div>
        <x-admin.field name="address" label="Alamat">
            <input id="address" name="address" type="text" maxlength="255" value="{{ old('address', $institution->address) }}" class="form-input">
        </x-admin.field>
        <div>
            <input type="hidden" name="is_active" value="0">
            <label class="inline-flex min-h-10 items-center gap-3 text-sm">
                <input type="checkbox" name="is_active" value="1" class="size-4 accent-mr-600" @checked(old('is_active', $institution->is_active))>
                Instansi aktif
            </label>
        </div>
        <div class="flex justify-end gap-2 border-t border-stone-100 pt-5">
            <a href="{{ route('admin.institutions.index') }}" class="btn-secondary">Batal</a>
            <button type="submit" class="btn-primary">{{ $isEdit ? 'Simpan perubahan' : 'Simpan instansi' }}</button>
        </div>
    </form>
</x-admin.layout>
