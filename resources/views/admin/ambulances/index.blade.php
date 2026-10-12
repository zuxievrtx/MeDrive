<x-admin.layout title="Ambulans" :breadcrumbs="['Manajemen Armada' => route('admin.drivers.index')]">
    <x-admin.page-header title="Ambulans" description="Ambulans berstatus tersedia bisa dipilih driver klinik yang sama saat membuka shift.">
        <x-slot:actions><a href="{{ route('admin.ambulances.create') }}" class="btn-primary"><i class="fa-solid fa-plus" aria-hidden="true"></i> Tambah ambulans</a></x-slot:actions>
    </x-admin.page-header>

    <x-admin.filter-bar :action="route('admin.ambulances.index')" :reset-url="route('admin.ambulances.index')">
        <div>
            <label for="q" class="form-label">Nomor polisi</label>
            <input id="q" name="q" type="search" value="{{ $filters['q'] ?? '' }}" placeholder="H 1234" class="form-input uppercase">
        </div>
        <div>
            <label for="clinic_id" class="form-label">Klinik</label>
            <select id="clinic_id" name="clinic_id" class="form-input">
                <option value="">Semua klinik</option>
                @foreach ($clinics as $clinic)<option value="{{ $clinic->id }}" @selected(($filters['clinic_id'] ?? null) == $clinic->id)>{{ $clinic->name }}</option>@endforeach
            </select>
        </div>
        <div>
            <label for="ambulance_type_id" class="form-label">Jenis</label>
            <select id="ambulance_type_id" name="ambulance_type_id" class="form-input">
                <option value="">Semua jenis</option>
                @foreach ($ambulanceTypes as $type)<option value="{{ $type->id }}" @selected(($filters['ambulance_type_id'] ?? null) == $type->id)>{{ $type->name }}</option>@endforeach
            </select>
        </div>
        <div>
            <label for="status" class="form-label">Status</label>
            <select id="status" name="status" class="form-input">
                <option value="">Semua status</option>
                @foreach ($statuses as $status)<option value="{{ $status->value }}" @selected(($filters['status'] ?? null) === $status->value)>{{ $status->label() }}</option>@endforeach
            </select>
        </div>
    </x-admin.filter-bar>

    <div class="card overflow-hidden">
        @if ($ambulances->isEmpty())
            <x-admin.empty-state icon="truck-medical" title="Belum ada ambulans yang cocok" />
        @else
            <div class="relative overflow-x-auto">
                <table class="data-table">
                    <thead><tr><th>Nomor polisi</th><th>Kendaraan</th><th>Jenis</th><th>Klinik</th><th>Status</th><th>Pemakaian</th><th><span class="sr-only">Aksi</span></th></tr></thead>
                    <tbody>
                        @foreach ($ambulances as $ambulance)
                            <tr class="hover:bg-stone-50">
                                <td class="tabular font-semibold whitespace-nowrap">{{ $ambulance->plate_number }}</td>
                                <td>
                                    <div>{{ $ambulance->vehicle_name ?? '-' }}</div>
                                    <div class="text-xs text-stone-600">{{ $ambulance->year ?? 'Tahun tidak diisi' }}</div>
                                </td>
                                <td class="whitespace-nowrap">{{ $ambulance->ambulanceType->name }}</td>
                                <td class="whitespace-nowrap">{{ $ambulance->clinic->name }}</td>
                                <td>
                                    <form method="POST" action="{{ route('admin.ambulances.status', $ambulance) }}" x-data class="flex items-center gap-2">
                                        @csrf
                                        @method('PATCH')
                                        <x-admin.badge :tone="$ambulance->status->tone()">{{ $ambulance->status->label() }}</x-admin.badge>
                                        <label class="sr-only" for="status-{{ $ambulance->id }}">Ubah status {{ $ambulance->plate_number }}</label>
                                        <select id="status-{{ $ambulance->id }}" name="status" class="form-input min-h-8 w-auto py-0 text-xs" @change="$el.form.submit()" @disabled($ambulance->in_use)
                                                @if ($ambulance->in_use) title="Sedang dipakai shift aktif" @endif>
                                            @foreach ($statuses as $status)<option value="{{ $status->value }}" @selected($ambulance->status === $status)>{{ $status->label() }}</option>@endforeach
                                        </select>
                                        <noscript><button type="submit" class="btn-secondary min-h-8 text-xs">Ubah</button></noscript>
                                    </form>
                                </td>
                                <td>
                                    @if ($ambulance->in_use)
                                        <x-admin.badge tone="blue" icon="user">Sedang dipakai</x-admin.badge>
                                        <div class="mt-1 text-xs text-stone-700">{{ $ambulance->openShift->driver->name }}</div>
                                    @else
                                        <span class="text-xs text-stone-600">Tidak dipakai</span>
                                    @endif
                                </td>
                                <td>
                                    <div class="flex justify-end gap-1">
                                        <a href="{{ route('admin.ambulances.edit', $ambulance) }}" class="btn-ghost min-h-9 px-2.5 text-xs">Edit</a>
                                        <x-admin.delete-button :url="route('admin.ambulances.destroy', $ambulance)" :name="$ambulance->plate_number" title="Hapus ambulans"
                                            description="Ambulans yang sudah punya riwayat shift atau laporan tidak bisa dihapus. Untuk armada yang tidak dipakai lagi, ubah status menjadi nonaktif." />
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            <div class="border-t border-stone-100 px-4 py-3">{{ $ambulances->links() }}</div>
        @endif
    </div>
</x-admin.layout>
