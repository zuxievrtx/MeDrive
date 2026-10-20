@php $isEdit = $ambulanceId !== null; @endphp
<x-admin.layout :title="$isEdit ? 'Edit ambulans' : 'Tambah ambulans'" :breadcrumbs="['Ambulans' => route('admin.ambulances.index')]">
    <x-admin.page-header :title="$isEdit ? 'Edit ambulans' : 'Tambah ambulans'" />

    <div x-data="adminOptions('clinics,ambulance_types,ambulance_statuses')">
        <form x-ref="form" @submit.prevent="submit($event)" novalidate class="card max-w-3xl space-y-5 p-6"
              x-data="apiForm({
                  url: @js($isEdit ? route('api.v1.admin.ambulances.update', $ambulanceId) : route('api.v1.admin.ambulances.store')),
                  method: @js($isEdit ? 'PUT' : 'POST'),
                  loadUrl: @js($isEdit ? route('api.v1.admin.ambulances.show', $ambulanceId) : null),
                  mapper: 'ambulance',
                  initial: { status: 'tersedia' },
                  redirect: @js(route('admin.ambulances.index')),
                  successMessage: @js($isEdit ? 'Ambulans diperbarui.' : 'Ambulans ditambahkan.'),
              })">
            <template x-if="loading"><x-admin.skeleton-rows :rows="5" /></template>
            <p x-show="loadError" x-cloak class="form-error" x-text="loadError"></p>
            <div x-show="!loading" class="space-y-5">
                <p x-show="form.in_use" x-cloak class="flex gap-2 rounded-lg border border-amber-300 bg-amber-50 p-3 text-sm text-amber-900">
                    <i class="fa-solid fa-triangle-exclamation mt-0.5" aria-hidden="true"></i>
                    <span x-text="`Sedang dipakai ${form.used_by?.name ?? 'driver'}. Status dan klinik baru bisa diubah setelah shift diakhiri.`"></span>
                </p>
                <div class="grid gap-5 md:grid-cols-2">
                    <x-admin.field name="clinic_id" label="Klinik" required>
                        <select id="clinic_id" name="clinic_id" required x-model="form.clinic_id" class="form-input">
                            <option value="">Pilih klinik</option>
                            <template x-for="item in options.clinics ?? []" :key="item.id"><option :value="String(item.id)" :selected="String(item.id) === String(form.clinic_id)" x-text="item.label"></option></template>
                        </select>
                    </x-admin.field>
                    <x-admin.field name="ambulance_type_id" label="Jenis ambulans" required hint="Menentukan jenis laporan yang bisa dilayani.">
                        <select id="ambulance_type_id" name="ambulance_type_id" required x-model="form.ambulance_type_id" class="form-input">
                            <option value="">Pilih jenis</option>
                            <template x-for="item in options.ambulance_types ?? []" :key="item.id"><option :value="String(item.id)" :selected="String(item.id) === String(form.ambulance_type_id)" x-text="item.name"></option></template>
                        </select>
                    </x-admin.field>
                </div>
                <div class="grid gap-5 md:grid-cols-3">
                    <x-admin.field name="plate_number" label="Nomor polisi" required hint="Contoh: H 1234 AB">
                        <input id="plate_number" name="plate_number" type="text" maxlength="15" required x-model="form.plate_number" class="form-input tabular uppercase">
                    </x-admin.field>
                    <x-admin.field name="vehicle_name" label="Kendaraan" hint="Merek dan model">
                        <input id="vehicle_name" name="vehicle_name" type="text" maxlength="100" x-model="form.vehicle_name" class="form-input">
                    </x-admin.field>
                    <x-admin.field name="year" label="Tahun">
                        <input id="year" name="year" type="number" min="1980" max="{{ now()->year + 1 }}" x-model="form.year" class="form-input tabular">
                    </x-admin.field>
                </div>
                <x-admin.field name="status" label="Status" required>
                    <div class="flex flex-wrap gap-2">
                        <template x-for="item in options.ambulance_statuses ?? []" :key="item.value">
                            <label class="inline-flex min-h-10 cursor-pointer items-center gap-2 rounded-lg border border-stone-300 px-3 text-sm has-[:checked]:border-mr-600 has-[:checked]:bg-mr-50">
                                <input type="radio" name="status" :value="item.value" x-model="form.status" class="accent-mr-600">
                                <span x-text="item.label"></span>
                            </label>
                        </template>
                    </div>
                </x-admin.field>
                <x-admin.field name="notes" label="Catatan">
                    <input id="notes" name="notes" type="text" maxlength="255" x-model="form.notes" class="form-input">
                </x-admin.field>
                <div class="flex justify-end gap-2 border-t border-stone-100 pt-5">
                    <a href="{{ route('admin.ambulances.index') }}" class="btn-secondary">Batal</a>
                    <button type="submit" class="btn-primary" :disabled="submitting">{{ $isEdit ? 'Simpan perubahan' : 'Simpan ambulans' }}</button>
                </div>
            </div>
        </form>
    </div>
</x-admin.layout>
