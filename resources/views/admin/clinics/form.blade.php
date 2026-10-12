@php $isEdit = $clinic->exists; @endphp
<x-admin.layout :title="$isEdit ? 'Edit klinik' : 'Tambah klinik'" :breadcrumbs="['Klinik' => route('admin.clinics.index')]">
    <x-admin.page-header :title="$isEdit ? 'Edit '.$clinic->name : 'Tambah klinik'" description="Klinik juga dipakai sebagai daftar faskes tujuan (mis. tujuan antar ibu hamil), jadi pastikan titik lokasinya tepat." />

    <form method="POST" action="{{ $isEdit ? route('admin.clinics.update', $clinic) : route('admin.clinics.store') }}"
          class="grid gap-6 xl:grid-cols-[minmax(0,1fr)_minmax(0,1fr)]"
          x-data="clinicPicker({ lat: @js(old('latitude', $clinic->latitude)), lng: @js(old('longitude', $clinic->longitude)) })">
        @csrf
        @if ($isEdit) @method('PUT') @endif

        <section class="card space-y-5 p-6">
            <x-admin.field name="institution_id" label="Instansi" required>
                <select id="institution_id" name="institution_id" required class="form-input">
                    <option value="">Pilih instansi</option>
                    @foreach ($institutions as $institution)
                        <option value="{{ $institution->id }}" @selected(old('institution_id', $clinic->institution_id) == $institution->id)>{{ $institution->name }}{{ $institution->is_active ? '' : ' (nonaktif)' }}</option>
                    @endforeach
                </select>
            </x-admin.field>
            <div class="grid gap-5 md:grid-cols-[minmax(0,1fr)_minmax(0,2fr)]">
                <x-admin.field name="code" label="Kode" required hint="Unik, contoh: PKM-TBL">
                    <input id="code" name="code" type="text" maxlength="20" required value="{{ old('code', $clinic->code) }}" class="form-input uppercase">
                </x-admin.field>
                <x-admin.field name="name" label="Nama klinik" required>
                    <input id="name" name="name" type="text" maxlength="150" required value="{{ old('name', $clinic->name) }}" class="form-input">
                </x-admin.field>
            </div>
            <div class="grid gap-5 md:grid-cols-2">
                <x-admin.field name="type" label="Jenis" required>
                    <select id="type" name="type" required class="form-input">
                        @foreach ($types as $type)<option value="{{ $type->value }}" @selected(old('type', $clinic->type?->value ?? 'klinik') === $type->value)>{{ $type->label() }}</option>@endforeach
                    </select>
                </x-admin.field>
                <x-admin.field name="phone" label="Telepon">
                    <input id="phone" name="phone" type="tel" maxlength="20" value="{{ old('phone', $clinic->phone) }}" class="form-input">
                </x-admin.field>
            </div>
            <x-admin.field name="address" label="Alamat" required>
                <input id="address" name="address" type="text" maxlength="255" required value="{{ old('address', $clinic->address) }}" class="form-input">
            </x-admin.field>
            <div>
                <input type="hidden" name="is_active" value="0">
                <label class="inline-flex min-h-10 items-center gap-3 text-sm">
                    <input type="checkbox" name="is_active" value="1" class="size-4 accent-mr-600" @checked(old('is_active', $clinic->is_active))>
                    Klinik aktif
                </label>
            </div>
        </section>

        <section class="card flex flex-col p-6">
            <h2 class="font-semibold">Titik lokasi <span class="text-mr-700" aria-hidden="true">*</span></h2>
            <p class="mb-3 text-sm text-stone-600">Klik peta atau geser pin untuk menentukan lokasi. Koordinat juga bisa diketik langsung.</p>
            <div class="relative min-h-80 flex-1 overflow-hidden rounded-lg border border-stone-200">
                <div x-ref="map" class="absolute inset-0 z-0"></div>
                <div x-show="!ready && !error" class="absolute inset-0 z-10 bg-white p-2"><div class="skeleton h-full w-full"></div></div>
                <p x-show="error" x-cloak class="absolute inset-0 z-10 grid place-items-center bg-white p-4 text-center text-sm text-mr-700" x-text="error"></p>
            </div>
            <div class="mt-4 grid gap-4 sm:grid-cols-2">
                <x-admin.field name="latitude" label="Latitude" required>
                    <input id="latitude" name="latitude" type="number" step="0.0000001" min="-90" max="90" required x-model="lat" class="form-input tabular">
                </x-admin.field>
                <x-admin.field name="longitude" label="Longitude" required>
                    <input id="longitude" name="longitude" type="number" step="0.0000001" min="-180" max="180" required x-model="lng" class="form-input tabular">
                </x-admin.field>
            </div>
            <p class="mt-2 text-xs text-stone-600" x-show="lat && lng">Titik terpilih: <span class="tabular font-semibold" x-text="`${lat}, ${lng}`"></span></p>
        </section>

        <div class="flex justify-end gap-2 xl:col-span-2">
            <a href="{{ route('admin.clinics.index') }}" class="btn-secondary">Batal</a>
            <button type="submit" class="btn-primary">{{ $isEdit ? 'Simpan perubahan' : 'Simpan klinik' }}</button>
        </div>
    </form>
</x-admin.layout>
