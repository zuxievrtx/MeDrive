<?php

use App\Http\Controllers\Admin\ActivityLogController;
use App\Http\Controllers\Admin\AmbulanceController;
use App\Http\Controllers\Admin\AmbulanceTypeController;
use App\Http\Controllers\Admin\Auth\LoginController;
use App\Http\Controllers\Admin\Auth\PasswordController;
use App\Http\Controllers\Admin\ClinicController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\DriverCertificationController;
use App\Http\Controllers\Admin\DriverController;
use App\Http\Controllers\Admin\DriverShiftController;
use App\Http\Controllers\Admin\InstitutionController;
use App\Http\Controllers\Admin\LocationLogController;
use App\Http\Controllers\Admin\NotificationController;
use App\Http\Controllers\Admin\ReportController;
use App\Http\Controllers\Admin\ReporterController;
use App\Http\Controllers\Admin\ReportTypeController;
use App\Http\Controllers\Admin\StatisticsController;
use App\Http\Controllers\Admin\TrackingController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Dashboard Admin Medrive (prefix /admin, nama route admin.*)
|--------------------------------------------------------------------------
| Tidak ada route registrasi driver, pembuatan laporan, atau penugasan manual:
| driver hanya didaftarkan admin, laporan dibuat pelapor, penugasan lewat broadcast.
*/

Route::middleware('guest')->group(function () {
    Route::get('login', [LoginController::class, 'create'])->name('login');
    Route::post('login', [LoginController::class, 'store'])->middleware('throttle:admin-login')->name('login.store');
});

Route::middleware(['auth', 'role:admin'])->group(function () {
    Route::post('logout', [LoginController::class, 'destroy'])->name('logout');
    Route::get('password', [PasswordController::class, 'edit'])->name('password.edit');
    Route::put('password', [PasswordController::class, 'update'])->name('password.update');

    Route::middleware('password.changed')->group(function () {
        Route::get('/', DashboardController::class)->name('dashboard');
        Route::get('notifications', NotificationController::class)->name('notifications');

        // Manajemen driver
        Route::get('drivers/{driver}/photo', [DriverController::class, 'photo'])->name('drivers.photo');
        Route::patch('drivers/{driver}/account-status', [DriverController::class, 'toggleStatus'])->name('drivers.account-status');
        Route::resource('drivers', DriverController::class)->except('destroy');
        Route::post('drivers/{driver}/certifications', [DriverCertificationController::class, 'store'])->name('drivers.certifications.store');
        Route::put('certifications/{certification}', [DriverCertificationController::class, 'update'])->name('certifications.update');
        Route::delete('certifications/{certification}', [DriverCertificationController::class, 'destroy'])->name('certifications.destroy');
        Route::get('certifications/{certification}/file', [DriverCertificationController::class, 'file'])->name('certifications.file');
        Route::post('shifts/{shift}/end', [DriverShiftController::class, 'end'])->name('shifts.end');

        // Armada
        Route::patch('ambulances/{ambulance}/status', [AmbulanceController::class, 'updateStatus'])->name('ambulances.status');
        Route::resource('ambulances', AmbulanceController::class)->except('show');
        Route::resource('ambulance-types', AmbulanceTypeController::class)->only(['index', 'edit', 'update']);

        // Organisasi
        Route::resource('institutions', InstitutionController::class)->except('show');
        Route::resource('clinics', ClinicController::class)->except('show');

        // Master jenis laporan
        Route::resource('report-types', ReportTypeController::class)->only(['index', 'edit', 'update']);

        // Monitoring laporan
        Route::get('reports/export', [ReportController::class, 'export'])->name('reports.export');
        Route::get('reports/{report}/attachments/{attachment}', [ReportController::class, 'attachment'])
            ->scopeBindings()
            ->name('reports.attachments.show');
        Route::post('reports/{report}/cancel', [ReportController::class, 'cancel'])->name('reports.cancel');
        Route::resource('reports', ReportController::class)->only(['index', 'show']);

        // Peta live & log lokasi
        Route::get('tracking', [TrackingController::class, 'index'])->name('tracking.index');
        Route::get('tracking/data', [TrackingController::class, 'data'])->name('tracking.data');
        Route::get('location-logs', [LocationLogController::class, 'index'])->name('location-logs.index');
        Route::get('location-logs/data', [LocationLogController::class, 'data'])->name('location-logs.data');

        // Statistik
        Route::get('statistics', [StatisticsController::class, 'index'])->name('statistics.index');
        Route::get('statistics/data', [StatisticsController::class, 'data'])->name('statistics.data');
        Route::get('statistics/export', [StatisticsController::class, 'export'])->name('statistics.export');

        // Sistem
        Route::get('activity-logs', ActivityLogController::class)->name('activity-logs.index');
        Route::patch('users/{reporter}/account-status', [ReporterController::class, 'toggleStatus'])->name('users.account-status');
        Route::get('users', [ReporterController::class, 'index'])->name('users.index');
        Route::get('users/{reporter}', [ReporterController::class, 'show'])->name('users.show');
    });
});
