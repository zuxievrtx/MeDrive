@php $isEdit = $institutionId !== null; @endphp
<x-admin.layout :title="$isEdit ? 'Edit instansi' : 'Tambah instansi'" :breadcrumbs="['Instansi' => route('admin.institutions.index')]">
    <x-admin.page-header :title="$isEdit ? 'Edit instansi' : 'Tambah instansi'" />

    <div x-data="adminOptions('institution_types')">
        <form x-ref="form" @submit.prevent="submit($event)" novalidate class="card max-w-3xl space-y-5 p-6"
              x-data="apiForm({
                  url: @js($isEdit ? route('api.v1.admin.institutions.update', $institutionId) : route('api.v1.admin.institutions.store')),
                  method: @js($isEdit ? 'PUT' : 'POST'),
                  loadUrl: @js($isEdit ? route('api.v1.admin.institutions.show', $institutionId) : null),
                  mapper: 'institution',
                  initial: { is_active: true },
                  redirect: @js(route('admin.institutions.index')),
                  successMessage: @js($isEdit ? 'Instansi diperbarui.' : 'Instansi ditambahkan.'),
              })">
            <template x-if="loading"><x-admin.skeleton-rows :rows="5" /></template>
            <p x-show="loadError" x-cloak class="form-error" x-text="loadError"></p>
            <div x-show="!loading" class="space-y-5">
                <div class="grid gap-5 md:grid-cols-[minmax(0,1fr)_minmax(0,2fr)]">
                    <x-admin.field name="code" label="Kode" required hint="Unik, contoh: DINKES-SMG">
                        <input id="code" name="code" type="text" maxlength="20" required x-model="form.code" class="form-input uppercase">
                    </x-admin.field>
                    <x-admin.field name="name" label="Nama instansi" required>
                        <input id="name" name="name" type="text" maxlength="150" required x-model="form.name" class="form-input">
                    </x-admin.field>
                </div>
                <div class="grid gap-5 md:grid-cols-3">
                    <x-admin.field name="type" label="Jenis" required>
                        <select id="type" name="type" required x-model="form.type" class="form-input">
                            <option value="">Pilih jenis</option>
                            <template x-for="item in options.institution_types ?? []" :key="item.value"><option :value="item.value" :selected="item.value === form.type" x-text="item.label"></option></template>
                        </select>
                    </x-admin.field>
                    <x-admin.field name="phone" label="Telepon">
                        <input id="phone" name="phone" type="tel" maxlength="20" x-model="form.phone" class="form-input">
                    </x-admin.field>
                    <x-admin.field name="email" label="Email">
                        <input id="email" name="email" type="email" maxlength="100" x-model="form.email" class="form-input">
                    </x-admin.field>
                </div>
                <x-admin.field name="address" label="Alamat">
                    <input id="address" name="address" type="text" maxlength="255" x-model="form.address" class="form-input">
                </x-admin.field>
                <div>
                    <input type="hidden" name="is_active" value="0">
                    <label class="inline-flex min-h-10 items-center gap-3 text-sm">
                        <input type="checkbox" name="is_active" value="1" class="size-4 accent-mr-600" x-model="form.is_active">
                        Instansi aktif
                    </label>
                </div>
                <div class="flex justify-end gap-2 border-t border-stone-100 pt-5">
                    <a href="{{ route('admin.institutions.index') }}" class="btn-secondary">Batal</a>
                    <button type="submit" class="btn-primary" :disabled="submitting">{{ $isEdit ? 'Simpan perubahan' : 'Simpan instansi' }}</button>
                </div>
            </div>
        </form>
    </div>
</x-admin.layout>
