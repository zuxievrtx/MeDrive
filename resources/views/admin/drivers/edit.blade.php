<x-admin.layout title="Edit driver" :breadcrumbs="['Driver' => route('admin.drivers.index'), $driver->name => route('admin.drivers.show', $driver)]">
    <x-admin.page-header title="Edit {{ $driver->name }}" description="Semua perubahan dicatat di log aktivitas admin beserta field yang berubah." />

    <form method="POST" action="{{ route('admin.drivers.update', $driver) }}" enctype="multipart/form-data" class="space-y-6">
        @csrf
        @method('PUT')
        @include('admin.drivers.partials.form-fields')

        <div class="flex flex-wrap justify-end gap-2">
            <a href="{{ route('admin.drivers.show', $driver) }}" class="btn-secondary">Batal</a>
            <button type="submit" class="btn-primary"><i class="fa-solid fa-floppy-disk" aria-hidden="true"></i> Simpan perubahan</button>
        </div>
    </form>
</x-admin.layout>
