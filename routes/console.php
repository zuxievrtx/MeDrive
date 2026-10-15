<?php

use App\Models\DriverLocationLog;
use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Buffer lokasi -> bulk insert log + snapshot + broadcast.
Schedule::command('medrive:flush-locations')->everyTenSeconds()->withoutOverlapping();

// Eskalasi broadcast laporan yang masih menunggu.
Schedule::command('medrive:escalate-dispatches')->everyMinute()->withoutOverlapping();

// Retensi driver_location_logs 14 hari.
Schedule::command('model:prune', ['--model' => [DriverLocationLog::class]])->dailyAt('01:30');
