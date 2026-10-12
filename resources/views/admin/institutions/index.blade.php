<x-admin.layout title="Instansi" :breadcrumbs="['Organisasi' => route('admin.institutions.index')]">
    <x-admin.page-header title="Instansi" description="Lembaga induk klinik dan pos ambulans: dinas kesehatan, PMI, yayasan, atau swasta.">
        <x-slot:actions><a href="{{ route('admin.institutions.create') }}" class="btn-primary"><i class="fa-solid fa-plus" aria-hidden="true"></i> Tambah instansi</a></x-slot:actions>
    </x-admin.page-header>

    <x-admin.filter-bar :action="route('admin.institutions.index')" :reset-url="route('admin.institutions.index')">
        <div>
            <label for="q" class="form-label">Cari</label>
            <input id="q" name="q" type="search" value="{{ $filters['q'] ?? '' }}" placeholder="Nama atau kode" class="form-input">
        </div>
        <div>
            <label for="type" class="form-label">Jenis</label>
            <select id="type" name="type" class="form-input">
                <option value="">Semua jenis</option>
                @foreach ($types as $type)<option value="{{ $type->value }}" @selected(($filters['type'] ?? null) === $type->value)>{{ $type->label() }}</option>@endforeach
            </select>
        </div>
        <div>
            <label for="active" class="form-label">Status</label>
            <select id="active" name="active" class="form-input">
                <option value="">Semua</option>
                <option value="1" @selected(($filters['active'] ?? null) === '1')>Aktif</option>
                <option value="0" @selected(($filters['active'] ?? null) === '0')>Nonaktif</option>
            </select>
        </div>
    </x-admin.filter-bar>

    <div class="card overflow-hidden">
        @if ($institutions->isEmpty())
            <x-admin.empty-state icon="building" title="Belum ada instansi yang cocok" />
        @else
            <div class="relative overflow-x-auto">
                <table class="data-table">
                    <thead><tr><th>Kode</th><th>Nama</th><th>Jenis</th><th>Kontak</th><th>Klinik</th><th>Status</th><th><span class="sr-only">Aksi</span></th></tr></thead>
                    <tbody>
                        @foreach ($institutions as $institution)
                            <tr class="hover:bg-stone-50">
                                <td class="tabular font-semibold whitespace-nowrap">{{ $institution->code }}</td>
                                <td>
                                    <div class="font-medium">{{ $institution->name }}</div>
                                    <div class="text-xs text-stone-600">{{ $institution->address ?? '-' }}</div>
                                </td>
                                <td>{{ $institution->type->label() }}</td>
                                <td class="text-xs whitespace-nowrap">
                                    <div>{{ $institution->phone ?? '-' }}</div>
                                    <div class="text-stone-600">{{ $institution->email ?? '' }}</div>
                                </td>
                                <td><a href="{{ route('admin.clinics.index', ['institution_id' => $institution->id]) }}" class="tabular font-semibold hover:text-mr-700">{{ $institution->clinics_count }}</a></td>
                                <td><x-admin.active-badge :active="$institution->is_active" /></td>
                                <td>
                                    <div class="flex justify-end gap-1">
                                        <a href="{{ route('admin.institutions.edit', $institution) }}" class="btn-ghost min-h-9 px-2.5 text-xs">Edit</a>
                                        <x-admin.delete-button :url="route('admin.institutions.destroy', $institution)" :name="$institution->name" title="Hapus instansi"
                                            :description="$institution->clinics_count > 0 ? 'Instansi '.$institution->name.' masih memiliki '.$institution->clinics_count.' klinik, jadi penghapusan akan ditolak. Nonaktifkan instansi bila sudah tidak dipakai.' : null" />
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            <div class="border-t border-stone-100 px-4 py-3">{{ $institutions->links() }}</div>
        @endif
    </div>
</x-admin.layout>
