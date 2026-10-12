<x-admin.layout title="Pengguna pelapor" :breadcrumbs="['Sistem' => route('admin.activity-logs.index')]">
    <x-admin.page-header title="Pengguna pelapor" description="Akun masyarakat yang mendaftar dari aplikasi Pelapor. Admin hanya bisa menonaktifkan atau mengaktifkan kembali." />

    <x-admin.filter-bar :action="route('admin.users.index')" :reset-url="route('admin.users.index')">
        <div>
            <label for="q" class="form-label">Cari</label>
            <input id="q" name="q" type="search" value="{{ $filters['q'] ?? '' }}" placeholder="Nama, email, telepon" class="form-input">
        </div>
        <div>
            <label for="status" class="form-label">Status akun</label>
            <select id="status" name="status" class="form-input">
                <option value="">Semua</option>
                <option value="aktif" @selected(($filters['status'] ?? null) === 'aktif')>Aktif</option>
                <option value="nonaktif" @selected(($filters['status'] ?? null) === 'nonaktif')>Nonaktif</option>
            </select>
        </div>
    </x-admin.filter-bar>

    <div class="card overflow-hidden" x-data="{ toggle: { open: false, url: '', name: '', active: true } }">
        @if ($reporters->isEmpty())
            <x-admin.empty-state icon="users" title="Tidak ada pelapor yang cocok" />
        @else
            <div class="relative overflow-x-auto">
                <table class="data-table">
                    <thead><tr><th>Pelapor</th><th>Email</th><th>Status</th><th>Perangkat</th><th>Laporan dibuat</th><th>Login terakhir</th><th><span class="sr-only">Aksi</span></th></tr></thead>
                    <tbody>
                        @foreach ($reporters as $reporter)
                            <tr class="hover:bg-stone-50">
                                <td>
                                    <div class="flex items-center gap-3">
                                        <x-admin.avatar :user="$reporter" size="sm" />
                                        <div>
                                            <a href="{{ route('admin.users.show', $reporter) }}" class="font-semibold whitespace-nowrap hover:text-mr-700">{{ $reporter->name }}</a>
                                            <div class="text-xs text-stone-600">{{ $reporter->phone }}</div>
                                        </div>
                                    </div>
                                </td>
                                <td class="break-all">{{ $reporter->email }}</td>
                                <td><x-admin.badge :tone="$reporter->account_status->tone()">{{ $reporter->account_status->label() }}</x-admin.badge></td>
                                <td class="whitespace-nowrap">
                                    <span class="tabular font-semibold">{{ $reporter->devices_count }}</span>
                                    @if ($reporter->devices_max_last_seen_at)
                                        <div class="text-xs text-stone-600">aktif {{ \Illuminate\Support\Carbon::parse($reporter->devices_max_last_seen_at)->diffForHumans() }}</div>
                                    @endif
                                </td>
                                <td><a href="{{ route('admin.users.show', $reporter) }}" class="tabular font-semibold hover:text-mr-700">{{ $reporter->reports_made_count }}</a></td>
                                <td class="text-xs whitespace-nowrap text-stone-700">{{ $reporter->last_login_at?->diffForHumans() ?? 'Belum tercatat' }}</td>
                                <td>
                                    <div class="flex justify-end gap-1">
                                        <a href="{{ route('admin.users.show', $reporter) }}" class="btn-ghost min-h-9 px-2.5 text-xs">Detail</a>
                                        <button type="button" class="btn-ghost min-h-9 px-2.5 text-xs"
                                                @click="toggle = { open: true, url: @js(route('admin.users.account-status', $reporter)), name: @js($reporter->name), active: @js($reporter->isActive()) }">
                                            {{ $reporter->isActive() ? 'Nonaktifkan' : 'Aktifkan' }}
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            <div class="border-t border-stone-100 px-4 py-3">{{ $reporters->links() }}</div>
        @endif

        @include('admin.users.partials.toggle-modal')
    </div>
</x-admin.layout>
