import Echo from 'laravel-echo';

import Pusher from 'pusher-js';
window.Pusher = Pusher;

// Tanpa kunci Reverb (mis. lingkungan demo tanpa server websocket) Echo tidak dibuat dan
// semua halaman otomatis memakai polling AJAX sebagai cadangan.
window.Echo = import.meta.env.VITE_REVERB_APP_KEY
    ? new Echo({
          broadcaster: 'reverb',
          key: import.meta.env.VITE_REVERB_APP_KEY,
          wsHost: import.meta.env.VITE_REVERB_HOST,
          wsPort: import.meta.env.VITE_REVERB_PORT ?? 80,
          wssPort: import.meta.env.VITE_REVERB_PORT ?? 443,
          forceTLS: (import.meta.env.VITE_REVERB_SCHEME ?? 'https') === 'https',
          enabledTransports: ['ws', 'wss'],
      })
    : null;
