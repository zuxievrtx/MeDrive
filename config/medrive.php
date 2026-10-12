<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Dashboard Admin Medrive
    |--------------------------------------------------------------------------
    */

    // Laporan menunggu lebih lama dari ini (menit) disorot di daftar laporan.
    'stale_pending_minutes' => 10,

    // SIM / sertifikat dianggap "akan kedaluwarsa" dalam rentang hari ini.
    'expiry_warning_days' => 60,

    // Driver tanpa update lokasi lebih lama dari ini (detik) dianggap "sinyal hilang".
    'signal_lost_seconds' => 60,

    // Retensi driver_location_logs (hari); rentang Log Lokasi tidak boleh melebihi ini.
    'location_log_retention_days' => 14,

    // Interval polling cadangan bila websocket Reverb tidak tersambung (milidetik).
    'poll_interval_ms' => 10000,

    // ambulance_types tidak punya kolom ikon; ikon marker peta dipetakan dari kode jenis.
    'ambulance_type_icons' => [
        'gawat_darurat' => 'truck-medical',
        'transport' => 'van-shuttle',
        'jenazah' => 'car-side',
        'default' => 'truck-medical',
    ],

];
