const csrfToken = () => document.querySelector('meta[name="csrf-token"]')?.content ?? '';

export class ApiError extends Error {
    constructor(status, code, message, details = {}) {
        super(message);
        this.status = status;
        this.code = code;
        this.details = details;
    }

    get isValidation() {
        return this.code === 'validation_failed';
    }
}

function buildUrl(url, params = {}) {
    const query = new URLSearchParams();
    Object.entries(params).forEach(([key, value]) => {
        if (value === null || value === undefined || value === '' || value === false) return;
        query.set(key, value === true ? '1' : value);
    });
    const qs = query.toString();
    return qs ? `${url}${url.includes('?') ? '&' : '?'}${qs}` : url;
}

/**
 * fetch ke /api/v1 dengan cookie session (Sanctum stateful), header CSRF, dan format error baku.
 * Error 4xx/5xx selain validasi otomatis ditampilkan sebagai toast kecuali silent: true.
 */
export async function apiFetch(url, { method = 'GET', body = null, params = {}, silent = false } = {}) {
    const headers = {
        Accept: 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-TOKEN': csrfToken(),
    };

    let payload = body;
    let httpMethod = method.toUpperCase();

    if (body instanceof FormData) {
        // PHP hanya membaca multipart pada POST; PUT/PATCH dikirim lewat method spoofing.
        if (!['GET', 'POST'].includes(httpMethod)) {
            body.set('_method', httpMethod);
            httpMethod = 'POST';
        }
    } else if (body !== null) {
        headers['Content-Type'] = 'application/json';
        payload = JSON.stringify(body);
    }

    let response;
    try {
        response = await fetch(buildUrl(url, params), {
            method: httpMethod,
            headers,
            body: payload,
            credentials: 'same-origin',
        });
    } catch {
        const error = new ApiError(
            0,
            'network_error',
            'Tidak dapat terhubung ke server. Periksa koneksi lalu coba lagi.',
        );
        if (!silent) window.toast?.({ title: error.message, tone: 'error' });
        throw error;
    }

    if (response.status === 204) return null;

    let json = null;
    try {
        json = await response.json();
    } catch {
        // respons bukan JSON (mis. halaman error server)
    }

    if (!response.ok || json?.success === false) {
        if (response.status === 401 || response.status === 419) {
            window.location.href = '/admin/login';
        }
        const error = new ApiError(
            response.status,
            json?.error?.code ?? 'http_error',
            json?.error?.message ?? `Permintaan gagal (HTTP ${response.status}).`,
            json?.error?.details ?? {},
        );
        if (!silent && !error.isValidation) window.toast?.({ title: error.message, tone: 'error', timeout: 9000 });
        throw error;
    }

    return json;
}

/** Ambil data (isi "data" dari amplop respons). */
export async function getData(url, params = {}, options = {}) {
    return (await apiFetch(url, { params, ...options }))?.data;
}

export { buildUrl };
