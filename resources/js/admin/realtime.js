const POLL_INTERVAL = Number(document.querySelector('meta[name="poll-interval"]')?.content || 10000);

/**
 * Berlangganan event privat Reverb; bila websocket tidak tersedia/terputus, jalankan polling
 * setiap 10 detik sampai koneksi pulih. onMode menerima 'realtime' atau 'polling' untuk indikator UI.
 *
 * events: { NamaEvent: handler } atau gunakan event + onEvent untuk satu event.
 */
export function subscribe({ channel, event, onEvent, events = {}, poll, onMode = () => {} }) {
    let timer = null;
    const handlers = event ? { ...events, [event]: onEvent } : events;

    const startPolling = () => {
        if (timer || !poll) {
            return;
        }
        onMode('polling');
        timer = setInterval(poll, POLL_INTERVAL);
    };

    const stopPolling = () => {
        if (timer) {
            clearInterval(timer);
            timer = null;
        }
        onMode('realtime');
    };

    if (!window.Echo) {
        startPolling();
        return () => clearInterval(timer);
    }

    const privateChannel = window.Echo.private(channel);
    Object.entries(handlers).forEach(([name, handler]) => privateChannel.listen(`.${name}`, handler));
    privateChannel.error?.(() => startPolling());

    const connection = window.Echo.connector?.pusher?.connection;
    if (connection) {
        const sync = (state) => (state === 'connected' ? stopPolling() : startPolling());
        connection.bind('state_change', ({ current }) => sync(current));
        sync(connection.state);
    }

    return () => {
        clearInterval(timer);
        window.Echo.leave(channel);
    };
}
