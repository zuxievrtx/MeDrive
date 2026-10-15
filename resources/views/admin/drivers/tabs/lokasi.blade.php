<div class="grid gap-6 lg:grid-cols-[minmax(0,2fr)_minmax(0,1fr)]">
    <section class="card overflow-hidden"
             x-data="pointMap({ point: driver.last_location ? { lat: driver.last_location.latitude, lng: driver.last_location.longitude, heading: driver.last_location.heading, is_on_duty: profile.is_on_duty, recorded_at: driver.last_location.recorded_at, icon: driver.open_shift?.ambulance?.ambulance_type?.map_icon ?? 'truck-medical', name: driver.name } : null })">
        <div class="relative h-96">
            <div x-ref="map" class="absolute inset-0 z-0"></div>
            <div x-show="error" x-cloak class="absolute inset-0 grid place-items-center bg-white text-sm text-mr-700" x-text="error"></div>
            <template x-if="!driver.last_location">
                <x-admin.empty-state icon="location-crosshairs" title="Belum ada data lokasi" description="Posisi terakhir tercatat setelah driver membuka shift dan aplikasi mengirim lokasi." class="absolute inset-0 z-10 h-full bg-white" />
            </template>
        </div>
    </section>

    <section class="card p-5">
        <h2 class="mb-4 font-semibold">Posisi terakhir</h2>
        <template x-if="driver.last_location">
            <dl class="grid grid-cols-[minmax(0,8rem)_minmax(0,1fr)] gap-x-4 gap-y-3 text-sm">
                <dt class="text-stone-600">Koordinat</dt><dd class="tabular" x-text="`${driver.last_location.latitude.toFixed(6)}, ${driver.last_location.longitude.toFixed(6)}`"></dd>
                <dt class="text-stone-600">Kecepatan</dt><dd class="tabular" x-text="`${driver.last_location.speed_kmh ?? '-'} km/j`"></dd>
                <dt class="text-stone-600">Arah</dt><dd class="tabular" x-text="driver.last_location.heading !== null ? `${driver.last_location.heading}°` : '-'"></dd>
                <dt class="text-stone-600">Akurasi</dt><dd class="tabular" x-text="driver.last_location.accuracy_m !== null ? `${driver.last_location.accuracy_m} m` : '-'"></dd>
                <dt class="text-stone-600">Baterai</dt>
                <dd class="tabular" :class="driver.last_location.battery_level !== null && driver.last_location.battery_level < 20 ? 'font-semibold text-mr-700' : ''"
                    x-text="driver.last_location.battery_level !== null ? `${driver.last_location.battery_level}%` : 'Belum dikirim'"></dd>
                <dt class="text-stone-600">GPS palsu</dt>
                <dd><span x-show="driver.last_location.is_mock_location"><x-admin.badge tone="red" icon="triangle-exclamation">Terdeteksi</x-admin.badge></span><span x-show="!driver.last_location.is_mock_location">Tidak</span></dd>
                <dt class="text-stone-600">Waktu</dt><dd><span x-text="window.formatDate(driver.last_location.recorded_at)"></span> <span class="text-stone-600" x-text="`(${window.timeAgo(driver.last_location.recorded_at)})`"></span></dd>
            </dl>
        </template>
        <p x-show="!driver.last_location" class="text-sm text-stone-600">Belum ada data.</p>
        <a href="{{ route('admin.location-logs.index', ['driver_id' => $driverId]) }}" class="btn-secondary mt-5 w-full"><i class="fa-solid fa-route" aria-hidden="true"></i> Lihat Log Lokasi driver ini</a>
    </section>
</div>
