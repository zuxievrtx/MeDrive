<x-admin.layout title="Edit driver" :breadcrumbs="['Driver' => route('admin.drivers.index'), 'Detail' => route('admin.drivers.show', $driverId)]">
    <div x-data="adminOptions('clinics,license_classes')">
        <form x-ref="form" x-data="apiForm({ url: @js(route('api.v1.admin.drivers.update', $driverId)), method: 'PUT', loadUrl: @js(route('api.v1.admin.drivers.show', $driverId)), mapper: 'driver', redirect: @js(route('admin.drivers.show', $driverId)), successMessage: 'Data driver berhasil diperbarui.' })"
              @submit.prevent="submit($event)" enctype="multipart/form-data" class="space-y-6" novalidate>
            <x-admin.page-header title="Edit driver" description="Semua perubahan dicatat di log aktivitas admin beserta field yang berubah.">
                <x-slot:actions><span class="text-sm font-semibold text-stone-700" x-text="form.name"></span></x-slot:actions>
            </x-admin.page-header>

            <template x-if="loading"><div class="card"><x-admin.skeleton-rows :rows="6" /></div></template>
            <div x-show="loadError" x-cloak class="rounded-lg border border-mr-300 bg-mr-50 p-4 text-sm text-mr-800" role="alert" x-text="loadError"></div>

            <div x-show="!loading && !loadError" class="space-y-6">
                @include('admin.drivers.partials.form-fields', ['isEdit' => true])

                <div class="flex flex-wrap justify-end gap-2">
                    <a href="{{ route('admin.drivers.show', $driverId) }}" class="btn-secondary">Batal</a>
                    <button type="submit" class="btn-primary" :disabled="submitting">
                        <i class="fa-solid" :class="submitting ? 'fa-spinner fa-spin' : 'fa-floppy-disk'" aria-hidden="true"></i>
                        <span x-text="submitting ? 'Menyimpan...' : 'Simpan perubahan'"></span>
                    </button>
                </div>
            </div>
        </form>
    </div>
</x-admin.layout>
