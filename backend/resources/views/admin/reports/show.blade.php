<x-admin.layout title="Detail laporan" :breadcrumbs="['Daftar laporan' => route('admin.reports.index')]">
    <div x-data="reportDetail({ url: @js(route('api.v1.admin.reports.show', $reportId)), reportId: {{ $reportId }} })">
        <template x-if="loading && !report">
            <div class="grid gap-6 xl:grid-cols-[minmax(0,3fr)_minmax(0,2fr)]" aria-busy="true">
                <div class="card space-y-3 p-5"><div class="skeleton h-5 w-32"></div><div class="skeleton h-9 w-56"></div><div class="skeleton h-24 w-full"></div></div>
                <div class="card h-80 skeleton"></div>
            </div>
        </template>
        <template x-if="!loading && error && !report">
            <div class="card flex flex-col items-center px-6 py-12 text-center" role="alert">
                <span class="mb-3 grid size-12 place-items-center rounded-full bg-mr-50 text-mr-700"><i class="fa-solid fa-triangle-exclamation" aria-hidden="true"></i></span>
                <p class="text-sm font-semibold" x-text="error"></p>
                <button type="button" class="btn-secondary mt-4" @click="load()">Muat ulang</button>
            </div>
        </template>

        <div x-show="report" x-cloak class="grid gap-6 xl:grid-cols-[minmax(0,3fr)_minmax(0,2fr)]">
            {{-- KIRI: isi laporan --}}
            <div class="min-w-0 space-y-6">
                <section class="card p-5">
                    <div class="flex flex-wrap items-start justify-between gap-4">
                        <div>
                            <p class="text-sm text-stone-600">Laporan darurat</p>
                            <h1 class="tabular text-3xl font-bold tracking-tight" x-text="report?.code"></h1>
                            <div class="mt-2 flex flex-wrap items-center gap-2">
                                <x-admin.type-chip type="report?.report_type" />
                                <span class="inline-flex rounded-md px-2 py-0.5 text-xs font-semibold ring-1 ring-inset" :class="window.badgeTone(report?.report_type?.priority === 1 ? 'red' : 'gray')" x-text="`Prioritas ${report?.report_type?.priority ?? '-'}`"></span>
                            </div>
                        </div>
                        <div class="text-right">
                            <x-admin.status-chip status="report?.status" class="px-3 py-1.5 text-sm" />
                            <p class="mt-2 text-xs text-stone-600" x-text="`Dibuat ${window.formatDate(report?.created_at)}`"></p>
                            <p x-show="report?.response_time_minutes !== null" class="text-xs text-stone-600">Diambil dalam <span class="tabular font-semibold text-stone-900" x-text="`${report?.response_time_minutes} menit`"></span></p>
                        </div>
                    </div>
                    <div class="mt-5 rounded-lg bg-stone-50 p-4">
                        <h2 class="text-xs font-semibold text-stone-600">Deskripsi dari pelapor</h2>
                        <p class="mt-1 text-sm whitespace-pre-line" x-text="report?.description"></p>
                    </div>
                    <dl class="mt-4 grid gap-3 text-sm sm:grid-cols-2">
                        <div><dt class="text-stone-600">Lokasi jemput</dt><dd><span x-text="report?.address ?? '-'"></span><span class="tabular block text-xs text-stone-600" x-text="`${report?.latitude}, ${report?.longitude}`"></span></dd></div>
                        <template x-if="report?.destination">
                            <div><dt class="text-stone-600">Tujuan antar</dt><dd><span x-text="report.destination.name"></span><span class="block text-xs text-stone-600" x-text="report.destination.address"></span></dd></div>
                        </template>
                    </dl>
                </section>

                <section class="card p-5" aria-labelledby="timeline-title">
                    <h2 id="timeline-title" class="mb-4 font-semibold">Riwayat status</h2>
                    <p x-show="(report?.timeline ?? []).length === 0" class="text-sm text-stone-600">Belum ada riwayat status.</p>
                    <ol x-show="(report?.timeline ?? []).length > 0" class="relative space-y-5 border-l-2 border-stone-200 pl-6">
                        <template x-for="(log, index) in report?.timeline ?? []" :key="log.id">
                            <li class="relative">
                                <span class="absolute top-1 -left-[1.95rem] size-3.5 rounded-full border-2 border-white ring-2"
                                      :class="index === report.timeline.length - 1 ? 'bg-mr-600 ring-mr-300' : 'bg-stone-400 ring-stone-200'"></span>
                                <div class="flex flex-wrap items-center gap-2">
                                    <template x-if="log.from_status">
                                        <span class="flex items-center gap-2">
                                            <x-admin.status-chip status="log.from_status" />
                                            <i class="fa-solid fa-arrow-right text-xs text-stone-500" aria-label="menjadi"></i>
                                        </span>
                                    </template>
                                    <x-admin.status-chip status="log.to_status" />
                                    <span class="tabular text-xs text-stone-600" x-text="window.formatDate(log.created_at, { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit' })"></span>
                                </div>
                                <p class="mt-1 text-sm">
                                    oleh <span class="font-medium" x-text="log.changed_by?.name ?? 'Sistem'"></span>
                                    <span x-show="log.changed_by" class="text-xs text-stone-600" x-text="`(${log.changed_by?.role?.label})`"></span>
                                </p>
                                <p x-show="log.note" class="text-sm text-stone-700" x-text="log.note"></p>
                            </li>
                        </template>
                    </ol>
                </section>

                {{-- Detail khusus jenis laporan (satu dari empat tabel detail) --}}
                <section class="card p-5">
                    <template x-if="report?.details?.kind === 'kecelakaan'">
                        <div>
                            <h2 class="mb-3 font-semibold">Detail kecelakaan</h2>
                            <dl class="grid gap-3 text-sm sm:grid-cols-3">
                                <div><dt class="text-stone-600">Jenis kecelakaan</dt><dd class="font-medium" x-text="report.details.accident_type.label"></dd></div>
                                <div><dt class="text-stone-600">Perkiraan korban</dt><dd class="tabular font-medium" x-text="`${report.details.estimated_victim_count} orang`"></dd></div>
                                <div><dt class="text-stone-600">Kondisi lokasi</dt>
                                    <dd class="flex flex-wrap gap-1.5">
                                        <span x-show="report.details.has_trapped_victim"><x-admin.badge tone="red">Ada korban terjepit</x-admin.badge></span>
                                        <span x-show="report.details.has_fire_hazard"><x-admin.badge tone="red">Potensi api</x-admin.badge></span>
                                        <span x-show="report.details.is_road_blocked"><x-admin.badge tone="amber">Jalan tertutup</x-admin.badge></span>
                                        <span x-show="!report.details.has_trapped_victim && !report.details.has_fire_hazard && !report.details.is_road_blocked">Tidak ada catatan bahaya</span>
                                    </dd>
                                </div>
                            </dl>
                        </div>
                    </template>
                    <template x-if="report?.details?.kind === 'medis'">
                        <div>
                            <h2 class="mb-3 font-semibold">Detail medis darurat</h2>
                            <dl class="grid gap-3 text-sm sm:grid-cols-3">
                                <div><dt class="text-stone-600">Kategori</dt><dd class="font-medium" x-text="report.details.medical_category.label"></dd></div>
                                <div><dt class="text-stone-600">Gejala mulai</dt><dd class="tabular font-medium" x-text="report.details.symptom_onset_at ? window.formatDate(report.details.symptom_onset_at) : 'Tidak diketahui'"></dd></div>
                                <div><dt class="text-stone-600">Riwayat penyakit</dt><dd class="font-medium" x-text="report.details.has_medical_history ? (report.details.medical_history_notes || 'Ada') : 'Tidak ada'"></dd></div>
                            </dl>
                        </div>
                    </template>
                    <template x-if="report?.details?.kind === 'ibu_hamil'">
                        <div>
                            <h2 class="mb-3 font-semibold">Detail ibu hamil</h2>
                            <dl class="grid gap-3 text-sm sm:grid-cols-3">
                                <div><dt class="text-stone-600">Usia kehamilan</dt><dd class="tabular font-medium" x-text="report.details.gestational_age_weeks ? `${report.details.gestational_age_weeks} minggu` : '-'"></dd></div>
                                <div><dt class="text-stone-600">Jarak kontraksi</dt><dd class="tabular font-medium" x-text="report.details.contraction_interval_minutes ? `tiap ${report.details.contraction_interval_minutes} menit` : '-'"></dd></div>
                                <div><dt class="text-stone-600">Kehamilan ke-</dt><dd class="tabular font-medium" x-text="report.details.pregnancy_number ?? '-'"></dd></div>
                                <div><dt class="text-stone-600">Ketuban / perdarahan</dt>
                                    <dd class="flex flex-wrap gap-1.5">
                                        <span class="inline-flex rounded-md px-2 py-0.5 text-xs font-semibold ring-1 ring-inset" :class="window.badgeTone(report.details.is_water_broken ? 'amber' : 'gray')" x-text="`Ketuban ${report.details.is_water_broken ? 'pecah' : 'belum pecah'}`"></span>
                                        <span class="inline-flex rounded-md px-2 py-0.5 text-xs font-semibold ring-1 ring-inset" :class="window.badgeTone(report.details.has_bleeding ? 'red' : 'gray')" x-text="report.details.has_bleeding ? 'Ada perdarahan' : 'Tidak ada perdarahan'"></span>
                                    </dd>
                                </div>
                                <div class="sm:col-span-2"><dt class="text-stone-600">Faskes tujuan</dt><dd class="font-medium" x-text="report.details.destination_clinic?.name ?? report.destination?.name ?? '-'"></dd></div>
                            </dl>
                        </div>
                    </template>
                    <template x-if="report?.details?.kind === 'jenazah'">
                        <div>
                            <h2 class="mb-3 font-semibold">Detail pengantaran jenazah</h2>
                            <dl class="grid gap-3 text-sm sm:grid-cols-3">
                                <div><dt class="text-stone-600">Nama almarhum/almarhumah</dt><dd class="font-medium" x-text="report.details.deceased_name"></dd></div>
                                <div><dt class="text-stone-600">Tempat jemput</dt><dd class="font-medium" x-text="report.details.pickup_place_type.label"></dd></div>
                                <div><dt class="text-stone-600">Jadwal jemput</dt><dd class="tabular font-medium" x-text="report.details.scheduled_pickup_at ? window.formatDate(report.details.scheduled_pickup_at) : 'Segera'"></dd></div>
                                <div><dt class="text-stone-600">Surat kematian</dt><dd class="font-medium" x-text="report.details.has_death_certificate ? 'Ada' : 'Belum ada'"></dd></div>
                                <div class="sm:col-span-2"><dt class="text-stone-600">Kontak keluarga</dt><dd class="font-medium"><span x-text="report.details.family_contact_name"></span> · <a :href="`tel:${report.details.family_contact_phone}`" class="hover:text-mr-700" x-text="report.details.family_contact_phone"></a></dd></div>
                            </dl>
                        </div>
                    </template>
                    <template x-if="report && !report.details">
                        <div>
                            <h2 class="font-semibold">Detail khusus jenis laporan</h2>
                            <p class="mt-1 text-sm text-stone-600">Pelapor belum mengisi detail tambahan untuk laporan ini.</p>
                        </div>
                    </template>
                </section>

                <section class="card overflow-hidden" aria-labelledby="patients-title">
                    <h2 id="patients-title" class="border-b border-stone-100 px-5 py-3 font-semibold">Pasien</h2>
                    <template x-if="report && report.patients.length === 0">
                        <x-admin.empty-state icon="user-injured" title="Belum ada data pasien" description="Data pasien diisi pelapor atau driver dari aplikasi." />
                    </template>
                    <div class="relative overflow-x-auto" x-show="(report?.patients ?? []).length > 0">
                        <table class="data-table">
                            <thead><tr><th>Nama</th><th>L/P</th><th>Usia</th><th>Kesadaran</th><th>Bernapas</th><th>Kondisi</th><th>Diserahkan ke</th></tr></thead>
                            <tbody>
                                <template x-for="patient in report?.patients ?? []" :key="patient.id">
                                    <tr>
                                        <td x-text="patient.name ?? 'Tanpa nama'"></td>
                                        <td x-text="patient.gender ?? '-'"></td>
                                        <td class="tabular" x-text="patient.age_estimate ? `± ${patient.age_estimate} th` : '-'"></td>
                                        <td x-text="patient.consciousness.label"></td>
                                        <td x-text="yesNo(patient.is_breathing)"></td>
                                        <td class="min-w-40" x-text="patient.condition_note ?? '-'"></td>
                                        <td class="min-w-40"><span x-text="patient.handed_over_to ?? '-'"></span><span x-show="patient.handed_over_at" class="tabular block text-xs text-stone-600" x-text="window.formatDate(patient.handed_over_at, { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' })"></span></td>
                                    </tr>
                                </template>
                            </tbody>
                        </table>
                    </div>
                </section>

                <section class="card p-5" aria-labelledby="attachments-title">
                    <h2 id="attachments-title" class="mb-3 font-semibold">Lampiran</h2>
                    <p x-show="report && report.attachments.length === 0" class="text-sm text-stone-600">Tidak ada lampiran.</p>
                    <ul x-show="(report?.attachments ?? []).length > 0" class="grid grid-cols-2 gap-3 sm:grid-cols-3">
                        <template x-for="att in report?.attachments ?? []" :key="att.id">
                            <li class="overflow-hidden rounded-lg border border-stone-200">
                                <template x-if="att.is_image">
                                    <button type="button" class="block aspect-[4/3] w-full bg-stone-100" x-data="{ failed: false }"
                                            @click="if (!failed) lightbox = { open: true, src: att.url, caption: `${att.type.label} (${att.size_kb} KB)` }"
                                            :aria-label="failed ? 'Berkas tidak tersedia' : `Perbesar ${att.type.label}`">
                                        <img :src="att.url" :alt="att.type.label" loading="lazy" class="size-full object-cover" x-show="!failed" x-on:error="failed = true">
                                        <span x-show="failed" x-cloak class="grid size-full place-items-center p-2 text-center text-xs text-stone-600"><span><i class="fa-solid fa-image mb-1 block text-lg" aria-hidden="true"></i>Berkas tidak tersedia di penyimpanan</span></span>
                                    </button>
                                </template>
                                <template x-if="!att.is_image">
                                    <a :href="`${att.url}?download=1`" class="grid aspect-[4/3] place-items-center bg-stone-50 text-stone-600 hover:bg-mr-50 hover:text-mr-700">
                                        <span class="text-center text-xs"><i class="fa-solid fa-file-pdf mb-1 block text-2xl" aria-hidden="true"></i>Unduh dokumen</span>
                                    </a>
                                </template>
                                <div class="px-2 py-1.5 text-xs">
                                    <div class="font-medium" x-text="att.type.label"></div>
                                    <div class="text-stone-600" x-text="`${att.size_kb} KB · ${window.formatDate(att.created_at, { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' })}`"></div>
                                </div>
                            </li>
                        </template>
                    </ul>

                    <div x-show="lightbox.open" x-cloak x-transition.opacity class="fixed inset-0 z-[80] flex flex-col items-center justify-center bg-stone-950/90 p-4"
                         @keydown.escape.window="lightbox.open = false" @click.self="lightbox.open = false" role="dialog" aria-modal="true" aria-label="Pratinjau lampiran">
                        <img :src="lightbox.src" :alt="lightbox.caption" class="max-h-[80vh] max-w-full rounded-lg object-contain">
                        <div class="mt-3 flex items-center gap-3 text-sm text-white">
                            <span x-text="lightbox.caption"></span>
                            <a :href="`${lightbox.src}?download=1`" class="btn-secondary min-h-9">Unduh</a>
                            <button type="button" class="btn-secondary min-h-9" @click="lightbox.open = false">Tutup</button>
                        </div>
                    </div>
                </section>

                <section class="card p-5" aria-labelledby="reporter-title">
                    <h2 id="reporter-title" class="mb-3 font-semibold">Pelapor</h2>
                    <div class="flex items-center gap-3">
                        <span class="grid size-10 shrink-0 place-items-center rounded-full bg-mr-50 text-sm font-bold text-mr-800 ring-1 ring-mr-300" aria-hidden="true"
                              x-text="(report?.reporter?.name ?? '').split(' ').map((part) => part[0]).slice(0, 2).join('').toUpperCase()"></span>
                        <div class="min-w-0">
                            <a :href="`/admin/users/${report?.reporter?.id}`" class="font-semibold hover:text-mr-700" x-text="report?.reporter?.name"></a>
                            <p class="text-sm text-stone-600">
                                <a :href="`tel:${report?.reporter?.phone}`" class="hover:text-mr-700" x-text="report?.reporter?.phone"></a> · <span x-text="report?.reporter?.email"></span>
                            </p>
                            <p class="text-xs text-stone-600" x-text="`${report?.reporter?.devices_count ?? 0} perangkat terdaftar, akun ${(report?.reporter?.account_status?.label ?? '').toLowerCase()}`"></p>
                        </div>
                    </div>
                </section>
            </div>

            {{-- KANAN: lokasi, armada, dispatch, aksi --}}
            <div class="min-w-0 space-y-6">
                <section class="card overflow-hidden" x-data="reportMap()" aria-label="Peta lokasi laporan">
                    <div class="relative h-80">
                        <div x-ref="map" class="absolute inset-0 z-0"></div>
                        <p x-show="error" x-cloak class="absolute inset-0 z-10 grid place-items-center bg-white text-sm text-mr-700" x-text="error"></p>
                    </div>
                    <div class="flex flex-wrap gap-x-4 gap-y-1 px-5 py-2.5 text-xs text-stone-600">
                        <span><i class="fa-solid fa-location-dot mr-1" :style="`color: ${typeColor}`" aria-hidden="true"></i>Lokasi jemput</span>
                        <span x-show="hasDestination"><i class="fa-solid fa-flag-checkered mr-1 text-stone-900" aria-hidden="true"></i>Tujuan</span>
                        <span x-show="hasDriver"><i class="fa-solid fa-truck-medical mr-1 text-mr-600" aria-hidden="true"></i>Posisi terakhir driver</span>
                    </div>
                </section>

                <section class="card p-5" aria-labelledby="fleet-title">
                    <h2 id="fleet-title" class="mb-3 font-semibold">Driver dan ambulans</h2>
                    <template x-if="report?.driver">
                        <div>
                            <div class="flex items-center gap-3">
                                <template x-if="report.driver.photo_url"><img :src="report.driver.photo_url" :alt="`Foto ${report.driver.name}`" class="size-12 shrink-0 rounded-full object-cover ring-1 ring-stone-200"></template>
                                <template x-if="!report.driver.photo_url"><span class="grid size-12 shrink-0 place-items-center rounded-full bg-mr-50 font-bold text-mr-800 ring-1 ring-mr-300" aria-hidden="true" x-text="report.driver.name.split(' ').map((part) => part[0]).slice(0, 2).join('').toUpperCase()"></span></template>
                                <div class="min-w-0">
                                    <a :href="`/admin/drivers/${report.driver.id}`" class="font-semibold hover:text-mr-700" x-text="report.driver.name"></a>
                                    <p class="text-sm text-stone-600" x-text="report.driver.clinic"></p>
                                    <a :href="`tel:${report.driver.phone}`" class="text-sm text-stone-600 hover:text-mr-700" x-text="report.driver.phone"></a>
                                </div>
                            </div>
                            <template x-if="report.ambulance">
                                <dl class="mt-4 grid grid-cols-2 gap-3 rounded-lg bg-stone-50 p-3 text-sm">
                                    <div><dt class="text-xs text-stone-600">Nomor polisi</dt><dd class="tabular font-semibold" x-text="report.ambulance.plate_number"></dd></div>
                                    <div><dt class="text-xs text-stone-600">Jenis</dt><dd x-text="report.ambulance.type"></dd></div>
                                    <div><dt class="text-xs text-stone-600">Kendaraan</dt><dd x-text="report.ambulance.vehicle_name ?? '-'"></dd></div>
                                    <div><dt class="text-xs text-stone-600">Klinik armada</dt><dd x-text="report.ambulance.clinic"></dd></div>
                                </dl>
                            </template>
                            <p x-show="report.driver.last_location" class="mt-3 text-xs text-stone-600"
                               x-text="`Posisi terakhir ${window.timeAgo(report.driver.last_location?.recorded_at)}, ${report.driver.last_location?.speed_kmh ?? 0} km/j.`"></p>
                        </div>
                    </template>
                    <p x-show="report && !report.driver" class="text-sm text-stone-600">Belum ada driver yang mengambil laporan ini.</p>
                </section>

                <section class="card overflow-hidden" aria-labelledby="dispatch-title">
                    <div class="border-b border-stone-100 px-5 py-3">
                        <h2 id="dispatch-title" class="font-semibold">Broadcast ke driver</h2>
                        <p class="text-xs text-stone-600" x-text="`Dikirim bertahap mulai dari driver terdekat (shift aktif, tidak bertugas) dengan jenis ambulans: ${(report?.report_type?.ambulance_types ?? []).map((type) => type.name).join(', ') || '-'}.`"></p>
                        <p x-show="report?.dispatch_state && report?.status?.value === 'menunggu'" class="mt-1 text-xs font-semibold"
                           :class="report?.dispatch_state?.alarmed ? 'text-mr-700' : 'text-stone-700'"
                           x-text="report?.dispatch_state?.alarmed ? 'Semua putaran habis tanpa driver: perlu tindakan admin.' : `Putaran ke-${report?.dispatch_state?.round} sedang berjalan.`"></p>
                    </div>
                    <template x-if="report && report.dispatches.length === 0">
                        <x-admin.empty-state icon="tower-broadcast" title="Belum ada broadcast tercatat" />
                    </template>
                    <ul x-show="(report?.dispatches ?? []).length > 0" class="divide-y divide-stone-100">
                        <template x-for="dispatch in report?.dispatches ?? []" :key="dispatch.id">
                            <li class="flex flex-wrap items-center justify-between gap-2 px-5 py-3">
                                <div class="min-w-0">
                                    <p class="text-sm font-medium"><span x-text="dispatch.driver?.name"></span> <span class="tabular text-xs text-stone-600" x-text="dispatch.plate_number ? `(${dispatch.plate_number})` : ''"></span></p>
                                    <p class="tabular text-xs text-stone-600"
                                       x-text="`${dispatch.distance_km.toLocaleString('id-ID', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} km · kirim ${window.formatDate(dispatch.sent_at, { hour: '2-digit', minute: '2-digit', second: '2-digit' })} · dibuka ${dispatch.opened_at ? window.formatDate(dispatch.opened_at, { hour: '2-digit', minute: '2-digit', second: '2-digit' }) : 'belum'}`"></p>
                                </div>
                                <x-admin.status-chip status="dispatch.response" />
                            </li>
                        </template>
                    </ul>
                </section>

                <section class="card space-y-3 p-5" aria-labelledby="actions-title">
                    <h2 id="actions-title" class="font-semibold">Aksi admin</h2>
                    <template x-if="report?.is_cancellable">
                        <div class="space-y-3">
                            <button type="button" class="btn-danger w-full" @click="cancel = { open: true, reason: '', errors: {}, submitting: false }"><i class="fa-solid fa-ban" aria-hidden="true"></i> Batalkan laporan</button>
                            <p class="text-xs text-stone-600">Hanya untuk laporan yang belum diambil driver, mis. laporan ganda atau palsu.</p>
                        </div>
                    </template>
                    <template x-if="report && !report.is_cancellable">
                        <div class="space-y-3">
                            <span class="block" tabindex="0" title="Laporan yang sudah diambil driver atau sudah ditutup tidak bisa dibatalkan admin." aria-describedby="cancel-hint">
                                <button type="button" class="btn-danger w-full" disabled><i class="fa-solid fa-ban" aria-hidden="true"></i> Batalkan laporan</button>
                            </span>
                            <p id="cancel-hint" class="text-xs text-stone-600" x-text="`Tidak tersedia: laporan berstatus ${(report.status.label ?? '').toLowerCase()}. Pembatalan hanya untuk laporan yang masih menunggu.`"></p>
                        </div>
                    </template>
                    <a :href="report?.driver ? `/admin/location-logs?driver_id=${report.driver.id}&report_id=${report.id}` : null"
                       class="btn-secondary w-full" :class="report?.driver ? '' : 'pointer-events-none opacity-50'"
                       :aria-disabled="report?.driver ? null : 'true'" :tabindex="report?.driver ? null : -1">
                        <i class="fa-solid fa-route" aria-hidden="true"></i> Lihat rute di Log Lokasi
                    </a>
                </section>
            </div>
        </div>

        <x-admin.modal show="cancel.open" title="Batalkan laporan">
            <form @submit.prevent="submitCancel()" class="space-y-4">
                <p class="text-sm text-stone-700">Status <strong x-text="report?.code"></strong> berubah menjadi <strong>dibatalkan</strong> dan tercatat di riwayat status atas nama Anda. Bila driver sudah mengambil laporan lebih dulu, pembatalan otomatis ditolak.</p>
                <div>
                    <label for="reason" class="form-label">Alasan pembatalan <span class="text-mr-700">*</span></label>
                    <textarea id="reason" x-model="cancel.reason" rows="3" minlength="5" maxlength="255" required class="form-input py-2" placeholder="Mis. laporan ganda dengan MDR-..."
                              :aria-invalid="cancel.errors.reason ? 'true' : null" aria-describedby="reason-error"></textarea>
                    <p id="reason-error" x-show="cancel.errors.reason" x-cloak class="form-error" x-text="cancel.errors.reason?.[0]"></p>
                </div>
                <div class="flex justify-end gap-2">
                    <button type="button" class="btn-secondary" @click="cancel.open = false">Kembali</button>
                    <button type="submit" class="btn-danger" :disabled="cancel.submitting">Batalkan laporan</button>
                </div>
            </form>
        </x-admin.modal>
    </div>
</x-admin.layout>
