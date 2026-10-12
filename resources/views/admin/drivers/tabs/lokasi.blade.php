@php
    $location = $driver->lastLocation;
    $point = $location ? [
        'lat' => (float) $location->latitude,
        'lng' => (float) $location->longitude,
        'heading' => $location->heading,
        'is_on_duty' => $profile->is_on_duty,
        'recorded_at' => $location->recorded_at->toIso8601String(),
        'icon' => $driver->openShift?->ambulance->ambulanceType->mapIcon() ?? config('medrive.ambulance_type_icons.default'),
        'name' => $driver->name,
    ] : null;
@endphp
<div class="grid gap-6 lg:grid-cols-[minmax(0,2fr)_minmax(0,1fr)]">
    <section class="card overflow-hidden" x-data="pointMap({ point: @js($point) })">
        <div class="relative h-96">
            @if ($point)
                <div x-ref="map" class="absolute inset-0 z-0"></div>
                <div x-show="error" x-cloak class="absolute inset-0 grid place-items-center bg-white text-sm text-mr-700" x-text="error"></div>
            @else
                <x-admin.empty-state icon="location-crosshairs" title="Belum ada data lokasi" description="Posisi terakhir tercatat setelah driver membuka shift dan aplikasi mengirim lokasi." class="h-full" />
            @endif
        </div>
    </section>

    <section class="card p-5">
        <h2 class="mb-4 font-semibold">Posisi terakhir</h2>
        @if ($location)
            <dl class="grid grid-cols-[minmax(0,8rem)_minmax(0,1fr)] gap-x-4 gap-y-3 text-sm">
                <dt class="text-stone-600">Koordinat</dt><dd class="tabular">{{ number_format((float) $location->latitude, 6) }}, {{ number_format((float) $location->longitude, 6) }}</dd>
                <dt class="text-stone-600">Kecepatan</dt><dd class="tabular">{{ $location->speed_kmh ?? '-' }} km/j</dd>
                <dt class="text-stone-600">Arah</dt><dd class="tabular">{{ $location->heading !== null ? $location->heading.'°' : '-' }}</dd>
                <dt class="text-stone-600">Akurasi</dt><dd class="tabular">{{ $location->accuracy_m !== null ? $location->accuracy_m.' m' : '-' }}</dd>
                <dt class="text-stone-600">Baterai</dt><dd class="text-stone-600">Dikirim lewat ping realtime, lihat Peta Live</dd>
                <dt class="text-stone-600">Waktu</dt><dd>{{ $location->recorded_at->translatedFormat('j M Y H:i:s') }} <span class="text-stone-600">({{ $location->recorded_at->diffForHumans() }})</span></dd>
                <dt class="text-stone-600">Shift</dt><dd>{{ $location->shift_id ? '#'.$location->shift_id : 'Di luar shift' }}</dd>
            </dl>
        @else
            <p class="text-sm text-stone-600">Belum ada data.</p>
        @endif
        <a href="{{ route('admin.location-logs.index', ['driver_id' => $driver->id]) }}" class="btn-secondary mt-5 w-full"><i class="fa-solid fa-route" aria-hidden="true"></i> Lihat Log Lokasi driver ini</a>
    </section>
</div>
