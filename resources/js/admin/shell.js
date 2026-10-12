import { getJson } from './http';
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

function beep() {
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

export function registerShell(Alpine) {
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
        push({ title, message = '', tone = 'info', url = null, timeout = 6000 }) {
            const id = this.nextId++;
            this.items.push({ id, title, message, tone, url });
            if (timeout) {
                setTimeout(() => this.dismiss(id), timeout);
            }
        },
        dismiss(id) {
            this.items = this.items.filter((item) => item.id !== id);
        },
    });

    window.toast = (options) => Alpine.store('toasts').push(options);
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

    Alpine.data('notifications', ({ url, pendingCount, lastReportId }) => ({
        pendingCount,
        lastReportId,
        open: false,
        loading: false,
        error: null,
        items: [],
        mode: 'polling',
        soundEnabled: storage.get('medrive.sound', true),

        init() {
            subscribe({
                channel: 'admin.reports',
                event: 'ReportCreated',
                onEvent: (report) => {
                    this.pendingCount++;
                    this.lastReportId = Math.max(this.lastReportId, report.id);
                    this.announce(report);
                },
                poll: () => this.poll(),
                onMode: (mode) => (this.mode = mode),
            });
        },

        async poll() {
            try {
                const data = await getJson(url, { after_id: this.lastReportId });
                this.pendingCount = data.pending_count;
                data.new_reports.forEach((report) => {
                    this.lastReportId = Math.max(this.lastReportId, report.id);
                    this.announce(report);
                });
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
