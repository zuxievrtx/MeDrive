<section class="card overflow-hidden" x-data="{ endShift: { open: false, url: '' } }">
    <div class="flex flex-wrap items-center justify-between gap-3 border-b border-stone-100 px-5 py-3">
        <h2 class="font-semibold">Riwayat shift</h2>
        @if ($driver->openShift)
            <button type="button" class="btn-danger" @click="endShift = { open: true, url: @js(route('admin.shifts.end', $driver->openShift)) }">
                <i class="fa-solid fa-power-off" aria-hidden="true"></i> Akhiri Shift (Admin)
            </button>
        @endif
    </div>
    @if ($shifts->isEmpty())
        <x-admin.empty-state icon="clock" title="Belum pernah membuka shift" description="Shift dibuka driver dari aplikasi dengan memilih ambulans kliniknya." />
    @else
        <div class="relative overflow-x-auto">
            <table class="data-table">
                <thead><tr><th>Mulai</th><th>Selesai</th><th>Durasi</th><th>Alasan selesai</th><th>Ambulans</th><th>Jenis</th></tr></thead>
                <tbody>
                    @foreach ($shifts as $shift)
                        <tr @class(['bg-green-50/60' => $shift->isOpen()])>
                            <td class="tabular whitespace-nowrap">{{ $shift->started_at->translatedFormat('j M Y H:i') }}</td>
                            <td class="whitespace-nowrap">
                                @if ($shift->isOpen())
                                    <x-admin.badge tone="green" icon="circle">Masih terbuka</x-admin.badge>
                                @else
                                    <span class="tabular">{{ $shift->ended_at->translatedFormat('j M Y H:i') }}</span>
                                @endif
                            </td>
                            <td class="tabular whitespace-nowrap">{{ $shift->started_at->diffForHumans($shift->ended_at ?? now(), syntax: \Carbon\CarbonInterface::DIFF_ABSOLUTE, parts: 2) }}</td>
                            <td>{{ $shift->end_reason?->label() ?? '-' }}</td>
                            <td class="tabular font-medium whitespace-nowrap">{{ $shift->ambulance->plate_number }}</td>
                            <td class="whitespace-nowrap">{{ $shift->ambulance->ambulanceType->name }}</td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
        <div class="border-t border-stone-100 px-4 py-3">{{ $shifts->links() }}</div>
    @endif

    <x-admin.modal show="endShift.open" title="Akhiri shift driver">
        <p class="text-sm text-stone-700">Shift <strong>{{ $driver->name }}</strong> akan ditutup dengan alasan <strong>dihentikan admin</strong>. Driver tidak lagi menerima broadcast laporan sampai membuka shift baru.</p>
        @if ($profile->is_on_duty)
            <div class="mt-3 flex gap-2 rounded-lg border border-amber-300 bg-amber-50 p-3 text-sm text-amber-900">
                <i class="fa-solid fa-triangle-exclamation mt-0.5" aria-hidden="true"></i>
                <p>Driver sedang menangani laporan. Status laporan tidak diubah oleh aksi ini.</p>
            </div>
        @endif
        <form method="POST" :action="endShift.url" class="mt-6 flex justify-end gap-2">
            @csrf
            <button type="button" class="btn-secondary" @click="endShift.open = false">Batal</button>
            <button type="submit" class="btn-danger">Akhiri shift</button>
        </form>
    </x-admin.modal>
</section>
