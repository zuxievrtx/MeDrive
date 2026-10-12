@php
    use App\Support\Label;
    $type = $report->reportType;
    $driver = $report->driver;
    $mapData = [
        'pickup' => ['lat' => (float) $report->latitude, 'lng' => (float) $report->longitude],
        'destination' => $report->destination_lat !== null ? ['lat' => (float) $report->destination_lat, 'lng' => (float) $report->destination_lng, 'name' => $report->destination_name] : null,
        'driver' => $driver?->lastLocation ? [
            'lat' => (float) $driver->lastLocation->latitude,
            'lng' => (float) $driver->lastLocation->longitude,
            'heading' => $driver->lastLocation->heading,
            'recorded_at' => $driver->lastLocation->recorded_at->toIso8601String(),
            'is_on_duty' => true,
            'icon' => $report->ambulance?->ambulanceType->mapIcon(),
            'name' => $driver->name,
            'plate_number' => $report->ambulance?->plate_number,
        ] : null,
        'typeColor' => $type->color,
    ];
@endphp
<x-admin.layout :title="$report->code" :breadcrumbs="['Daftar laporan' => route('admin.reports.index')]">
    <div class="grid gap-6 xl:grid-cols-[minmax(0,3fr)_minmax(0,2fr)]">
        {{-- KIRI: isi laporan --}}
        <div class="min-w-0 space-y-6">
            <section class="card p-5">
                <div class="flex flex-wrap items-start justify-between gap-4">
                    <div>
                        <p class="text-sm text-stone-600">Laporan darurat</p>
                        <h1 class="tabular text-3xl font-bold tracking-tight">{{ $report->code }}</h1>
                        <div class="mt-2 flex flex-wrap items-center gap-2">
                            <x-admin.type-badge :type="$type" />
                            <x-admin.badge :tone="$type->priority === 1 ? 'red' : 'gray'">Prioritas {{ $type->priority }}</x-admin.badge>
                        </div>
                    </div>
                    <div class="text-right">
                        <x-admin.status-badge :status="$report->status" class="px-3 py-1.5 text-sm" />
                        <p class="mt-2 text-xs text-stone-600">Dibuat {{ $report->created_at->translatedFormat('j F Y H:i') }}</p>
                        @if ($report->response_time_minutes !== null)
                            <p class="text-xs text-stone-600">Diambil dalam <span class="tabular font-semibold text-stone-900">{{ $report->response_time_minutes }} menit</span></p>
                        @endif
                    </div>
                </div>
                <div class="mt-5 rounded-lg bg-stone-50 p-4">
                    <h2 class="text-xs font-semibold text-stone-600">Deskripsi dari pelapor</h2>
                    <p class="mt-1 text-sm whitespace-pre-line">{{ $report->description }}</p>
                </div>
                <dl class="mt-4 grid gap-3 text-sm sm:grid-cols-2">
                    <div><dt class="text-stone-600">Lokasi jemput</dt><dd>{{ $report->address ?? '-' }}<span class="tabular block text-xs text-stone-600">{{ $report->latitude }}, {{ $report->longitude }}</span></dd></div>
                    @if ($report->destination_name || $report->destination_address)
                        <div><dt class="text-stone-600">Tujuan antar</dt><dd>{{ $report->destination_name }}<span class="block text-xs text-stone-600">{{ $report->destination_address }}</span></dd></div>
                    @endif
                </dl>
            </section>

            <section class="card p-5" aria-labelledby="timeline-title">
                <h2 id="timeline-title" class="mb-4 font-semibold">Riwayat status</h2>
                @if ($report->statusLogs->isEmpty())
                    <p class="text-sm text-stone-600">Belum ada riwayat status.</p>
                @else
                    <ol class="relative space-y-5 border-l-2 border-stone-200 pl-6">
                        @foreach ($report->statusLogs as $log)
                            <li class="relative">
                                <span class="absolute top-1 -left-[1.95rem] size-3.5 rounded-full border-2 border-white ring-2 {{ $loop->last ? 'bg-mr-600 ring-mr-300' : 'bg-stone-400 ring-stone-200' }}"></span>
                                <div class="flex flex-wrap items-center gap-2">
                                    @if ($log->from_status)
                                        <x-admin.status-badge :status="$log->from_status" />
                                        <i class="fa-solid fa-arrow-right text-xs text-stone-500" aria-label="menjadi"></i>
                                    @endif
                                    <x-admin.status-badge :status="$log->to_status" />
                                    <span class="tabular text-xs text-stone-600">{{ $log->created_at->translatedFormat('j M Y H:i:s') }}</span>
                                </div>
                                <p class="mt-1 text-sm">
                                    oleh <span class="font-medium">{{ $log->changer?->name ?? 'Sistem' }}</span>
                                    @if ($log->changer)<span class="text-xs text-stone-600">({{ $log->changer->role->label() }})</span>@endif
                                </p>
                                @if ($log->note)<p class="text-sm text-stone-700">{{ $log->note }}</p>@endif
                            </li>
                        @endforeach
                    </ol>
                @endif
            </section>

            @include('admin.reports.partials.type-details')

            <section class="card overflow-hidden" aria-labelledby="patients-title">
                <h2 id="patients-title" class="border-b border-stone-100 px-5 py-3 font-semibold">Pasien</h2>
                @if ($report->patients->isEmpty())
                    <x-admin.empty-state icon="user-injured" title="Belum ada data pasien" description="Data pasien diisi pelapor atau driver dari aplikasi." />
                @else
                    <div class="relative overflow-x-auto">
                        <table class="data-table">
                            <thead><tr><th>Nama</th><th>L/P</th><th>Usia</th><th>Kesadaran</th><th>Bernapas</th><th>Kondisi</th><th>Diserahkan ke</th></tr></thead>
                            <tbody>
                                @foreach ($report->patients as $patient)
                                    <tr>
                                        <td>{{ $patient->name ?? 'Tanpa nama' }}</td>
                                        <td>{{ $patient->gender ?? '-' }}</td>
                                        <td class="tabular">{{ $patient->age_estimate ? '± '.$patient->age_estimate.' th' : '-' }}</td>
                                        <td>{{ Label::humanize($patient->consciousness) }}</td>
                                        <td>{{ Label::yesNo($patient->is_breathing) }}</td>
                                        <td class="min-w-40">{{ $patient->condition_note ?? '-' }}</td>
                                        <td class="min-w-40">{{ $patient->handed_over_to ?? '-' }}@if ($patient->handed_over_at)<span class="tabular block text-xs text-stone-600">{{ $patient->handed_over_at->translatedFormat('j M H:i') }}</span>@endif</td>
                                    </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                @endif
            </section>

            @include('admin.reports.partials.attachments')

            <section class="card p-5" aria-labelledby="reporter-title">
                <h2 id="reporter-title" class="mb-3 font-semibold">Pelapor</h2>
                <div class="flex items-center gap-3">
                    <x-admin.avatar :user="$report->reporter" />
                    <div class="min-w-0">
                        <a href="{{ route('admin.users.show', $report->reporter) }}" class="font-semibold hover:text-mr-700">{{ $report->reporter->name }}</a>
                        <p class="text-sm text-stone-600">
                            <a href="tel:{{ $report->reporter->phone }}" class="hover:text-mr-700">{{ $report->reporter->phone }}</a> · {{ $report->reporter->email }}
                        </p>
                        <p class="text-xs text-stone-600">{{ $report->reporter->devices->count() }} perangkat terdaftar, akun {{ mb_strtolower($report->reporter->account_status->label()) }}</p>
                    </div>
                </div>
            </section>
        </div>

        {{-- KANAN: lokasi, armada, dispatch, aksi --}}
        <div class="min-w-0 space-y-6">
            <section class="card overflow-hidden" x-data="reportMap(@js($mapData))" aria-label="Peta lokasi laporan">
                <div class="relative h-80">
                    <div x-ref="map" class="absolute inset-0 z-0"></div>
                    <p x-show="error" x-cloak class="absolute inset-0 z-10 grid place-items-center bg-white text-sm text-mr-700" x-text="error"></p>
                </div>
                <div class="flex flex-wrap gap-x-4 gap-y-1 px-5 py-2.5 text-xs text-stone-600">
                    <span><i class="fa-solid fa-location-dot mr-1" style="color: {{ $type->color }}" aria-hidden="true"></i>Lokasi jemput</span>
                    @if ($mapData['destination'])<span><i class="fa-solid fa-flag-checkered mr-1 text-stone-900" aria-hidden="true"></i>Tujuan</span>@endif
                    @if ($mapData['driver'])<span><i class="fa-solid fa-truck-medical mr-1 text-mr-600" aria-hidden="true"></i>Posisi terakhir driver</span>@endif
                </div>
            </section>

            <section class="card p-5" aria-labelledby="fleet-title">
                <h2 id="fleet-title" class="mb-3 font-semibold">Driver dan ambulans</h2>
                @if ($driver)
                    <div class="flex items-center gap-3">
                        <x-admin.avatar :user="$driver" size="lg" :photo-url="$driver->driverProfile?->photo_path ? route('admin.drivers.photo', $driver) : null" />
                        <div class="min-w-0">
                            <a href="{{ route('admin.drivers.show', $driver) }}" class="font-semibold hover:text-mr-700">{{ $driver->name }}</a>
                            <p class="text-sm text-stone-600">{{ $driver->driverProfile?->clinic->name }}</p>
                            <a href="tel:{{ $driver->phone }}" class="text-sm text-stone-600 hover:text-mr-700">{{ $driver->phone }}</a>
                        </div>
                    </div>
                    @if ($report->ambulance)
                        <dl class="mt-4 grid grid-cols-2 gap-3 rounded-lg bg-stone-50 p-3 text-sm">
                            <div><dt class="text-xs text-stone-600">Nomor polisi</dt><dd class="tabular font-semibold">{{ $report->ambulance->plate_number }}</dd></div>
                            <div><dt class="text-xs text-stone-600">Jenis</dt><dd>{{ $report->ambulance->ambulanceType->name }}</dd></div>
                            <div><dt class="text-xs text-stone-600">Kendaraan</dt><dd>{{ $report->ambulance->vehicle_name ?? '-' }}</dd></div>
                            <div><dt class="text-xs text-stone-600">Klinik armada</dt><dd>{{ $report->ambulance->clinic->name }}</dd></div>
                        </dl>
                    @endif
                    @if ($driver->lastLocation)
                        <p class="mt-3 text-xs text-stone-600">
                            Posisi terakhir {{ $driver->lastLocation->recorded_at->diffForHumans() }},
                            {{ $driver->lastLocation->speed_kmh ?? 0 }} km/j.
                        </p>
                    @endif
                @else
                    <p class="text-sm text-stone-600">Belum ada driver yang mengambil laporan ini.</p>
                @endif
            </section>

            <section class="card overflow-hidden" aria-labelledby="dispatch-title">
                <div class="border-b border-stone-100 px-5 py-3">
                    <h2 id="dispatch-title" class="font-semibold">Broadcast ke driver</h2>
                    <p class="text-xs text-stone-600">Dikirim ke driver shift aktif yang tidak bertugas dengan jenis ambulans: {{ $type->ambulanceTypes->pluck('name')->implode(', ') ?: '-' }}.</p>
                </div>
                @if ($report->dispatches->isEmpty())
                    <x-admin.empty-state icon="tower-broadcast" title="Belum ada broadcast tercatat" />
                @else
                    <ul class="divide-y divide-stone-100">
                        @foreach ($report->dispatches as $dispatch)
                            <li class="flex flex-wrap items-center justify-between gap-2 px-5 py-3">
                                <div class="min-w-0">
                                    <p class="text-sm font-medium">{{ $dispatch->driver->name }} <span class="tabular text-xs text-stone-600">({{ $dispatch->shift?->ambulance?->plate_number }})</span></p>
                                    <p class="tabular text-xs text-stone-600">
                                        {{ number_format((float) $dispatch->distance_km, 2, ',', '.') }} km ·
                                        kirim {{ $dispatch->sent_at->format('H:i:s') }} ·
                                        dibuka {{ $dispatch->opened_at?->format('H:i:s') ?? 'belum' }}
                                    </p>
                                </div>
                                <x-admin.badge :tone="$dispatch->response->tone()">{{ $dispatch->response->label() }}</x-admin.badge>
                            </li>
                        @endforeach
                    </ul>
                @endif
            </section>

            <section class="card space-y-3 p-5" x-data="{ cancelOpen: @js($errors->has('reason')) }" aria-labelledby="actions-title">
                <h2 id="actions-title" class="font-semibold">Aksi admin</h2>
                @can('cancel', $report)
                    <button type="button" class="btn-danger w-full" @click="cancelOpen = true"><i class="fa-solid fa-ban" aria-hidden="true"></i> Batalkan laporan</button>
                    <p class="text-xs text-stone-600">Hanya untuk laporan yang belum diambil driver, mis. laporan ganda atau palsu.</p>
                @else
                    <span class="block" tabindex="0" title="Laporan yang sudah diambil driver atau sudah ditutup tidak bisa dibatalkan admin."
                          aria-describedby="cancel-hint">
                        <button type="button" class="btn-danger w-full" disabled><i class="fa-solid fa-ban" aria-hidden="true"></i> Batalkan laporan</button>
                    </span>
                    <p id="cancel-hint" class="text-xs text-stone-600">Tidak tersedia: laporan berstatus {{ mb_strtolower($report->status->label()) }}. Pembatalan hanya untuk laporan yang masih menunggu.</p>
                @endcan
                <a href="{{ route('admin.location-logs.index', array_filter(['driver_id' => $report->driver_id, 'report_id' => $report->id])) }}"
                   @class(['btn-secondary w-full', 'pointer-events-none opacity-50' => ! $report->driver_id])
                   @if (! $report->driver_id) aria-disabled="true" tabindex="-1" @endif>
                    <i class="fa-solid fa-route" aria-hidden="true"></i> Lihat rute di Log Lokasi
                </a>

                @can('cancel', $report)
                    <x-admin.modal show="cancelOpen" title="Batalkan {{ $report->code }}">
                        <form method="POST" action="{{ route('admin.reports.cancel', $report) }}" class="space-y-4">
                            @csrf
                            <p class="text-sm text-stone-700">Status berubah menjadi <strong>dibatalkan</strong> dan tercatat di riwayat status atas nama Anda. Bila driver sudah mengambil laporan lebih dulu, pembatalan otomatis ditolak.</p>
                            <x-admin.field name="reason" label="Alasan pembatalan" required>
                                <textarea id="reason" name="reason" rows="3" minlength="5" maxlength="255" required class="form-input py-2" placeholder="Mis. laporan ganda dengan MDR-...">{{ old('reason') }}</textarea>
                            </x-admin.field>
                            <div class="flex justify-end gap-2">
                                <button type="button" class="btn-secondary" @click="cancelOpen = false">Kembali</button>
                                <button type="submit" class="btn-danger">Batalkan laporan</button>
                            </div>
                        </form>
                    </x-admin.modal>
                @endcan
            </section>
        </div>
    </div>
</x-admin.layout>
