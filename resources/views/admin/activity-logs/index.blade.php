@php
    $moduleLabels = ['driver' => 'Driver', 'certification' => 'Sertifikat', 'shift' => 'Shift', 'ambulance' => 'Ambulans', 'ambulance_type' => 'Jenis ambulans',
        'institution' => 'Instansi', 'clinic' => 'Klinik', 'report' => 'Laporan', 'report_type' => 'Jenis laporan', 'reporter' => 'Pelapor', 'admin' => 'Admin'];
    $verbTones = ['created' => 'green', 'updated' => 'blue', 'status_changed' => 'violet', 'deleted' => 'red', 'deactivated' => 'gray', 'activated' => 'teal', 'cancelled' => 'amber', 'ended' => 'amber'];
@endphp
<x-admin.layout title="Log aktivitas admin" :breadcrumbs="['Sistem' => route('admin.activity-logs.index')]">
    <x-admin.page-header title="Log aktivitas admin" description="Jejak semua aksi tulis di dashboard admin. Hanya bisa dibaca, tidak bisa diubah atau dihapus." />

    <x-admin.filter-bar :action="route('admin.activity-logs.index')" :reset-url="route('admin.activity-logs.index')">
        <div>
            <label for="admin_id" class="form-label">Admin</label>
            <select id="admin_id" name="admin_id" class="form-input">
                <option value="">Semua admin</option>
                @foreach ($admins as $admin)<option value="{{ $admin->id }}" @selected(($filters['admin_id'] ?? null) == $admin->id)>{{ $admin->name }}</option>@endforeach
            </select>
        </div>
        <div>
            <label for="module" class="form-label">Kategori aksi</label>
            <select id="module" name="module" class="form-input">
                <option value="">Semua kategori</option>
                @foreach ($modules as $module)<option value="{{ $module }}" @selected(($filters['module'] ?? null) === $module)>{{ $moduleLabels[$module] ?? $module }}</option>@endforeach
            </select>
        </div>
        <div>
            <label for="from" class="form-label">Dari tanggal</label>
            <input id="from" name="from" type="date" value="{{ $filters['from'] ?? '' }}" class="form-input">
        </div>
        <div>
            <label for="to" class="form-label">Sampai tanggal</label>
            <input id="to" name="to" type="date" value="{{ $filters['to'] ?? '' }}" class="form-input">
        </div>
    </x-admin.filter-bar>

    <div class="card overflow-hidden">
        @if ($logs->isEmpty())
            <x-admin.empty-state icon="clock-rotate-left" title="Belum ada aktivitas yang cocok" />
        @else
            <div class="relative overflow-x-auto">
                <table class="data-table">
                    <thead><tr><th>Waktu</th><th>Admin</th><th>Aksi</th><th>Objek</th><th>Deskripsi</th><th>IP</th></tr></thead>
                    <tbody>
                        @foreach ($logs as $log)
                            @php [$module, $verb] = array_pad(explode('.', $log->action, 2), 2, ''); @endphp
                            <tr>
                                <td class="tabular whitespace-nowrap" title="{{ $log->created_at->diffForHumans() }}">{{ $log->created_at->translatedFormat('j M Y H:i:s') }}</td>
                                <td class="whitespace-nowrap">{{ $log->admin?->name ?? 'Admin terhapus' }}</td>
                                <td><x-admin.badge :tone="$verbTones[$verb] ?? 'gray'">{{ $log->action }}</x-admin.badge></td>
                                <td class="tabular text-xs whitespace-nowrap text-stone-700">{{ $log->subject_type }}#{{ $log->subject_id }}</td>
                                <td class="min-w-64">{{ $log->description }}</td>
                                <td class="tabular text-xs whitespace-nowrap text-stone-600">{{ $log->ip_address ?? '-' }}</td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            <div class="border-t border-stone-100 px-4 py-3">{{ $logs->links() }}</div>
        @endif
    </div>
</x-admin.layout>
