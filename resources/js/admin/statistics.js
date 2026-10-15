import { getJson } from './http';

const BRAND = '#b30000';
const BRAND_SOFT = '#e88585';
const BRAND_MID = '#d14545';
const STATUS_COLORS = {
    menunggu: '#d97706',
    diambil: '#2563eb',
    dalam_perjalanan: '#7c3aed',
    tiba_di_lokasi: '#0891b2',
    mengantar_pasien: '#0d9488',
    selesai: '#16a34a',
    dibatalkan: '#78716c',
};

let chartPromise = null;

function loadChart() {
    chartPromise ??= import('chart.js/auto').then((module) => {
        const Chart = module.default ?? module.Chart;
        Chart.defaults.font.family = getComputedStyle(document.body).fontFamily;
        Chart.defaults.color = '#57534e';
        Chart.defaults.borderColor = '#e7e5e4';
        Chart.defaults.plugins.legend.labels.boxWidth = 12;
        Chart.defaults.maintainAspectRatio = false;
        return Chart;
    });
    return chartPromise;
}

const percent = (value, total) => (total ? `${((value / total) * 100).toFixed(1)}%` : '0%');

function trendChart() {
    let chart = null;
    return {
        error: null,
        empty: false,
        init() {
            // Data tren datang dari ringkasan dashboard (fetch API), bukan dari render server.
            window.addEventListener('medrive:dashboard-trend', (event) => this.draw(event.detail));
        },
        async draw({ labels, current, previous }) {
            this.empty = current.every((value) => value === 0);
            try {
                const Chart = await loadChart();
                if (chart) {
                    chart.data.labels = labels;
                    chart.data.datasets[0].data = current;
                    chart.data.datasets[1].data = previous;
                    chart.update();
                    return;
                }
                chart = new Chart(this.$refs.canvas, {
                    type: 'line',
                    data: {
                        labels,
                        datasets: [
                            {
                                label: '14 hari terakhir',
                                data: current,
                                borderColor: BRAND,
                                backgroundColor: 'rgba(179, 0, 0, 0.08)',
                                fill: true,
                                tension: 0,
                                pointRadius: 3,
                            },
                            {
                                label: '14 hari sebelumnya',
                                data: previous,
                                borderColor: BRAND_SOFT,
                                borderDash: [6, 4],
                                pointRadius: 0,
                                tension: 0,
                            },
                        ],
                    },
                    options: {
                        interaction: { mode: 'index', intersect: false },
                        scales: { y: { beginAtZero: true, ticks: { precision: 0 } } },
                    },
                });
            } catch {
                this.error = 'Grafik gagal dimuat.';
            }
        },
        destroy() {
            chart?.destroy();
        },
    };
}

/**
 * Halaman Statistik: semua grafik diisi dari satu endpoint JSON agar rentang bisa diganti tanpa reload.
 */
function localDate(date) {
    return date.toLocaleDateString('sv-SE', { timeZone: 'Asia/Jakarta' });
}

/**
 * Rentang awal dari query string (bisa dibagikan), default 7 hari terakhir.
 */
function initialRange(ranges) {
    const query = new URLSearchParams(window.location.search);
    const now = new Date();
    return {
        range: ranges.includes(query.get('range')) ? query.get('range') : '7d',
        year: Number(query.get('year')) || now.getFullYear(),
        from: query.get('from') || localDate(new Date(now.getTime() - 13 * 86400000)),
        to: query.get('to') || localDate(now),
    };
}

function statisticsPage({ dataUrl, exportUrl, ranges }) {
    const charts = {};
    const initial = initialRange(ranges);

    return {
        range: initial.range,
        year: initial.year,
        from: initial.from,
        to: initial.to,
        loading: true,
        error: null,
        data: null,
        orgMode: 'clinic',

        async init() {
            await this.load();
        },

        params() {
            const params = { range: this.range };
            if (this.range === 'year') params.year = this.year;
            if (this.range === 'custom') {
                params.from = this.from;
                params.to = this.to;
            }
            return params;
        },

        get exportHref() {
            return `${exportUrl}?${new URLSearchParams(this.params())}`;
        },

        setRange(range) {
            this.range = range;
            if (range !== 'custom') this.load();
        },

        async load() {
            this.loading = true;
            this.error = null;
            try {
                this.data = await getJson(dataUrl, this.params());
                const query = new URLSearchParams(this.params());
                history.replaceState(null, '', `${location.pathname}?${query}`);
                await this.$nextTick();
                await this.render();
            } catch (error) {
                this.error = error.isValidation
                    ? (Object.values(error.details).flat()[0] ?? error.message)
                    : error.message;
            } finally {
                this.loading = false;
            }
        },

        isEmpty() {
            return !this.data || this.data.summary.total.value === 0;
        },

        async render() {
            const Chart = await loadChart();
            const d = this.data;
            const draw = (key, config) => {
                charts[key]?.destroy();
                const canvas = this.$refs[key];
                if (canvas) charts[key] = new Chart(canvas, config);
            };

            draw('volume', {
                data: {
                    labels: d.labels,
                    datasets: [
                        {
                            type: 'bar',
                            label: 'Periode ini',
                            data: d.series.current,
                            backgroundColor: BRAND,
                            borderRadius: 3,
                            order: 2,
                        },
                        {
                            type: 'line',
                            label: 'Periode sebelumnya',
                            data: d.series.previous,
                            borderColor: BRAND_SOFT,
                            borderDash: [6, 4],
                            pointRadius: 0,
                            tension: 0,
                            order: 1,
                        },
                    ],
                },
                options: {
                    interaction: { mode: 'index', intersect: false },
                    scales: { y: { beginAtZero: true, ticks: { precision: 0 } } },
                },
            });

            const typeTotal = d.by_type.reduce((sum, type) => sum + type.total, 0);
            draw('types', {
                type: 'doughnut',
                data: {
                    labels: d.by_type.map((type) => `${type.name} (${percent(type.total, typeTotal)})`),
                    datasets: [
                        {
                            data: d.by_type.map((type) => type.total),
                            backgroundColor: d.by_type.map((type) => type.color),
                            borderWidth: 2,
                        },
                    ],
                },
                options: { cutout: '62%', plugins: { legend: { position: 'bottom' } } },
            });

            draw('typeSeries', {
                type: 'bar',
                data: {
                    labels: d.labels,
                    datasets: d.by_type_series.map((type) => ({
                        label: type.name,
                        data: type.data,
                        backgroundColor: type.color,
                    })),
                },
                options: {
                    scales: { x: { stacked: true }, y: { stacked: true, beginAtZero: true, ticks: { precision: 0 } } },
                },
            });

            draw('response', {
                type: 'line',
                data: {
                    labels: d.labels,
                    datasets: [
                        {
                            label: 'Laporan dibuat sampai diambil',
                            data: d.response_times.taken,
                            borderColor: BRAND,
                            backgroundColor: BRAND,
                            spanGaps: true,
                            tension: 0,
                        },
                        {
                            label: 'Diambil sampai tiba di lokasi',
                            data: d.response_times.arrived,
                            borderColor: '#44403c',
                            backgroundColor: '#44403c',
                            spanGaps: true,
                            tension: 0,
                        },
                    ],
                },
                options: {
                    interaction: { mode: 'index', intersect: false },
                    scales: { y: { beginAtZero: true, title: { display: true, text: 'menit' } } },
                },
            });

            draw('drivers', {
                type: 'bar',
                data: {
                    labels: d.top_drivers.map((driver) => driver.name),
                    datasets: [
                        {
                            label: 'Laporan ditangani',
                            data: d.top_drivers.map((driver) => driver.reports),
                            backgroundColor: BRAND_MID,
                            borderRadius: 3,
                        },
                    ],
                },
                options: {
                    indexAxis: 'y',
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            callbacks: {
                                afterLabel: (item) => {
                                    const driver = d.top_drivers[item.dataIndex];
                                    return `Rasio menang broadcast: ${driver.win_ratio ?? '-'}% (${driver.won} diambil, ${driver.lost} kalah cepat/diabaikan)`;
                                },
                            },
                        },
                    },
                    scales: { x: { beginAtZero: true, ticks: { precision: 0 } } },
                },
            });

            this.renderOrg(Chart);

            draw('hours', {
                type: 'bar',
                data: {
                    labels: Array.from({ length: 24 }, (_, hour) => String(hour).padStart(2, '0')),
                    datasets: [
                        {
                            label: 'Laporan',
                            data: d.by_hour,
                            backgroundColor: d.by_hour.map((value) =>
                                value === Math.max(...d.by_hour) && value > 0 ? BRAND : BRAND_SOFT,
                            ),
                            borderRadius: 2,
                        },
                    ],
                },
                options: {
                    plugins: { legend: { display: false } },
                    scales: { y: { beginAtZero: true, ticks: { precision: 0 } } },
                },
            });

            const statusTotal = d.by_status.reduce((sum, status) => sum + status.total, 0);
            draw('statuses', {
                type: 'pie',
                data: {
                    labels: d.by_status.map((status) => `${status.label} (${percent(status.total, statusTotal)})`),
                    datasets: [
                        {
                            data: d.by_status.map((status) => status.total),
                            backgroundColor: d.by_status.map((status) => STATUS_COLORS[status.status]),
                            borderWidth: 2,
                        },
                    ],
                },
                options: { plugins: { legend: { display: false } } },
            });
        },

        async renderOrg(Chart = null) {
            Chart ??= await loadChart();
            const rows = this.orgMode === 'clinic' ? this.data.by_clinic : this.data.by_institution;
            charts.org?.destroy();
            charts.org = new Chart(this.$refs.org, {
                type: 'bar',
                data: {
                    labels: rows.map((row) => row.name),
                    datasets: [
                        {
                            label: 'Laporan',
                            data: rows.map((row) => row.total),
                            backgroundColor: BRAND,
                            borderRadius: 3,
                        },
                    ],
                },
                options: {
                    plugins: { legend: { display: false } },
                    scales: { y: { beginAtZero: true, ticks: { precision: 0 } } },
                },
            });
        },
    };
}

export function statusColor(status) {
    return STATUS_COLORS[status];
}

export function registerStatistics(Alpine) {
    window.statusColor = statusColor;
    Alpine.data('trendChart', trendChart);
    Alpine.data('statisticsPage', statisticsPage);
}
