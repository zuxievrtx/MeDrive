import { getJson } from './http';
import { getData } from './api';
import { subscribe } from './realtime';
import { escapeHtml } from './shell';
import { apiAction } from './resources';

const SIGNAL_LOST_MS = Number(document.querySelector('meta[name="signal-lost-seconds"]')?.content || 60) * 1000;
const ON_DUTY_COLOR = '#b30000';
const STANDBY_COLOR = '#44403c';

let leafletPromise = null;

export function loadLeaflet() {
    leafletPromise ??= import('leaflet').then((module) => module.default ?? module);
    return leafletPromise;
}

export function createMap(L, element, { center = [-6.9932, 110.4203], zoom = 12, ...options } = {}) {
    const map = L.map(element, { zoomControl: true, ...options }).setView(center, zoom);
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
    }).addTo(map);
    return map;
}

export function pinIcon(L, color, icon) {
    return L.divIcon({
        className: '',
        iconSize: [30, 30],
        iconAnchor: [15, 15],
        html: `<div class="mr-marker" style="width:30px;height:30px"><div class="mr-marker__body" style="inset:0;background:${color}"><i class="fa-solid fa-${escapeHtml(icon)}"></i></div></div>`,
    });
}

export function pulseIcon(L, color) {
    return L.divIcon({
        className: '',
        iconSize: [18, 18],
        iconAnchor: [9, 9],
        html: `<div class="mr-pulse" style="--pulse-color:${color}"></div>`,
    });
}

export function isStale(driver) {
    return !driver.recorded_at || Date.now() - new Date(driver.recorded_at).getTime() > SIGNAL_LOST_MS;
}

export function ambulanceIcon(L, driver, { showLabel = true } = {}) {
    const color = driver.is_on_duty ? ON_DUTY_COLOR : STANDBY_COLOR;
    const stale = isStale(driver);
    const hasHeading = driver.heading !== null && driver.heading !== undefined;
    const label = showLabel
        ? `<div class="mr-marker__label">${escapeHtml(driver.name)} · ${escapeHtml(driver.plate_number ?? '-')}${stale ? ' · sinyal hilang' : ''}</div>`
        : '';

    return L.divIcon({
        className: '',
        iconSize: [36, 36],
        iconAnchor: [18, 18],
        popupAnchor: [0, -18],
        html: `<div class="mr-marker ${stale ? 'mr-marker--stale' : ''}" style="--marker-color:${color}">
            <div class="mr-marker__heading" style="transform:rotate(${hasHeading ? driver.heading : 0}deg);${hasHeading ? '' : 'display:none'}"></div>
            <div class="mr-marker__body" style="background:${color}"><i class="fa-solid fa-${escapeHtml(driver.icon ?? 'truck-medical')}"></i></div>
            ${label}
        </div>`,
    });
}

export function secondsAgo(iso) {
    if (!iso) {
        return null;
    }
    return Math.max(0, Math.round((Date.now() - new Date(iso).getTime()) / 1000));
}

export function agoLabel(iso) {
    const seconds = secondsAgo(iso);
    if (seconds === null) return 'belum ada data';
    if (seconds < 60) return `${seconds} detik lalu`;
    if (seconds < 3600) return `${Math.floor(seconds / 60)} menit lalu`;
    if (seconds < 86400) return `${Math.floor(seconds / 3600)} jam lalu`;
    return `${Math.floor(seconds / 86400)} hari lalu`;
}

function mergeLocation(driver, payload) {
    return {
        ...driver,
        name: payload.name ?? driver.name,
        plate_number: payload.plate_number ?? driver.plate_number,
        ambulance_type: payload.ambulance_type ?? driver.ambulance_type,
        lat: Number(payload.lat),
        lng: Number(payload.lng),
        speed_kmh: payload.speed_kmh,
        heading: payload.heading,
        battery_level: payload.battery_level ?? driver.battery_level,
        is_mock_location: payload.is_mock_location ?? driver.is_mock_location,
        accuracy_m: payload.accuracy_m,
        is_on_duty: Boolean(payload.is_on_duty),
        report_code: payload.report_code,
        report_status: payload.report_status,
        recorded_at: payload.recorded_at,
    };
}

/**
 * Peta Live: posisi semua driver dengan shift terbuka dari driver_last_locations + event Reverb.
 * Dipakai juga oleh mini peta dashboard (mode compact).
 */
function trackingMap({ dataUrl, compact = false }) {
    // Objek Leaflet disimpan di luar state Alpine agar tidak dibungkus proxy reaktif.
    let L = null;
    let map = null;
    let reportLayer = null;
    const markers = new Map();

    return {
        drivers: [],
        reports: [],
        loading: true,
        error: null,
        mode: 'polling',
        filters: { clinic: '', type: '', onDutyOnly: false },
        followId: null,
        selectedId: null,
        tick: 0,
        endShift: { open: false, driverId: null, shiftId: null, name: '', submitting: false },

        async init() {
            try {
                L = await loadLeaflet();
                map = createMap(L, this.$refs.map, { zoom: compact ? 11 : 12, scrollWheelZoom: !compact });
                reportLayer = L.layerGroup().addTo(map);
                map.on('dragstart', () => (this.followId = null));
            } catch {
                this.error = 'Peta gagal dimuat. Periksa koneksi internet untuk tile OpenStreetMap.';
            }

            await this.refresh(true);

            subscribe({
                channel: 'admin.tracking',
                event: 'DriverLocationUpdated',
                onEvent: (payload) => this.applyLocation(payload),
                poll: () => this.refresh(),
                onMode: (mode) => (this.mode = mode),
            });

            // Perbarui label "x detik lalu" dan status sinyal hilang.
            setInterval(() => {
                this.tick++;
                this.drivers.forEach((driver) => this.drawDriver(driver));
            }, 5000);

            window.addEventListener('medrive:report-created', () => this.refresh());
        },

        async refresh(fit = false) {
            try {
                const data = await getJson(dataUrl);
                this.drivers = data.drivers;
                this.reports = data.reports;
                this.error = null;
                this.redraw(fit);
            } catch (error) {
                this.error = error.message;
            } finally {
                this.loading = false;
            }
        },

        applyLocation(payload) {
            const index = this.drivers.findIndex((driver) => driver.driver_id === payload.driver_id);
            if (index === -1) {
                // Driver baru membuka shift: ambil ulang data lengkap (klinik, jenis ambulans).
                this.refresh();
                return;
            }
            this.drivers[index] = mergeLocation(this.drivers[index], payload);
            this.drawDriver(this.drivers[index]);
            if (this.followId === payload.driver_id && map) {
                map.panTo([this.drivers[index].lat, this.drivers[index].lng]);
            }
        },

        get visibleDrivers() {
            this.tick;
            return this.drivers.filter((driver) => this.matches(driver));
        },

        matches(driver) {
            if (this.filters.clinic && String(driver.clinic_id) !== String(this.filters.clinic)) return false;
            if (this.filters.type && String(driver.ambulance_type_id) !== String(this.filters.type)) return false;
            if (this.filters.onDutyOnly && !driver.is_on_duty) return false;
            return true;
        },

        redraw(fit = false) {
            if (!map) return;
            const seen = new Set();
            this.drivers.forEach((driver) => {
                seen.add(driver.driver_id);
                this.drawDriver(driver);
            });
            [...markers.keys()].forEach((id) => {
                if (!seen.has(id)) {
                    markers.get(id).remove();
                    markers.delete(id);
                }
            });

            reportLayer.clearLayers();
            this.reports.forEach((report) => {
                L.marker([report.lat, report.lng], { icon: pulseIcon(L, report.color || ON_DUTY_COLOR) })
                    .bindPopup(
                        `<strong>${escapeHtml(report.code)}</strong><br>${escapeHtml(report.type)} · ${escapeHtml(report.status_label)}<br>${escapeHtml(report.address)}<br><a href="${report.url}">Buka detail laporan</a>`,
                    )
                    .addTo(reportLayer);
            });

            if (fit) this.fitAll();
        },

        fitAll() {
            const points = [
                ...this.drivers.filter((d) => d.lat !== null).map((d) => [d.lat, d.lng]),
                ...this.reports.map((r) => [r.lat, r.lng]),
            ];
            if (points.length > 0) {
                map.fitBounds(points, { padding: [40, 40], maxZoom: 15 });
            }
        },

        drawDriver(driver) {
            if (!map || driver.lat === null || driver.lat === undefined) return;
            const visible = this.matches(driver);
            let marker = markers.get(driver.driver_id);
            if (!marker) {
                marker = L.marker([driver.lat, driver.lng], {
                    icon: ambulanceIcon(L, driver, { showLabel: !compact }),
                });
                marker.on('click', () => (this.selectedId = driver.driver_id));
                markers.set(driver.driver_id, marker);
            }
            marker.setLatLng([driver.lat, driver.lng]);
            marker.setIcon(ambulanceIcon(L, driver, { showLabel: !compact }));
            marker.setZIndexOffset(driver.is_on_duty ? 1000 : 0);
            if (!compact) {
                marker.bindPopup(this.popupHtml(driver));
            }
            if (visible && !map.hasLayer(marker)) marker.addTo(map);
            if (!visible && map.hasLayer(marker)) marker.remove();
        },

        popupHtml(driver) {
            const report = driver.report_code
                ? `<div>Menangani <strong>${escapeHtml(driver.report_code)}</strong> (${escapeHtml(driver.report_status_label ?? driver.report_status ?? '')})</div>`
                : '<div>Standby, belum menangani laporan</div>';
            return `<div style="min-width:200px">
                <div style="font-weight:600">${escapeHtml(driver.name)}</div>
                <div>${escapeHtml(driver.plate_number ?? '-')} · ${escapeHtml(driver.ambulance_type ?? '')}</div>
                <div>${escapeHtml(driver.clinic_name ?? '')}</div>
                ${report}
                <div style="margin-top:4px;color:#57534e">${driver.speed_kmh ?? 0} km/j · baterai ${driver.battery_level ?? '-'}% · update ${agoLabel(driver.recorded_at)}</div>
                ${driver.is_mock_location ? '<div style="margin-top:4px;color:#b91c1c;font-weight:600">Lokasi palsu (mock) terdeteksi</div>' : ''}
                <div style="display:flex;gap:6px;margin-top:8px;flex-wrap:wrap">
                    <a class="btn-secondary" style="min-height:32px;padding:0 10px" href="${driver.history_url}">Riwayat Rute</a>
                    <button type="button" class="btn-danger" style="min-height:32px;padding:0 10px" onclick="window.dispatchEvent(new CustomEvent('medrive:end-shift',{detail:{driverId:${Number(driver.driver_id)},shiftId:${Number(driver.shift_id)},name:${escapeHtml(JSON.stringify(driver.name))}}}))">Akhiri Shift</button>
                </div>
            </div>`;
        },

        focus(driver) {
            this.selectedId = driver.driver_id;
            this.followId = driver.driver_id;
            if (map && driver.lat !== null) {
                map.flyTo([driver.lat, driver.lng], 16, { duration: 0.8 });
                markers.get(driver.driver_id)?.openPopup();
            }
        },

        stopFollow() {
            this.followId = null;
        },

        openEndShift({ driverId, shiftId, name }) {
            this.endShift = { open: true, driverId, shiftId, name, submitting: false };
        },

        async confirmEndShift() {
            this.endShift.submitting = true;
            try {
                await apiAction(`/api/v1/admin/drivers/${this.endShift.driverId}/shifts/${this.endShift.shiftId}/end`, {
                    successMessage: `Shift ${this.endShift.name} telah diakhiri.`,
                });
                this.endShift.open = false;
                map?.closePopup();
                await this.refresh();
            } catch {
                // pesan error sudah ditampilkan apiFetch; data dimuat ulang agar sinkron
                this.endShift.open = false;
                await this.refresh();
            } finally {
                this.endShift.submitting = false;
            }
        },

        isStale,
        agoLabel,
    };
}

/**
 * Peta detail laporan. Data datang dari event medrive:report-loaded (reportDetail memuat dari API);
 * marker driver diperbarui setiap laporan dimuat ulang.
 */
function reportMap() {
    let map = null;
    let driverMarker = null;

    return {
        error: null,
        hasDestination: false,
        hasDriver: false,
        typeColor: ON_DUTY_COLOR,

        init() {
            window.addEventListener('medrive:report-loaded', (event) => this.render(event.detail));
        },

        async render(report) {
            try {
                const L = await loadLeaflet();
                const pickup = { lat: report.latitude, lng: report.longitude };
                const destination =
                    report.destination?.latitude != null
                        ? {
                              lat: report.destination.latitude,
                              lng: report.destination.longitude,
                              name: report.destination.name,
                          }
                        : null;
                const location = report.driver?.last_location;
                const driver = location
                    ? {
                          lat: location.latitude,
                          lng: location.longitude,
                          heading: location.heading,
                          recorded_at: location.recorded_at,
                          is_on_duty: true,
                          icon: report.ambulance?.map_icon,
                          name: report.driver.name,
                          plate_number: report.ambulance?.plate_number,
                      }
                    : null;

                this.typeColor = report.report_type?.color || ON_DUTY_COLOR;
                this.hasDestination = Boolean(destination);
                this.hasDriver = Boolean(driver);

                if (!map) {
                    map = createMap(L, this.$refs.map, { center: [pickup.lat, pickup.lng], zoom: 15 });
                    const points = [[pickup.lat, pickup.lng]];

                    L.marker([pickup.lat, pickup.lng], { icon: pinIcon(L, this.typeColor, 'location-dot') })
                        .bindPopup('<strong>Lokasi jemput</strong>')
                        .addTo(map);

                    if (destination) {
                        points.push([destination.lat, destination.lng]);
                        L.marker([destination.lat, destination.lng], { icon: pinIcon(L, '#1c1917', 'flag-checkered') })
                            .bindPopup(`<strong>Tujuan</strong><br>${escapeHtml(destination.name ?? '')}`)
                            .addTo(map);
                        L.polyline(
                            [
                                [pickup.lat, pickup.lng],
                                [destination.lat, destination.lng],
                            ],
                            { color: '#1c1917', weight: 3, dashArray: '6 6' },
                        ).addTo(map);
                    }

                    if (driver) points.push([driver.lat, driver.lng]);
                    if (points.length > 1) map.fitBounds(points, { padding: [40, 40], maxZoom: 16 });
                }

                driverMarker?.remove();
                driverMarker = driver
                    ? L.marker([driver.lat, driver.lng], { icon: ambulanceIcon(L, driver) }).addTo(map)
                    : null;
            } catch {
                this.error = 'Peta gagal dimuat.';
            }
        },
    };
}

function pointMap({ point }) {
    return {
        error: null,
        async init() {
            if (!point) return;
            try {
                const L = await loadLeaflet();
                const map = createMap(L, this.$refs.map, { center: [point.lat, point.lng], zoom: 15 });
                L.marker([point.lat, point.lng], { icon: ambulanceIcon(L, point, { showLabel: false }) }).addTo(map);
            } catch {
                this.error = 'Peta gagal dimuat.';
            }
        },
    };
}

/**
 * Log Lokasi: rute historis dari driver_location_logs, playback, dan titik baru real-time
 * (event DriverLocationUpdated / polling driver_last_locations) bila driver sedang shift.
 */
/**
 * Nilai input datetime-local (WIB) dari ISO string.
 */
function toLocalInput(iso) {
    return new Date(iso).toLocaleString('sv-SE', { timeZone: 'Asia/Jakarta' }).slice(0, 16).replace(' ', 'T');
}

/**
 * Log Lokasi: filter, rute + ringkasan (/admin/location-logs), tabel ping (apiList terpisah), dan mode realtime
 * bila driver masih shift dan rentang berakhir di "sekarang".
 */
function locationLogMap({ routeUrl, trackingUrl }) {
    let L = null;
    let map = null;
    let routeLayer = null;
    let playbackMarker = null;
    let subscribed = false;

    return {
        filters: { driver_id: '', report_id: '', from: '', to: '', accurate_only: false },
        errors: {},
        loading: false,
        loaded: false,
        error: null,
        driver: null,
        report: null,
        isLive: false,
        points: [],
        livePoints: [],
        summary: null,
        mode: null,
        position: 0,
        playing: false,
        timer: null,

        async init() {
            const query = new URLSearchParams(window.location.search);
            ['driver_id', 'report_id', 'from', 'to'].forEach((key) => {
                if (query.has(key)) this.filters[key] = query.get(key);
            });
            this.filters.accurate_only = query.get('accurate_only') === '1';

            try {
                L = await loadLeaflet();
                map = createMap(L, this.$refs.map);
                routeLayer = L.layerGroup().addTo(map);
            } catch {
                this.error = 'Peta gagal dimuat.';
            }

            if (this.filters.driver_id) await this.load();
        },

        params() {
            return {
                driver_id: this.filters.driver_id,
                report_id: this.filters.report_id || null,
                from: this.filters.from || null,
                to: this.filters.to || null,
                accurate_only: this.filters.accurate_only ? 1 : null,
            };
        },

        submit() {
            if (!this.filters.driver_id) {
                this.errors = { driver_id: ['Pilih driver terlebih dahulu.'] };
                return;
            }
            this.load();
        },

        clearReport() {
            this.filters.report_id = '';
            this.filters.from = '';
            this.filters.to = '';
            this.load();
        },

        async load() {
            this.pause();
            this.loading = true;
            this.errors = {};
            this.error = null;
            try {
                const data = await getData(routeUrl, this.params(), { silent: true });
                this.driver = data.driver;
                this.report = data.report;
                this.isLive = data.is_live;
                this.summary = data.summary;
                this.points = data.points;
                this.livePoints = [];
                this.position = Math.max(0, this.points.length - 1);
                this.filters.from = toLocalInput(data.range.from);
                this.filters.to = toLocalInput(data.range.to);
                this.loaded = true;
                this.syncQuery();
                window.dispatchEvent(new CustomEvent('medrive:location-range', { detail: this.params() }));
                this.$nextTick(() => {
                    map?.invalidateSize();
                    this.draw();
                });
                if (this.isLive) this.subscribeLive();
            } catch (error) {
                if (error.isValidation) this.errors = error.details;
                else this.error = error.message;
            } finally {
                this.loading = false;
            }
        },

        syncQuery() {
            const query = new URLSearchParams();
            Object.entries(this.params()).forEach(([key, value]) => {
                if (value !== null && value !== '') query.set(key, value);
            });
            history.replaceState(null, '', `${window.location.pathname}?${query}`);
        },

        subscribeLive() {
            if (subscribed) return;
            subscribed = true;
            subscribe({
                channel: 'admin.tracking',
                event: 'DriverLocationUpdated',
                onEvent: (payload) => {
                    if (this.isLive && Number(payload.driver_id) === Number(this.driver?.id)) this.appendLive(payload);
                },
                poll: () => this.pollLive(),
                onMode: (mode) => (this.mode = mode),
            });
        },

        draw() {
            if (!map) return;
            routeLayer.clearLayers();
            const latlngs = this.points.map((point) => [point.lat, point.lng]);
            if (latlngs.length === 0) return;

            L.polyline(latlngs, { color: '#b30000', weight: 4, opacity: 0.85 }).addTo(routeLayer);
            this.points
                .filter((point) => point.mock)
                .forEach((point) =>
                    L.circleMarker([point.lat, point.lng], {
                        radius: 6,
                        color: '#7f1d1d',
                        fillColor: '#fecaca',
                        fillOpacity: 1,
                    })
                        .bindTooltip('GPS PALSU')
                        .addTo(routeLayer),
                );
            L.marker(latlngs[0], { icon: pinIcon(L, '#15803d', 'play') })
                .bindTooltip('Mulai')
                .addTo(routeLayer);
            L.marker(latlngs.at(-1), { icon: pinIcon(L, '#1c1917', 'flag-checkered') })
                .bindTooltip('Akhir')
                .addTo(routeLayer);
            playbackMarker = L.marker(latlngs.at(-1), {
                icon: ambulanceIcon(
                    L,
                    { ...this.points.at(-1), is_on_duty: true, recorded_at: new Date().toISOString() },
                    { showLabel: false },
                ),
                zIndexOffset: 2000,
            }).addTo(routeLayer);
            map.fitBounds(latlngs, { padding: [30, 30], maxZoom: 17 });
        },

        get current() {
            return this.points[this.position] ?? null;
        },

        stat(key) {
            const summary = this.summary;
            if (!summary) return '-';
            const format = (value, unit) =>
                value === null || value === undefined ? '-' : `${Number(value).toLocaleString('id-ID')}${unit}`;
            return {
                points: format(summary.points, ''),
                distance: format(summary.distance_km, ' km'),
                max: format(summary.max_speed_kmh, ' km/j'),
                avg: format(summary.avg_speed_kmh, ' km/j'),
                battery: format(summary.last_battery, '%'),
            }[key];
        },

        seek() {
            const point = this.current;
            if (!point || !playbackMarker) return;
            playbackMarker.setLatLng([point.lat, point.lng]);
            playbackMarker.setIcon(
                ambulanceIcon(
                    L,
                    { ...point, is_on_duty: true, recorded_at: new Date().toISOString() },
                    { showLabel: false },
                ),
            );
        },

        togglePlay() {
            if (this.playing) {
                this.pause();
                return;
            }
            if (this.position >= this.points.length - 1) this.position = 0;
            this.playing = true;
            const step = Math.max(1, Math.round(this.points.length / 300));
            this.timer = setInterval(() => {
                this.position = Math.min(this.points.length - 1, this.position + step);
                this.seek();
                if (this.position >= this.points.length - 1) this.pause();
            }, 100);
        },

        pause() {
            this.playing = false;
            clearInterval(this.timer);
        },

        appendLive(payload) {
            const last = this.points.at(-1);
            if (last && new Date(last.recorded_at) >= new Date(payload.recorded_at)) return;
            const point = {
                lat: Number(payload.lat),
                lng: Number(payload.lng),
                speed_kmh: payload.speed_kmh,
                heading: payload.heading,
                battery_level: payload.battery_level,
                accuracy_m: payload.accuracy_m,
                recorded_at: payload.recorded_at,
                mock: Boolean(payload.is_mock_location),
                live: true,
            };
            this.points.push(point);
            this.livePoints.unshift(point);
            this.position = this.points.length - 1;
            this.draw();
        },

        async pollLive() {
            if (!this.isLive || !this.driver) return;
            try {
                const data = await getJson(trackingUrl, { driver_id: this.driver.id });
                const driver = data.drivers[0];
                if (driver && driver.lat !== null) this.appendLive(driver);
            } catch {
                // dicoba lagi pada interval berikutnya
            }
        },
    };
}

export function registerMaps(Alpine) {
    Alpine.data('trackingMap', trackingMap);
    Alpine.data('reportMap', reportMap);
    Alpine.data('pointMap', pointMap);
    Alpine.data('locationLogMap', locationLogMap);
}
