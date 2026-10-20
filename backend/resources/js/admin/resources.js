import { apiFetch, getData } from './api';

/**
 * Pemetaan data API -> nilai form edit, per jenis sumber daya.
 */
const formMappers = {
    driver: (driver) => ({
        name: driver.name,
        phone: driver.phone,
        email: driver.email,
        clinic_id: driver.driver_profile?.clinic_id ?? '',
        employee_number: driver.driver_profile?.employee_number ?? '',
        license_number: driver.driver_profile?.license_number ?? '',
        license_class: driver.driver_profile?.license_class?.value ?? '',
        license_expires_at: driver.driver_profile?.license_expires_at ?? '',
        photo_url: driver.driver_profile?.photo_url ?? null,
    }),
    institution: (institution) => ({ ...institution, type: institution.type?.value ?? '' }),
    clinic: (clinic) => ({ ...clinic, type: clinic.type?.value ?? 'klinik' }),
    ambulance: (ambulance) => ({
        ...ambulance,
        status: ambulance.status?.value ?? 'tersedia',
        year: ambulance.year ?? '',
    }),
    ambulanceType: (type) => ({ ...type }),
    reportType: (type) => ({
        ...type,
        color: type.color ?? '#57534E',
        ambulance_type_ids: (type.ambulance_types ?? []).map((item) => String(item.id)),
    }),
};

function readQuery(keys) {
    const query = new URLSearchParams(window.location.search);
    return Object.fromEntries(keys.filter((key) => query.has(key)).map((key) => [key, query.get(key)]));
}

function getPath(object, path) {
    return path.split('.').reduce((value, key) => value?.[key], object);
}

export function registerResources(Alpine) {
    /**
     * Data dropdown (klinik, instansi, jenis, status) dari /admin/options.
     */
    Alpine.data('adminOptions', (only = '') => ({
        options: {},
        optionsLoaded: false,
        async init() {
            try {
                this.options = await getData('/api/v1/admin/options', { only }, { silent: true });
            } catch {
                window.toast?.({ title: 'Pilihan filter gagal dimuat. Muat ulang halaman.', tone: 'error' });
            } finally {
                this.optionsLoaded = true;
            }
        },
    }));

    /**
     * Daftar paginated dari API. Filter tersinkron ke query string agar bisa dibagikan/di-refresh.
     */
    Alpine.data('apiList', ({ url, filters = {}, syncUrl = true, refreshOn = [], autoload = true }) => ({
        url,
        defaults: { ...filters },
        filters: { ...filters },
        page: 1,
        rows: [],
        meta: null,
        loading: autoload,
        error: null,

        init() {
            if (syncUrl) {
                Object.assign(this.filters, readQuery(Object.keys(this.defaults)));
                this.page = Number(new URLSearchParams(window.location.search).get('page') || 1);
            }
            if (autoload) this.load();
            [...refreshOn, 'medrive:refresh'].forEach((name) => window.addEventListener(name, () => this.load(true)));
        },

        async load(quiet = false) {
            if (!quiet) this.loading = true;
            this.error = null;
            try {
                const body = await apiFetch(this.url, {
                    params: { ...this.filters, page: this.page > 1 ? this.page : null },
                    silent: true,
                });
                this.rows = body.data ?? [];
                this.meta = body.meta ?? null;
                if (this.pagination && this.page > this.pagination.last_page && this.pagination.last_page > 0) {
                    this.page = this.pagination.last_page;
                    return this.load(quiet);
                }
                this.syncQuery();
            } catch (error) {
                this.error = error.isValidation
                    ? (Object.values(error.details).flat()[0] ?? error.message)
                    : error.message;
            } finally {
                this.loading = false;
            }
        },

        syncQuery() {
            if (!syncUrl) return;
            const query = new URLSearchParams();
            Object.entries(this.filters).forEach(([key, value]) => {
                if (
                    value !== '' &&
                    value !== null &&
                    value !== undefined &&
                    value !== false &&
                    value !== this.defaults[key]
                ) {
                    query.set(key, value);
                }
            });
            if (this.page > 1) query.set('page', this.page);
            const qs = query.toString();
            history.replaceState(null, '', `${window.location.pathname}${qs ? `?${qs}` : ''}`);
        },

        apply() {
            this.page = 1;
            this.load();
        },

        resetFilters() {
            this.filters = { ...this.defaults };
            this.apply();
        },

        goTo(page) {
            if (!this.pagination || page < 1 || page > this.pagination.last_page || page === this.page) return;
            this.page = page;
            this.load();
            this.$el.scrollIntoView?.({ block: 'start', behavior: 'smooth' });
        },

        sortBy(column) {
            const isSame = this.filters.sort === column;
            this.filters.sort = column;
            this.filters.direction = isSame && this.filters.direction === 'asc' ? 'desc' : 'asc';
            this.apply();
        },

        sortIcon(column) {
            if (this.filters.sort !== column) return 'fa-sort text-stone-400';
            return this.filters.direction === 'desc' ? 'fa-sort-down' : 'fa-sort-up';
        },

        get pagination() {
            return this.meta?.pagination ?? null;
        },

        get isEmpty() {
            return !this.loading && !this.error && this.rows.length === 0;
        },

        get pageNumbers() {
            const last = this.pagination?.last_page ?? 1;
            const current = this.page;
            const pages = new Set(
                [1, last, current - 1, current, current + 1].filter((page) => page >= 1 && page <= last),
            );
            const sorted = [...pages].sort((a, b) => a - b);
            return sorted.flatMap((page, index) =>
                index > 0 && page - sorted[index - 1] > 1 ? ['...', page] : [page],
            );
        },

        get rangeLabel() {
            const p = this.pagination;
            if (!p || p.total === 0) return '';
            const from = (p.current_page - 1) * p.per_page + 1;
            return `Menampilkan ${from} sampai ${Math.min(p.current_page * p.per_page, p.total)} dari ${p.total} data`;
        },

        exportUrl(base) {
            const query = new URLSearchParams(
                Object.entries(this.filters).filter(
                    ([, value]) => value !== '' && value !== null && value !== undefined,
                ),
            );
            return `${base}${query.toString() ? `?${query}` : ''}`;
        },
    }));

    /**
     * Form create/edit ke API. Kirim FormData dari elemen form (berkas ikut), tampilkan error per field.
     */
    Alpine.data(
        'apiForm',
        ({
            url,
            method = 'POST',
            loadUrl = null,
            mapper = null,
            initial = {},
            redirect = null,
            idPath = 'id',
            successMessage = 'Data tersimpan.',
            rememberCredentials = false,
        }) => ({
            form: { ...initial },
            errors: {},
            submitting: false,
            loading: Boolean(loadUrl),
            loadError: null,

            async init() {
                if (!loadUrl) return;
                try {
                    const data = await getData(loadUrl, {}, { silent: true });
                    this.form = { ...this.form, ...(mapper ? formMappers[mapper](data) : data) };
                } catch (error) {
                    this.loadError = error.message;
                } finally {
                    this.loading = false;
                }
            },

            error(name) {
                return this.errors[name]?.[0] ?? null;
            },

            get errorCount() {
                return Object.keys(this.errors).length;
            },

            async submit(event) {
                const element = this.$refs.form ?? event?.target;
                this.errors = {};
                this.submitting = true;
                try {
                    const body = await apiFetch(url, { method, body: new FormData(element) });
                    const data = body?.data ?? {};
                    const id = getPath(data, idPath);

                    if (rememberCredentials && data.credentials && id) {
                        try {
                            sessionStorage.setItem(`medrive.credentials.${id}`, JSON.stringify(data.credentials));
                        } catch {
                            // sessionStorage tidak tersedia: kredensial ditampilkan lewat toast saja
                            window.toast?.({
                                title: `Password sementara: ${data.credentials.password}`,
                                tone: 'info',
                                timeout: 0,
                            });
                        }
                    }

                    this.flash(successMessage);
                    if (redirect) {
                        window.location.href = redirect.replace(':id', id ?? '');
                    } else {
                        window.toast?.({ title: successMessage, tone: 'success' });
                        this.$dispatch('form-saved', data);
                    }
                } catch (error) {
                    if (error.isValidation) {
                        this.errors = error.details;
                        window.toast?.({
                            title: `Periksa kembali isian (${this.errorCount} belum valid).`,
                            tone: 'error',
                        });
                        this.$nextTick(() =>
                            element
                                .querySelector('[aria-invalid="true"], .form-error:not([style*="display: none"])')
                                ?.scrollIntoView({ block: 'center', behavior: 'smooth' }),
                        );
                    }
                } finally {
                    this.submitting = false;
                }
            },

            flash(message) {
                try {
                    sessionStorage.setItem('medrive.flash', JSON.stringify({ title: message, tone: 'success' }));
                } catch {
                    // flash dilewati bila sessionStorage tidak tersedia
                }
            },
        }),
    );
}

/**
 * Aksi tunggal (hapus, nonaktifkan, batalkan) ke API dengan toast hasil.
 */
export async function apiAction(url, { method = 'POST', body = null, successMessage = 'Berhasil disimpan.' } = {}) {
    const result = await apiFetch(url, { method, body });
    window.toast?.({ title: successMessage, tone: 'success' });
    window.dispatchEvent(new CustomEvent('medrive:refresh'));
    return result?.data ?? null;
}
