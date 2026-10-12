@php $isEdit = $ambulance->exists; @endphp
<x-admin.layout :title="$isEdit ? 'Edit ambulans' : 'Tambah ambulans'" :breadcrumbs="['Ambulans' => route('admin.ambulances.index')]">
    <x-admin.page-header :title="$isEdit ? 'Edit '.$ambulance->plate_number : 'Tambah ambulans'" />

    <form method="POST" action="{{ $isEdit ? route('admin.ambulances.update', $ambulance) : route('admin.ambulances.store') }}" class="card max-w-3xl space-y-5 p-6">
        @csrf
        @if ($isEdit) @method('PUT') @endif
        <div class="grid gap-5 md:grid-cols-2">
            <x-admin.field name="clinic_id" label="Klinik" required>
                <select id="clinic_id" name="clinic_id" required class="form-input">
                    <option value="">Pilih klinik</option>
                    @foreach ($clinics as $clinic)<option value="{{ $clinic->id }}" @selected(old('clinic_id', $ambulance->clinic_id) == $clinic->id)>{{ $clinic->labelWithInstitution() }}</option>@endforeach
                </select>
            </x-admin.field>
            <x-admin.field name="ambulance_type_id" label="Jenis ambulans" required hint="Menentukan jenis laporan yang bisa dilayani.">
                <select id="ambulance_type_id" name="ambulance_type_id" required class="form-input">
                    <option value="">Pilih jenis</option>
                    @foreach ($ambulanceTypes as $type)<option value="{{ $type->id }}" @selected(old('ambulance_type_id', $ambulance->ambulance_type_id) == $type->id)>{{ $type->name }}</option>@endforeach
                </select>
            </x-admin.field>
        </div>
        <div class="grid gap-5 md:grid-cols-3">
            <x-admin.field name="plate_number" label="Nomor polisi" required hint="Contoh: H 1234 AB">
                <input id="plate_number" name="plate_number" type="text" maxlength="15" required value="{{ old('plate_number', $ambulance->plate_number) }}" class="form-input tabular uppercase">
            </x-admin.field>
            <x-admin.field name="vehicle_name" label="Kendaraan" hint="Merek dan model">
                <input id="vehicle_name" name="vehicle_name" type="text" maxlength="100" value="{{ old('vehicle_name', $ambulance->vehicle_name) }}" class="form-input">
            </x-admin.field>
            <x-admin.field name="year" label="Tahun">
                <input id="year" name="year" type="number" min="1980" max="{{ now()->year + 1 }}" value="{{ old('year', $ambulance->year) }}" class="form-input tabular">
            </x-admin.field>
        </div>
        <x-admin.field name="status" label="Status" required>
            <div class="flex flex-wrap gap-2">
                @foreach ($statuses as $status)
                    <label class="inline-flex min-h-10 cursor-pointer items-center gap-2 rounded-lg border border-stone-300 px-3 text-sm has-[:checked]:border-mr-600 has-[:checked]:bg-mr-50">
                        <input type="radio" name="status" value="{{ $status->value }}" class="accent-mr-600" @checked(old('status', $ambulance->status?->value) === $status->value)>
                        {{ $status->label() }}
                    </label>
                @endforeach
            </div>
        </x-admin.field>
        <x-admin.field name="notes" label="Catatan">
            <input id="notes" name="notes" type="text" maxlength="255" value="{{ old('notes', $ambulance->notes) }}" class="form-input">
        </x-admin.field>
        <div class="flex justify-end gap-2 border-t border-stone-100 pt-5">
            <a href="{{ route('admin.ambulances.index') }}" class="btn-secondary">Batal</a>
            <button type="submit" class="btn-primary">{{ $isEdit ? 'Simpan perubahan' : 'Simpan ambulans' }}</button>
        </div>
    </form>
</x-admin.layout>
