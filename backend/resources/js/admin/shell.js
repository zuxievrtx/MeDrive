import { getJson } from './http';
import { getData } from './api';
import { subscribe } from './realtime';

const storage = {
    get(key, fallback) {
        try {
            const value = localStorage.getItem(key);
            return value === null ? fallback : JSON.parse(value);
        } catch {
            return fallback;
        }
    },
    set(key, value) {
        try {
            localStorage.setItem(key, JSON.stringify(value));
        } catch {
            // penyimpanan lokal tidak tersedia (mode privat), preferensi tidak diingat
        }
    },
};

export function escapeHtml(value) {
    return String(value ?? '').replace(
        /[&<>"']/g,
        (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char],
    );
}

/** Teks putih atau gelap, mana yang lebih terbaca di atas warna jenis laporan. */
export function readableTextOn(hex) {
    const value = (hex || '#57534e').replace('#', '');
    const [r, g, b] = [0, 2, 4].map((offset) => parseInt(value.substring(offset, offset + 2), 16) / 255);
    const channel = (c) => (c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4);
    const luminance = 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b);
    return luminance > 0.4 ? '#1c1917' : '#ffffff';
}

function beep(times = 1) {
    if (times > 1) {
        for (let index = 0; index < times; index++) setTimeout(() => beep(1), index * 700);
        return;
    }
    try {
        const context = new (window.AudioContext || window.webkitAudioContext)();
        const oscillator = context.createOscillator();
        const gain = context.createGain();
        oscillator.type = 'square';
        oscillator.frequency.value = 880;
        gain.gain.setValueAtTime(0.08, context.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.0001, context.currentTime + 0.6);
        oscillator.connect(gain).connect(context.destination);
        oscillator.start();
        oscillator.stop(context.currentTime + 0.6);
    } catch {
        // browser memblokir audio sebelum ada interaksi pengguna
    }
}

// Kelas badge per tone; sama dengan komponen Blade x-admin.badge.
const BADGE_TONES = {
    amber: 'bg-amber-100 text-amber-900 ring-amber-200',
    blue: 'bg-blue-100 text-blue-900 ring-blue-200',
    violet: 'bg-violet-100 text-violet-900 ring-violet-200',
    cyan: 'bg-cyan-100 text-cyan-900 ring-cyan-200',
    teal: 'bg-teal-100 text-teal-900 ring-teal-200',
    green: 'bg-green-100 text-green-900 ring-green-200',
    gray: 'bg-stone-100 text-stone-700 ring-stone-200',
    red: 'bg-mr-50 text-mr-800 ring-mr-300',
    brand: 'bg-mr-600 text-white ring-mr-600',
};

export function registerShell(Alpine) {
    window.badgeTone = (tone) => BADGE_TONES[tone] ?? BADGE_TONES.gray;
    window.typeStyle = (type) =>
        `background-color:${type?.color ?? '#57534e'};color:${type?.text_color ?? readableTextOn(type?.color)}`;
    window.typeIcon = (type) => (type?.icon ? `fa-${type.icon}` : '');
    window.formatDate = (
        iso,
        options = { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' },
    ) =>
        iso
            ? new Intl.DateTimeFormat('id-ID', { timeZone: 'Asia/Jakarta', ...options })
                  .format(new Date(iso))
                  .replace(/\./g, ':')
            : '-';
    window.formatDay = (iso) =>
        iso ? window.formatDate(iso, { day: 'numeric', month: 'short', year: 'numeric' }) : '-';
    window.timeAgo = (iso) => {
        if (!iso) return '-';
        const seconds = Math.round((new Date(iso).getTime() - Date.now()) / 1000);
        const format = new Intl.RelativeTimeFormat('id-ID', { numeric: 'auto' });
        const abs = Math.abs(seconds);
        if (abs < 60) return format.format(seconds, 'second');
        if (abs < 3600) return format.format(Math.round(seconds / 60), 'minute');
        if (abs < 86400) return format.format(Math.round(seconds / 3600), 'hour');
        if (abs < 2592000) return format.format(Math.round(seconds / 86400), 'day');
        return format.format(Math.round(seconds / 2592000), 'month');
    };
    window.durationLabel = (minutes) => {
        if (minutes === null || minutes === undefined) return '-';
        if (minutes < 60) return `${minutes} menit`;
        const hours = Math.floor(minutes / 60);
        if (hours < 24) return `${hours} jam ${minutes % 60} menit`;
        return `${Math.floor(hours / 24)} hari ${hours % 24} jam`;
    };

    Alpine.store('sidebar', {
        collapsed: storage.get('medrive.sidebar.collapsed', false),
        mobileOpen: false,
        toggle() {
            this.collapsed = !this.collapsed;
            storage.set('medrive.sidebar.collapsed', this.collapsed);
        },
    });

    Alpine.store('toasts', {
        items: [],
        nextId: 1,
        timers: {},
        /**
         * key: toast dengan key sama menggantikan isi toast sebelumnya (mis. ronde eskalasi beruntun
         * untuk satu laporan) agar tidak menumpuk.
         */
        push({ title, message = '', tone = 'info', url = null, timeout = 6000, key = null }) {
            const existing = key ? this.items.find((item) => item.key === key) : null;
            const id = existing?.id ?? this.nextId++;
            if (existing) {
                Object.assign(existing, { title, message, tone, url });
                clearTimeout(this.timers[id]);
            } else {
                this.items.push({ id, key, title, message, tone, url });
            }
            if (timeout) {
                this.timers[id] = setTimeout(() => this.dismiss(id), timeout);
            }
            return Boolean(existing);
        },
        dismiss(id) {
            this.items = this.items.filter((item) => item.id !== id);
        },
    });

    window.toast = (options) => Alpine.store('toasts').push(options);

    // Pesan sukses dari halaman sebelumnya (mis. setelah simpan lalu redirect).
    try {
        const flash = sessionStorage.getItem('medrive.flash');
        if (flash) {
            sessionStorage.removeItem('medrive.flash');
            queueMicrotask(() => window.toast(JSON.parse(flash)));
        }
    } catch {
        // sessionStorage tidak tersedia
    }
    window.readableTextOn = readableTextOn;

    Alpine.data('clock', () => ({
        time: '',
        date: '',
        init() {
            const timeFormat = new Intl.DateTimeFormat('id-ID', {
                timeZone: 'Asia/Jakarta',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
                hour12: false,
            });
            const dateFormat = new Intl.DateTimeFormat('id-ID', {
                timeZone: 'Asia/Jakarta',
                weekday: 'short',
                day: 'numeric',
                month: 'short',
            });
            const tick = () => {
                const now = new Date();
                this.time = timeFormat.format(now).replaceAll('.', ':');
                this.date = dateFormat.format(now);
            };
            tick();
            setInterval(tick, 1000);
        },
    }));

    /**
     * Laporan yang broadcast-nya sudah diperluas (ronde >= 2) atau dialarmkan (semua ronde lewat).
     */
    Alpine.store('escalations', {
        items: [],
        loaded: false,
        url: null,

        get alarmCount() {
            return this.items.filter((item) => item.is_final).length;
        },

        async load() {
            if (!this.url) return;
            try {
                this.items = await getData(this.url, {}, { silent: true });
                this.loaded = true;
            } catch {
                // dicoba lagi pada polling berikutnya
            }
        },

        upsert(event) {
            const index = this.items.findIndex((item) => item.id === event.id);
            if (index === -1) this.items.unshift(event);
            else this.items[index] = { ...this.items[index], ...event };
        },

        remove(reportId) {
            this.items = this.items.filter((item) => item.id !== reportId);
        },
    });

    Alpine.data('notifications', ({ url, escalationsUrl }) => ({
        pendingCount: 0,
        lastReportId: null,
        open: false,
        loading: false,
        error: null,
        items: [],
        mode: 'polling',
        soundEnabled: storage.get('medrive.sound', true),

        async init() {
            Alpine.store('escalations').url = escalationsUrl;
            await Promise.all([this.poll(true), Alpine.store('escalations').load()]);

            subscribe({
                channel: 'admin',
                events: {
                    ReportCreated: (report) => {
                        this.pendingCount++;
                        this.lastReportId = Math.max(this.lastReportId ?? 0, report.id);
                        this.announce(report);
                    },
                    DispatchEscalated: (event) => this.announceEscalation(event),
                    ReportStatusChanged: (event) => {
                        if (event.from_status === 'menunggu') {
                            this.pendingCount = Math.max(0, this.pendingCount - 1);
                            Alpine.store('escalations').remove(event.id);
                        }
                        window.dispatchEvent(new CustomEvent('medrive:report-status', { detail: event }));
                    },
                },
                poll: () => this.poll(),
                onMode: (mode) => (this.mode = mode),
            });
        },

        async poll(initial = false) {
            try {
                const data = await getJson(
                    url,
                    initial || this.lastReportId === null ? {} : { after_id: this.lastReportId },
                );
                this.pendingCount = data.pending_count;
                if (!initial && this.lastReportId !== null) {
                    data.new_reports.forEach((report) => this.announce(report));
                }
                this.lastReportId = Math.max(this.lastReportId ?? 0, data.last_report_id);

                if (!initial) {
                    const before = new Map(Alpine.store('escalations').items.map((item) => [item.id, item]));
                    await Alpine.store('escalations').load();
                    Alpine.store('escalations')
                        .items.filter(
                            (item) =>
                                before.get(item.id)?.round !== item.round ||
                                before.get(item.id)?.is_final !== item.is_final,
                        )
                        .forEach((item) => this.announceEscalation(item, false));
                }
            } catch {
                // polling berikutnya akan mencoba lagi
            }
        },

        announce(report) {
            window.dispatchEvent(new CustomEvent('medrive:report-created', { detail: report }));
            window.toast({
                title: `Laporan baru ${report.code}`,
                message: `${report.type?.name ?? 'Laporan'} di ${report.address}`,
                tone: 'alert',
                url: report.url,
                timeout: 10000,
            });
            if (this.soundEnabled && Number(report.type?.priority) === 1) {
                beep();
            }
        },

        announceEscalation(event, updateStore = true) {
            if (updateStore) Alpine.store('escalations').upsert(event);
            window.dispatchEvent(new CustomEvent('medrive:escalated', { detail: event }));

            const radius = event.radius_km ? `radius ${event.radius_km} km` : 'seluruh area';
            const replaced = window.toast({
                key: `escalation-${event.id}`,
                title: event.is_final
                    ? `ALARM: ${event.code} belum diambil`
                    : `Eskalasi ${event.code} ke ronde ${event.round}`,
                message: event.is_final
                    ? `Semua ronde broadcast sudah lewat dan laporan masih menunggu (${event.waiting_minutes} menit).`
                    : `Broadcast diperluas ke ${radius}, ${event.recipients ?? 0} driver baru menerima tawaran.`,
                tone: event.is_final ? 'alarm' : 'alert',
                url: event.url,
                timeout: event.is_final ? 0 : 12000,
            });
            // Ronde beruntun untuk laporan yang sama cukup satu bunyi; alarm akhir selalu berbunyi.
            if (this.soundEnabled && (event.is_final || !replaced)) beep(event.is_final ? 3 : 1);
        },

        toggleSound() {
            this.soundEnabled = !this.soundEnabled;
            storage.set('medrive.sound', this.soundEnabled);
        },

        async toggle() {
            this.open = !this.open;
            if (!this.open) {
                return;
            }
            this.loading = true;
            this.error = null;
            try {
                const data = await getJson(url);
                this.pendingCount = data.pending_count;
                this.items = data.latest_pending;
            } catch (error) {
                this.error = error.message;
            } finally {
                this.loading = false;
            }
        },
    }));

    Alpine.data('copyText', () => ({
        copied: false,
        async copy(text) {
            try {
                await navigator.clipboard.writeText(text);
            } catch {
                const area = document.createElement('textarea');
                area.value = text;
                document.body.appendChild(area);
                area.select();
                document.execCommand('copy');
                area.remove();
            }
            this.copied = true;
            setTimeout(() => (this.copied = false), 2000);
        },
    }));

    Alpine.data('relativeTime', (iso) => ({
        label: '',
        init() {
            const format = new Intl.RelativeTimeFormat('id-ID', { numeric: 'auto' });
            const update = () => {
                const seconds = Math.round((new Date(iso).getTime() - Date.now()) / 1000);
                const abs = Math.abs(seconds);
                if (abs < 60) this.label = format.format(seconds, 'second');
                else if (abs < 3600) this.label = format.format(Math.round(seconds / 60), 'minute');
                else if (abs < 86400) this.label = format.format(Math.round(seconds / 3600), 'hour');
                else this.label = format.format(Math.round(seconds / 86400), 'day');
            };
            update();
            setInterval(update, 15000);
        },
    }));
}
