<x-admin.layout title="Edit jenis ambulans" :breadcrumbs="['Jenis ambulans' => route('admin.ambulance-types.index')]">
    <x-admin.page-header title="Edit jenis ambulans" />

    <form x-ref="form" @submit.prevent="submit($event)" novalidate class="card max-w-2xl space-y-5 p-6"
          x-data="apiForm({ url: @js(route('api.v1.admin.ambulance-types.update', $ambulanceTypeId)), method: 'PUT', loadUrl: @js(route('api.v1.admin.ambulance-types.show', $ambulanceTypeId)), mapper: 'ambulanceType', redirect: @js(route('admin.ambulance-types.index')), successMessage: 'Jenis ambulans diperbarui.' })">
        <template x-if="loading"><x-admin.skeleton-rows :rows="3" /></template>
        <div x-show="!loading" class="space-y-5">
            <div>
                <span class="form-label">Kode</span>
                <p class="tabular rounded-lg bg-stone-100 px-3 py-2 text-sm text-stone-700"><span x-text="form.code"></span> <span class="text-xs">(tidak bisa diubah)</span></p>
            </div>
            <x-admin.field name="name" label="Nama" required>
                <input id="name" name="name" type="text" maxlength="100" required x-model="form.name" class="form-input">
            </x-admin.field>
            <x-admin.field name="description" label="Deskripsi">
                <textarea id="description" name="description" maxlength="255" rows="3" x-model="form.description" class="form-input py-2"></textarea>
            </x-admin.field>
            <div class="flex justify-end gap-2 border-t border-stone-100 pt-5">
                <a href="{{ route('admin.ambulance-types.index') }}" class="btn-secondary">Batal</a>
                <button type="submit" class="btn-primary" :disabled="submitting">Simpan perubahan</button>
            </div>
        </div>
    </form>
</x-admin.layout>
