@php $isEdit = $clinicId !== null; @endphp
<x-admin.layout :title="$isEdit ? 'Edit klinik' : 'Tambah klinik'" :breadcrumbs="['Klinik' => route('admin.clinics.index')]">
    <x-admin.page-header :title="$isEdit ? 'Edit klinik' : 'Tambah klinik'" description="Klinik juga dipakai sebagai daftar faskes tujuan (mis. tujuan antar ibu hamil), jadi pastikan titik lokasinya tepat." />

    <div x-data="adminOptions('institutions,clinic_types')">
        <form x-ref="form" @submit.prevent="submit($event)" novalidate class="grid gap-6 xl:grid-cols-[minmax(0,1fr)_minmax(0,1fr)]"
              x-data="apiForm({
                  url: @js($isEdit ? route('api.v1.admin.clinics.update', $clinicId) : route('api.v1.admin.clinics.store')),
                  method: @js($isEdit ? 'PUT' : 'POST'),
                  loadUrl: @js($isEdit ? route('api.v1.admin.clinics.show', $clinicId) : null),
                  mapper: 'clinic',
                  initial: { is_active: true, type: 'klinik', latitude: '', longitude: '' },
                  redirect: @js(route('admin.clinics.index')),
                  successMessage: @js($isEdit ? 'Klinik diperbarui.' : 'Klinik ditambahkan.'),
              })">
            <section class="card space-y-5 p-6">
                <template x-if="loading"><x-admin.skeleton-rows :rows="5" /></template>
                <p x-show="loadError" x-cloak class="form-error" x-text="loadError"></p>
                <x-admin.field name="institution_id" label="Instansi" required>
                    <select id="institution_id" name="institution_id" required x-model="form.institution_id" class="form-input">
                        <option value="">Pilih instansi</option>
                        <template x-for="item in options.institutions ?? []" :key="item.id">
                            <option :value="String(item.id)" :selected="String(item.id) === String(form.institution_id)" x-text="item.name + (item.is_active ? '' : ' (nonaktif)')"></option>
                        </template>
                    </select>
                </x-admin.field>
                <div class="grid gap-5 md:grid-cols-[minmax(0,1fr)_minmax(0,2fr)]">
                    <x-admin.field name="code" label="Kode" required hint="Unik, contoh: PKM-TBL">
                        <input id="code" name="code" type="text" maxlength="20" required x-model="form.code" class="form-input uppercase">
                    </x-admin.field>
                    <x-admin.field name="name" label="Nama klinik" required>
                        <input id="name" name="name" type="text" maxlength="150" required x-model="form.name" class="form-input">
                    </x-admin.field>
                </div>
                <div class="grid gap-5 md:grid-cols-2">
                    <x-admin.field name="type" label="Jenis" required>
                        <select id="type" name="type" required x-model="form.type" class="form-input">
                            <template x-for="item in options.clinic_types ?? []" :key="item.value"><option :value="item.value" :selected="item.value === form.type" x-text="item.label"></option></template>
                        </select>
                    </x-admin.field>
                    <x-admin.field name="phone" label="Telepon">
                        <input id="phone" name="phone" type="tel" maxlength="20" x-model="form.phone" class="form-input">
                    </x-admin.field>
                </div>
                <x-admin.field name="address" label="Alamat" required>
                    <input id="address" name="address" type="text" maxlength="255" required x-model="form.address" class="form-input">
                </x-admin.field>
                <div>
                    <input type="hidden" name="is_active" value="0">
                    <label class="inline-flex min-h-10 items-center gap-3 text-sm">
                        <input type="checkbox" name="is_active" value="1" class="size-4 accent-mr-600" x-model="form.is_active">
                        Klinik aktif
                    </label>
                </div>
            </section>

            <section class="card flex flex-col p-6" x-data="clinicPicker()" x-effect="syncFromForm(form.latitude, form.longitude)">
                <h2 class="font-semibold">Titik lokasi <span class="text-mr-700" aria-hidden="true">*</span></h2>
                <p class="mb-3 text-sm text-stone-600">Klik peta atau geser pin untuk menentukan lokasi. Koordinat juga bisa diketik langsung.</p>
                <div class="relative min-h-80 flex-1 overflow-hidden rounded-lg border border-stone-200">
                    <div x-ref="map" class="absolute inset-0 z-0"></div>
                    <div x-show="!ready && !mapError" class="absolute inset-0 z-10 bg-white p-2"><div class="skeleton h-full w-full"></div></div>
                    <p x-show="mapError" x-cloak class="absolute inset-0 z-10 grid place-items-center bg-white p-4 text-center text-sm text-mr-700" x-text="mapError"></p>
                </div>
                <div class="mt-4 grid gap-4 sm:grid-cols-2">
                    <x-admin.field name="latitude" label="Latitude" required>
                        <input id="latitude" name="latitude" type="number" step="0.0000001" min="-90" max="90" required x-model="form.latitude" class="form-input tabular">
                    </x-admin.field>
                    <x-admin.field name="longitude" label="Longitude" required>
                        <input id="longitude" name="longitude" type="number" step="0.0000001" min="-180" max="180" required x-model="form.longitude" class="form-input tabular">
                    </x-admin.field>
                </div>
                <p class="mt-2 text-xs text-stone-600" x-show="form.latitude && form.longitude">Titik terpilih: <span class="tabular font-semibold" x-text="`${form.latitude}, ${form.longitude}`"></span></p>
            </section>

            <div class="flex justify-end gap-2 xl:col-span-2">
                <a href="{{ route('admin.clinics.index') }}" class="btn-secondary">Batal</a>
                <button type="submit" class="btn-primary" :disabled="submitting || loading">{{ $isEdit ? 'Simpan perubahan' : 'Simpan klinik' }}</button>
            </div>
        </form>
    </div>
</x-admin.layout>
