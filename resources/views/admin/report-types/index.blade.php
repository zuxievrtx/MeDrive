<x-admin.layout title="Master jenis laporan">
    <x-admin.page-header title="Master jenis laporan" description="Aturan tiap jenis laporan, termasuk jenis ambulans yang menerima broadcast. Warna dan ikon di sini dipakai di seluruh dashboard." />

    <div class="card overflow-hidden">
        @if ($reportTypes->isEmpty())
            <x-admin.empty-state icon="list-check" title="Belum ada jenis laporan" />
        @else
            <div class="relative overflow-x-auto">
                <table class="data-table">
                    <thead><tr><th>Urutan</th><th>Jenis</th><th>Warna</th><th>Prioritas</th><th>Darurat</th><th>Wajib tujuan</th><th>Dilayani ambulans</th><th>Laporan</th><th>Status</th><th><span class="sr-only">Aksi</span></th></tr></thead>
                    <tbody>
                        @foreach ($reportTypes as $type)
                            <tr>
                                <td class="tabular">{{ $type->sort_order }}</td>
                                <td>
                                    <x-admin.type-badge :type="$type" />
                                    <div class="mt-1 max-w-xs text-xs text-stone-600">{{ $type->description }}</div>
                                </td>
                                <td><span class="tabular inline-flex items-center gap-2 text-xs"><span class="size-5 rounded border border-stone-300" style="background: {{ $type->color ?? '#57534e' }}"></span>{{ $type->color ?? '-' }}</span></td>
                                <td><x-admin.badge :tone="$type->priority === 1 ? 'red' : 'gray'">P{{ $type->priority }}</x-admin.badge></td>
                                <td>{{ $type->is_emergency ? 'Ya' : 'Tidak, bisa dijadwalkan' }}</td>
                                <td>{{ $type->requires_destination ? 'Ya' : 'Tidak' }}</td>
                                <td>
                                    <ul class="space-y-0.5 text-xs">
                                        @forelse ($type->ambulanceTypes as $ambulanceType)
                                            <li class="whitespace-nowrap">{{ $ambulanceType->name }}</li>
                                        @empty
                                            <li class="font-semibold text-mr-700">Belum ada penerima</li>
                                        @endforelse
                                    </ul>
                                </td>
                                <td class="tabular">{{ $type->reports_count }}</td>
                                <td><x-admin.active-badge :active="$type->is_active" /></td>
                                <td><a href="{{ route('admin.report-types.edit', $type) }}" class="btn-ghost min-h-9 px-2.5 text-xs">Edit</a></td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        @endif
    </div>
</x-admin.layout>
