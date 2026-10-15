import Alpine from 'alpinejs';
import focus from '@alpinejs/focus';
import '@fortawesome/fontawesome-free/css/fontawesome.css';
import '@fortawesome/fontawesome-free/css/solid.css';

/**
 * Echo exposes an expressive API for subscribing to channels and listening
 * for events that are broadcast by Laravel. Echo and event broadcasting
 * allow your team to quickly build robust real-time web applications.
 */
import './echo';

import { registerShell } from './admin/shell';
import { registerForms } from './admin/forms';
import { registerMaps } from './admin/maps';
import { registerStatistics } from './admin/statistics';
import { registerResources, apiAction } from './admin/resources';
import { apiFetch, getData } from './admin/api';
import { registerPages } from './admin/pages';

window.Alpine = Alpine;
Alpine.plugin(focus);

registerShell(Alpine);
registerForms(Alpine);
registerMaps(Alpine);
registerStatistics(Alpine);
registerResources(Alpine);
registerPages(Alpine);

// Dipakai ekspresi Alpine di template untuk aksi satu klik (hapus, aktifkan, batalkan).
window.medrive = { api: apiFetch, action: apiAction, getData };

Alpine.start();
