import { getData } from './api';
import { apiAction } from './resources';

function debounce(fn, wait = 800) {
    let timer = null;
    return (...args) => {
        clearTimeout(timer);
        timer = setTimeout(() => fn(...args), wait);
    };
}

export function registerPages(Alpine) {
    /**
     * Beranda: ringkasan dari /admin/dashboard/summary, dimuat ulang saat ada laporan baru / status berubah.
     */
    Alpine.data('dashboardPage', ({ url }) => ({
        data: null,
        loading: true,
        error: null,

        init() {
            this.load();
            const refresh = debounce(() => this.load(true));
            ['medrive:report-created', 'medrive:report-status', 'medrive:escalated'].forEach((name) =>
                window.addEventListener(name, refresh),
            );
        },

        async load(quiet = false) {
            if (!quiet) this.loading = true;
            try {
                this.data = await getData(url, {}, { silent: true });
                this.error = null;
                window.dispatchEvent(new CustomEvent('medrive:dashboard-trend', { detail: this.data.trend }));
            } catch (error) {
                this.error = error.message;
            } finally {
                this.loading = false;
            }
        },

        delta(card, higherIsBetter = false) {
            if (!card) return { label: '', tone: '' };
            if (card.value === card.previous) return { label: 'sama', tone: 'text-stone-700', icon: 'fa-equals' };
            const up = card.value > card.previous;
            const good = higherIsBetter ? up : !up;
            return {
                label: `${up ? 'naik' : 'turun'} ${card.delta === null ? 'dari 0' : `${Math.abs(card.delta)}%`}`,
                tone: good ? 'text-green-700' : 'text-mr-700',
                icon: up ? 'fa-arrow-trend-up' : 'fa-arrow-trend-down',
            };
        },
    }));

    /**
     * Detail driver dengan tab (profil, sertifikat, shift, laporan, lokasi). Kredensial driver baru
     * dibaca sekali dari sessionStorage lalu dihapus.
     */
    Alpine.data('driverDetail', ({ url, driverId, tab }) => ({
        driver: null,
        loading: true,
        error: null,
        tab,
        credentials: null,
        copied: false,
        toggle: { open: false },
        endShift: { open: false },
        reset: { open: false, password: null, submitting: false },
        cert: { open: false, mode: 'create', url: null, data: {}, errors: {}, submitting: false },
        removeCert: { open: false, item: null },

        init() {
            try {
                const key = `medrive.credentials.${driverId}`;
                const stored = sessionStorage.getItem(key);
                if (stored) {
                    this.credentials = JSON.parse(stored);
                    sessionStorage.removeItem(key);
                }
            } catch {
                // sessionStorage tidak tersedia
            }
            this.load();
            this.$watch('tab', (value) => {
                const query = new URLSearchParams(window.location.search);
                query.set('tab', value);
                history.replaceState(null, '', `${window.location.pathname}?${query}`);
            });
        },

        async load() {
            try {
                this.driver = await getData(url, {}, { silent: true });
                this.error = null;
            } catch (error) {
                this.error = error.message;
            } finally {
                this.loading = false;
            }
        },

        get profile() {
            return this.driver?.driver_profile ?? {};
        },

        async copyCredentials() {
            const text = `Email: ${this.credentials.email}\nPassword: ${this.credentials.password}`;
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

        async toggleStatus() {
            const active = this.driver.account_status.value === 'aktif';
            try {
                this.driver = {
                    ...this.driver,
                    ...(await apiAction(`${url}/${active ? 'deactivate' : 'activate'}`, {
                        successMessage: active ? 'Akun driver dinonaktifkan.' : 'Akun driver diaktifkan kembali.',
                    })),
                };
                this.toggle.open = false;
            } catch (error) {
                if (error.code === 'driver_has_open_shift') {
                    this.toggle.open = false;
                    this.tab = 'shift';
                }
            }
        },

        async confirmEndShift() {
            try {
                await apiAction(`${url}/shifts/${this.driver.open_shift.id}/end`, {
                    successMessage: `Shift ${this.driver.name} telah diakhiri.`,
                });
                this.endShift.open = false;
                await this.load();
            } catch {
                // pesan error sudah ditampilkan apiFetch
            }
        },

        async resetPassword() {
            this.reset.submitting = true;
            try {
                const data = await apiAction(`${url}/reset-password`, { successMessage: 'Password driver direset.' });
                this.reset.password = data.credentials.password;
                this.credentials = data.credentials;
                this.reset.open = false;
                await this.load();
            } finally {
                this.reset.submitting = false;
            }
        },

        openCertForm(item = null) {
            this.cert = {
                open: true,
                mode: item ? 'edit' : 'create',
                url: item ? `/api/v1/admin/certifications/${item.id}` : `${url}/certifications`,
                data: item
                    ? { ...item }
                    : { name: '', certificate_number: '', issuer: '', issued_at: '', expires_at: '' },
                errors: {},
                submitting: false,
            };
        },

        async saveCert(event) {
            this.cert.submitting = true;
            this.cert.errors = {};
            try {
                await window.medrive.api(this.cert.url, {
                    method: this.cert.mode === 'edit' ? 'PUT' : 'POST',
                    body: new FormData(event.target),
                });
                window.toast({
                    title: this.cert.mode === 'edit' ? 'Sertifikat diperbarui.' : 'Sertifikat ditambahkan.',
                    tone: 'success',
                });
                this.cert.open = false;
                await this.load();
            } catch (error) {
                if (error.isValidation) this.cert.errors = error.details;
            } finally {
                this.cert.submitting = false;
            }
        },

        async deleteCert() {
            try {
                await apiAction(`/api/v1/admin/certifications/${this.removeCert.item.id}`, {
                    method: 'DELETE',
                    successMessage: 'Sertifikat dihapus.',
                });
                this.removeCert.open = false;
                await this.load();
            } catch {
                // pesan error sudah ditampilkan
            }
        },
    }));

    /**
     * Detail laporan untuk admin: semua relasi dari satu endpoint, diperbarui saat status berubah.
     */
    Alpine.data('reportDetail', ({ url, reportId }) => ({
        report: null,
        loading: true,
        error: null,
        cancel: { open: false, reason: '', errors: {}, submitting: false },
        lightbox: { open: false, src: '', caption: '' },

        init() {
            this.load();
            window.addEventListener('medrive:report-status', (event) => {
                if (event.detail.id === reportId) this.load(true);
            });
            window.addEventListener('medrive:escalated', (event) => {
                if (event.detail.id === reportId) this.load(true);
            });
        },

        async load(quiet = false) {
            if (!quiet) this.loading = true;
            try {
                this.report = await getData(url, {}, { silent: true });
                this.error = null;
                this.$nextTick(() =>
                    window.dispatchEvent(new CustomEvent('medrive:report-loaded', { detail: this.report })),
                );
            } catch (error) {
                this.error = error.message;
            } finally {
                this.loading = false;
            }
        },

        async submitCancel() {
            this.cancel.submitting = true;
            this.cancel.errors = {};
            try {
                await window.medrive.api(`${url}/cancel`, { method: 'POST', body: { reason: this.cancel.reason } });
                window.toast({ title: `Laporan ${this.report.code} dibatalkan.`, tone: 'success' });
                this.cancel.open = false;
                await this.load(true);
            } catch (error) {
                if (error.isValidation) this.cancel.errors = error.details;
                else this.cancel.open = false;
                if (error.code === 'report_not_cancellable') await this.load(true);
            } finally {
                this.cancel.submitting = false;
            }
        },

        yesNo(value) {
            return value === null || value === undefined ? 'Tidak diketahui' : value ? 'Ya' : 'Tidak';
        },
    }));

    /**
     * Aktif/nonaktifkan akun pelapor (PUT /admin/users/{id}). onSaved menerima data user terbaru.
     */
    Alpine.data('reporterToggle', () => ({
        toggle: { open: false, id: null, name: '', active: true, submitting: false },

        openToggle(user) {
            this.toggle = {
                open: true,
                id: user.id,
                name: user.name,
                active: user.account_status.value === 'aktif',
                submitting: false,
            };
        },

        async submitToggle() {
            this.toggle.submitting = true;
            try {
                const user = await apiAction(`/api/v1/admin/users/${this.toggle.id}`, {
                    method: 'PUT',
                    body: { account_status: this.toggle.active ? 'nonaktif' : 'aktif' },
                    successMessage: this.toggle.active
                        ? 'Akun pelapor dinonaktifkan.'
                        : 'Akun pelapor diaktifkan kembali.',
                });
                this.toggle.open = false;
                this.$dispatch('reporter-updated', user);
            } catch {
                // pesan error sudah ditampilkan apiFetch
            } finally {
                this.toggle.submitting = false;
            }
        },
    }));
}
