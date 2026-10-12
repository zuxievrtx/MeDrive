<x-admin.layout title="Klinik" :breadcrumbs="['Organisasi' => route('admin.institutions.index')]">
    <x-admin.page-header title="Klinik" description="Klinik, puskesmas, rumah sakit, dan pos ambulans tempat driver dan ambulans bernaung. Klinik juga muncul sebagai pilihan faskes tujuan di aplikasi pelapor.">
        <x-slot:actions><a href="{{ route('admin.clinics.create') }}" class="btn-primary"><i class="fa-solid fa-plus" aria-hidden="true"></i> Tambah klinik</a></x-slot:actions>
    </x-admin.page-header>

    <x-admin.filter-bar :action="route('admin.clinics.index')" :reset-url="route('admin.clinics.index')">
        <div>
            <label for="q" class="form-label">Cari</label>
            <input id="q" name="q" type="search" value="{{ $filters['q'] ?? '' }}" placeholder="Nama, kode, alamat" class="form-input">
        </div>
        <div>
            <label for="institution_id" class="form-label">Instansi</label>
            <select id="institution_id" name="institution_id" class="form-input">
                <option value="">Semua instansi</option>
                @foreach ($institutions as $institution)<option value="{{ $institution->id }}" @selected(($filters['institution_id'] ?? null) == $institution->id)>{{ $institution->name }}</option>@endforeach
            </select>
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
        @if ($clinics->isEmpty())
            <x-admin.empty-state icon="house-medical" title="Belum ada klinik yang cocok" />
        @else
            <div class="relative overflow-x-auto">
                <table class="data-table">
                    <thead><tr><th>Kode</th><th>Klinik</th><th>Instansi</th><th>Jenis</th><th>Koordinat</th><th>Driver</th><th>Ambulans</th><th>Status</th><th><span class="sr-only">Aksi</span></th></tr></thead>
                    <tbody>
                        @foreach ($clinics as $clinic)
                            <tr class="hover:bg-stone-50">
                                <td class="tabular font-semibold whitespace-nowrap">{{ $clinic->code }}</td>
                                <td>
                                    <div class="font-medium">{{ $clinic->name }}</div>
                                    <div class="text-xs text-stone-600">{{ $clinic->address }}</div>
                                </td>
                                <td class="whitespace-nowrap">{{ $clinic->institution->name }}</td>
                                <td class="whitespace-nowrap">{{ $clinic->type->label() }}</td>
                                <td class="tabular text-xs whitespace-nowrap">
                                    <a href="https://www.openstreetmap.org/?mlat={{ $clinic->latitude }}&mlon={{ $clinic->longitude }}#map=17/{{ $clinic->latitude }}/{{ $clinic->longitude }}" target="_blank" rel="noopener" class="hover:text-mr-700">
                                        {{ number_format((float) $clinic->latitude, 5) }}, {{ number_format((float) $clinic->longitude, 5) }}
                                    </a>
                                </td>
                                <td><a href="{{ route('admin.drivers.index', ['clinic_id' => $clinic->id]) }}" class="tabular font-semibold hover:text-mr-700">{{ $clinic->driver_profiles_count }}</a></td>
                                <td><a href="{{ route('admin.ambulances.index', ['clinic_id' => $clinic->id]) }}" class="tabular font-semibold hover:text-mr-700">{{ $clinic->ambulances_count }}</a></td>
                                <td><x-admin.active-badge :active="$clinic->is_active" /></td>
                                <td>
                                    <div class="flex justify-end gap-1">
                                        <a href="{{ route('admin.clinics.edit', $clinic) }}" class="btn-ghost min-h-9 px-2.5 text-xs">Edit</a>
                                        <x-admin.delete-button :url="route('admin.clinics.destroy', $clinic)" :name="$clinic->name" title="Hapus klinik"
                                            :description="($clinic->driver_profiles_count + $clinic->ambulances_count) > 0 ? 'Klinik '.$clinic->name.' masih memiliki driver atau ambulans, jadi penghapusan akan ditolak. Nonaktifkan klinik bila sudah tidak dipakai.' : null" />
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            <div class="border-t border-stone-100 px-4 py-3">{{ $clinics->links() }}</div>
        @endif
    </div>
</x-admin.layout>
