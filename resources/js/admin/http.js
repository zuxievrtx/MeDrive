/**
 * fetch() JSON dengan header Laravel (CSRF + X-Requested-With) dan pesan galat yang bisa ditampilkan.
 */
export async function getJson(url, params = {}) {
    const query = new URLSearchParams(
        Object.entries(params).filter(([, value]) => value !== null && value !== undefined && value !== ''),
    );
    const target = query.toString() ? `${url}${url.includes('?') ? '&' : '?'}${query}` : url;

    const response = await fetch(target, {
        headers: {
            Accept: 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
        },
        credentials: 'same-origin',
    });

    if (!response.ok) {
        let message = `Gagal memuat data (HTTP ${response.status}).`;
        try {
            const body = await response.json();
            message = body.message || message;
        } catch {
            // respons bukan JSON, pakai pesan default
        }
        throw new Error(message);
    }

    return response.json();
}
