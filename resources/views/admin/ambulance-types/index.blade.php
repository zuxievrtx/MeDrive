<x-admin.layout title="Jenis ambulans" :breadcrumbs="['Manajemen Armada' => route('admin.drivers.index')]">
    <x-admin.page-header title="Jenis ambulans" description="Kode jenis dipakai aturan broadcast sehingga tidak bisa diubah. Jenis laporan yang dilayani diatur di Master Jenis Laporan." />

    <div class="card overflow-hidden">
        @if ($ambulanceTypes->isEmpty())
            <x-admin.empty-state icon="tags" title="Belum ada jenis ambulans" />
        @else
            <div class="relative overflow-x-auto">
                <table class="data-table">
                    <thead><tr><th>Kode</th><th>Nama</th><th>Deskripsi</th><th>Melayani laporan</th><th>Armada</th><th><span class="sr-only">Aksi</span></th></tr></thead>
                    <tbody>
                        @foreach ($ambulanceTypes as $type)
                            <tr>
                                <td class="tabular text-xs font-semibold whitespace-nowrap text-stone-700">{{ $type->code }}</td>
                                <td class="font-medium whitespace-nowrap"><i class="fa-solid fa-{{ $type->mapIcon() }} mr-1.5 text-stone-500" aria-hidden="true"></i>{{ $type->name }}</td>
                                <td class="text-stone-700">{{ $type->description ?? '-' }}</td>
                                <td>
                                    <div class="flex flex-wrap gap-1">
                                        @forelse ($type->reportTypes as $reportType)
                                            <x-admin.type-badge :type="$reportType" />
                                        @empty
                                            <span class="text-xs text-stone-600">Belum melayani jenis apa pun</span>
                                        @endforelse
                                    </div>
                                </td>
                                <td><a href="{{ route('admin.ambulances.index', ['ambulance_type_id' => $type->id]) }}" class="tabular font-semibold hover:text-mr-700">{{ $type->ambulances_count }}</a></td>
                                <td><a href="{{ route('admin.ambulance-types.edit', $type) }}" class="btn-ghost min-h-9 px-2.5 text-xs">Edit</a></td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        @endif
    </div>
</x-admin.layout>
