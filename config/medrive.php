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

    /*
    |--------------------------------------------------------------------------
    | Dispatch & eskalasi
    |--------------------------------------------------------------------------
    | Ronde broadcast: radius (km) per ronde, null = seluruh area. Ronde berikutnya
    | hanya dikirim ke driver yang belum pernah menerima broadcast laporan tersebut.
    */
    'dispatch' => [
        'radius_rounds_km' => [5, 10, 15, null],

        // Jeda antar ronde (detik) per prioritas jenis laporan; jenis tidak darurat (terjadwal) memakai "scheduled".
        'round_interval_seconds' => [
            'priority' => [1 => 60, 2 => 120],
            'default' => 180,
            'scheduled' => 300,
        ],

        // Laporan menunggu yang diproses job eskalasi per menit (laporan lama di luar ini dianggap sudah dialarmkan).
        'escalation_lookback_hours' => 24,
    ],

    /*
    |--------------------------------------------------------------------------
    | Pipeline lokasi adaptif
    |--------------------------------------------------------------------------
    | Interval ping ditentukan server lewat next_interval_seconds di respons POST /driver/location.
    */
    'location' => [
        'interval_seconds' => [
            'on_duty' => 5,
            'standby' => 25,
            'stationary' => 60,
        ],
        'stationary_speed_kmh' => 2,
        'stationary_consecutive_points' => 2,
        'low_battery_percent' => 20,
        'low_battery_multiplier' => 2,
        // Aplikasi boleh mengirim lebih cepat bila sudah berpindah sejauh ini saat standby.
        'distance_filter_m' => 50,
        'max_batch_points' => 10,
        'max_batch_age_seconds' => 15,
        'snapshot_min_seconds' => 15,
        'broadcast_min_seconds' => 5,
        // Cache posisi terbaru per driver untuk fallback polling pelapor.
        'reporter_poll_cache_seconds' => 5,
    ],

    /*
    |--------------------------------------------------------------------------
    | Firebase Cloud Messaging (HTTP v1)
    |--------------------------------------------------------------------------
    | Kosongkan kredensial untuk mode log-only (notifikasi hanya dicatat di log).
    */
    'fcm' => [
        'project_id' => env('FCM_PROJECT_ID'),
        'client_email' => env('FCM_CLIENT_EMAIL'),
        'private_key' => env('FCM_PRIVATE_KEY'),
    ],

    // Kode jenis laporan => tabel detail (accident/medical/maternity/funeral).
    'report_detail_tables' => [
        'kecelakaan' => 'accident',
        'medis_darurat' => 'medical',
        'ibu_hamil' => 'maternity',
        'pengantaran_jenazah' => 'funeral',
    ],

    // Lampiran laporan dari aplikasi: maksimal jumlah dan ukuran per foto (KB).
    'attachments' => [
        'max_files' => 5,
        'max_kb' => 2048,
    ],

];
