import { getData } from './api';

/**
 * Kompatibilitas modul lama: mengembalikan isi "data" dari respons API v1.
 */
export async function getJson(url, params = {}) {
    return getData(url, params, { silent: true });
}
