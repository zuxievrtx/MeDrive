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

window.Alpine = Alpine;
Alpine.plugin(focus);

registerShell(Alpine);
registerForms(Alpine);
registerMaps(Alpine);
registerStatistics(Alpine);

Alpine.start();
