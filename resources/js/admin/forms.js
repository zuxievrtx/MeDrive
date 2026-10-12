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

    Alpine.data('clinicPicker', ({ lat, lng }) => {
        let map = null;
        let marker = null;

        return {
            lat: lat ?? '',
            lng: lng ?? '',
            ready: false,
            error: null,

            async init() {
                try {
                    const L = await loadLeaflet();
                    const hasPoint = this.lat !== '' && this.lng !== '';
                    // Titik awal default: pusat Kota Semarang (wilayah data contoh).
                    const center = hasPoint ? [Number(this.lat), Number(this.lng)] : [-6.9932, 110.4203];
                    map = createMap(L, this.$refs.map, { center, zoom: hasPoint ? 16 : 12 });
                    marker = L.marker(center, { draggable: true, icon: pinIcon(L, '#b30000', 'house-medical') });
                    if (hasPoint) {
                        marker.addTo(map);
                    }
                    marker.on('dragend', () => this.setFromLatLng(marker.getLatLng()));
                    map.on('click', (event) => this.setFromLatLng(event.latlng));
                    this.$watch('lat', () => this.syncMarker());
                    this.$watch('lng', () => this.syncMarker());
                    this.ready = true;
                } catch (error) {
                    this.error = 'Peta gagal dimuat. Koordinat tetap bisa diisi manual.';
                }
            },

            setFromLatLng({ lat, lng }) {
                this.lat = lat.toFixed(7);
                this.lng = lng.toFixed(7);
            },

            syncMarker() {
                const lat = Number(this.lat);
                const lng = Number(this.lng);
                if (!marker || Number.isNaN(lat) || Number.isNaN(lng) || this.lat === '' || this.lng === '') {
                    return;
                }
                marker.setLatLng([lat, lng]);
                if (!map.hasLayer(marker)) {
                    marker.addTo(map);
                }
            },
        };
    });

    Alpine.data('ambulanceTypeChecklist', (initial) => ({
        initial: [...initial].map(String).sort().join(','),
        confirmOpen: false,
        changed() {
            const current = [...this.$root.querySelectorAll('input[name="ambulance_type_ids[]"]:checked')]
                .map((input) => input.value)
                .sort()
                .join(',');
            return current !== this.initial;
        },
        submit(event) {
            if (this.changed() && !this.confirmOpen) {
                event.preventDefault();
                this.confirmOpen = true;
            }
        },
        confirm() {
            this.confirmOpen = false;
            this.$root.querySelector('form').submit();
        },
    }));
}
