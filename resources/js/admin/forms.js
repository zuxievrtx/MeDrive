import { loadLeaflet, createMap, pinIcon } from './maps';

const PASSWORD_CHARS = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';

function randomPassword(length = 12) {
    const values = new Uint32Array(length);
    crypto.getRandomValues(values);
    return Array.from(values, (value) => PASSWORD_CHARS[value % PASSWORD_CHARS.length]).join('');
}

export function registerForms(Alpine) {
    Alpine.data('passwordField', (initial = '') => ({
        password: initial,
        visible: false,
        generate() {
            this.password = randomPassword();
            this.visible = true;
        },
    }));

    Alpine.data('photoPreview', (initialUrl = null) => ({
        previewUrl: initialUrl,
        tooLarge: false,
        pick(event) {
            const [file] = event.target.files;
            this.tooLarge = Boolean(file && file.size > 2 * 1024 * 1024);
            this.previewUrl = file && !this.tooLarge ? URL.createObjectURL(file) : initialUrl;
        },
    }));

    /**
     * Pemilih titik klinik. Membaca/menulis form.latitude & form.longitude milik apiForm induk.
     */
    Alpine.data('clinicPicker', () => {
        let map = null;
        let marker = null;
        let centered = false;

        return {
            ready: false,
            // Bukan "error": nama itu milik apiForm (pesan error per field) di scope induk.
            mapError: null,

            async init() {
                try {
                    const L = await loadLeaflet();
                    // Titik awal default: pusat Kota Semarang (wilayah data contoh).
                    const center = [-6.9932, 110.4203];
                    map = createMap(L, this.$refs.map, { center, zoom: 12 });
                    marker = L.marker(center, { draggable: true, icon: pinIcon(L, '#b30000', 'house-medical') });
                    marker.on('dragend', () => this.setFromLatLng(marker.getLatLng()));
                    map.on('click', (event) => this.setFromLatLng(event.latlng));
                    this.ready = true;
                    this.syncFromForm(this.form.latitude, this.form.longitude);
                } catch {
                    this.mapError = 'Peta gagal dimuat. Koordinat tetap bisa diisi manual.';
                }
            },

            setFromLatLng({ lat, lng }) {
                this.form.latitude = lat.toFixed(7);
                this.form.longitude = lng.toFixed(7);
            },

            syncFromForm(latitude, longitude) {
                const lat = Number(latitude);
                const lng = Number(longitude);
                if (
                    !marker ||
                    latitude === '' ||
                    latitude === null ||
                    longitude === '' ||
                    longitude === null ||
                    Number.isNaN(lat) ||
                    Number.isNaN(lng)
                ) {
                    return;
                }
                marker.setLatLng([lat, lng]);
                if (!map.hasLayer(marker)) marker.addTo(map);
                if (!centered) {
                    map.setView([lat, lng], 16);
                    centered = true;
                }
            },
        };
    });

    /**
     * Konfirmasi sebelum menyimpan perubahan jenis ambulans penerima broadcast.
     */
    Alpine.data('ambulanceTypeChecklist', () => ({
        initialTypes: null,
        confirmOpen: false,

        init() {
            this.$watch('loading', (loading) => {
                if (!loading) this.initialTypes = [...(this.form.ambulance_type_ids ?? [])].sort().join(',');
            });
        },

        changed() {
            return [...(this.form.ambulance_type_ids ?? [])].sort().join(',') !== this.initialTypes;
        },

        confirmOrSubmit(event) {
            if (this.changed() && !this.confirmOpen) {
                this.confirmOpen = true;
                return;
            }
            this.confirmOpen = false;
            this.submit(event);
        },
    }));
}
