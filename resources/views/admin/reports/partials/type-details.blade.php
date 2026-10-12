@php use App\Support\Label; @endphp
@if ($detail = $report->accidentDetail)
    <section class="card p-5">
        <h2 class="mb-3 font-semibold">Detail kecelakaan</h2>
        <dl class="grid gap-3 text-sm sm:grid-cols-3">
            <div><dt class="text-stone-600">Jenis kecelakaan</dt><dd class="font-medium">{{ Label::humanize($detail->accident_type) }}</dd></div>
            <div><dt class="text-stone-600">Perkiraan korban</dt><dd class="tabular font-medium">{{ $detail->estimated_victim_count }} orang</dd></div>
            <div><dt class="text-stone-600">Kondisi lokasi</dt>
                <dd class="flex flex-wrap gap-1.5">
                    @if ($detail->has_trapped_victim)<x-admin.badge tone="red">Ada korban terjepit</x-admin.badge>@endif
                    @if ($detail->has_fire_hazard)<x-admin.badge tone="red">Potensi api</x-admin.badge>@endif
                    @if ($detail->is_road_blocked)<x-admin.badge tone="amber">Jalan tertutup</x-admin.badge>@endif
                    @if (! $detail->has_trapped_victim && ! $detail->has_fire_hazard && ! $detail->is_road_blocked)<span>Tidak ada catatan bahaya</span>@endif
                </dd>
            </div>
        </dl>
    </section>
@elseif ($detail = $report->medicalDetail)
    <section class="card p-5">
        <h2 class="mb-3 font-semibold">Detail medis darurat</h2>
        <dl class="grid gap-3 text-sm sm:grid-cols-3">
            <div><dt class="text-stone-600">Kategori</dt><dd class="font-medium">{{ Label::humanize($detail->medical_category) }}</dd></div>
            <div><dt class="text-stone-600">Gejala mulai</dt><dd class="tabular font-medium">{{ $detail->symptom_onset_at?->translatedFormat('j M Y H:i') ?? 'Tidak diketahui' }}</dd></div>
            <div><dt class="text-stone-600">Riwayat penyakit</dt><dd class="font-medium">{{ $detail->has_medical_history ? ($detail->medical_history_notes ?: 'Ada') : 'Tidak ada' }}</dd></div>
        </dl>
    </section>
@elseif ($detail = $report->maternityDetail)
    <section class="card p-5">
        <h2 class="mb-3 font-semibold">Detail ibu hamil</h2>
        <dl class="grid gap-3 text-sm sm:grid-cols-3">
            <div><dt class="text-stone-600">Usia kehamilan</dt><dd class="tabular font-medium">{{ $detail->gestational_age_weeks ? $detail->gestational_age_weeks.' minggu' : '-' }}</dd></div>
            <div><dt class="text-stone-600">Jarak kontraksi</dt><dd class="tabular font-medium">{{ $detail->contraction_interval_minutes ? 'tiap '.$detail->contraction_interval_minutes.' menit' : '-' }}</dd></div>
            <div><dt class="text-stone-600">Kehamilan ke-</dt><dd class="tabular font-medium">{{ $detail->pregnancy_number ?? '-' }}</dd></div>
            <div><dt class="text-stone-600">Ketuban / perdarahan</dt>
                <dd class="flex flex-wrap gap-1.5">
                    <x-admin.badge :tone="$detail->is_water_broken ? 'amber' : 'gray'">Ketuban {{ $detail->is_water_broken ? 'pecah' : 'belum pecah' }}</x-admin.badge>
                    <x-admin.badge :tone="$detail->has_bleeding ? 'red' : 'gray'">{{ $detail->has_bleeding ? 'Ada perdarahan' : 'Tidak ada perdarahan' }}</x-admin.badge>
                </dd>
            </div>
            <div class="sm:col-span-2"><dt class="text-stone-600">Faskes tujuan</dt><dd class="font-medium">{{ $detail->destinationClinic?->name ?? $report->destination_name ?? '-' }}</dd></div>
        </dl>
    </section>
@elseif ($detail = $report->funeralDetail)
    <section class="card p-5">
        <h2 class="mb-3 font-semibold">Detail pengantaran jenazah</h2>
        <dl class="grid gap-3 text-sm sm:grid-cols-3">
            <div><dt class="text-stone-600">Nama almarhum/almarhumah</dt><dd class="font-medium">{{ $detail->deceased_name }}</dd></div>
            <div><dt class="text-stone-600">Tempat jemput</dt><dd class="font-medium">{{ Label::humanize($detail->pickup_place_type) }}</dd></div>
            <div><dt class="text-stone-600">Jadwal jemput</dt><dd class="tabular font-medium">{{ $detail->scheduled_pickup_at?->translatedFormat('j M Y H:i') ?? 'Segera' }}</dd></div>
            <div><dt class="text-stone-600">Surat kematian</dt><dd class="font-medium">{{ $detail->has_death_certificate ? 'Ada' : 'Belum ada' }}</dd></div>
            <div class="sm:col-span-2"><dt class="text-stone-600">Kontak keluarga</dt><dd class="font-medium">{{ $detail->family_contact_name }} · <a href="tel:{{ $detail->family_contact_phone }}" class="hover:text-mr-700">{{ $detail->family_contact_phone }}</a></dd></div>
        </dl>
    </section>
@else
    <section class="card p-5">
        <h2 class="font-semibold">Detail khusus jenis laporan</h2>
        <p class="mt-1 text-sm text-stone-600">Pelapor belum mengisi detail tambahan untuk laporan ini.</p>
    </section>
@endif
