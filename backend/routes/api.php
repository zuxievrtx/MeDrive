<?php

use App\Http\Controllers\Api\V1\Admin;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\ChatController;
use App\Http\Controllers\Api\V1\Driver;
use App\Http\Controllers\Api\V1\GeocodeController;
use App\Http\Controllers\Api\V1\MediaController;
use App\Http\Controllers\Api\V1\Reporter;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Medrive v1 (/api/v1, nama route api.v1.*)
|--------------------------------------------------------------------------
| Tiga klien, satu service layer:
| - reporter: aplikasi Pelapor (token Sanctum, ability "reporter")
| - driver:   aplikasi Driver (token Sanctum, ability "driver")
| - admin:    dashboard Blade + Alpine (cookie session Sanctum SPA stateful)
| Tidak ada registrasi driver, pembuatan laporan oleh admin, penugasan manual,
| pembatalan oleh pelapor, maupun penutupan shift otomatis.
*/

Route::prefix('v1')->name('api.v1.')->group(function () {
    // Berkas privat dibuka lewat <img>/tautan, jadi tidak mewajibkan header Accept JSON.
    Route::get('media/{type}/{id}', MediaController::class)
        ->middleware(['auth:sanctum', 'throttle:api'])
        ->whereIn('type', ['driver-photo', 'certification', 'attachment', 'chat'])
        ->whereNumber('id')
        ->name('media');

    // Unduhan CSV dibuka sebagai berkas, jadi juga tanpa kewajiban header Accept JSON.
    Route::prefix('admin')->name('admin.')
        ->middleware(['auth:sanctum', 'role:admin', 'password.changed', 'throttle:api-admin'])
        ->group(function () {
            Route::get('reports/export', [Admin\ReportController::class, 'export'])->name('reports.export');
            Route::get('statistics/export', [Admin\StatisticsController::class, 'export'])->name('statistics.export');
        });

    Route::middleware('api.json')->group(function () {
        Route::prefix('auth')->name('auth.')->group(function () {
            Route::post('register', [AuthController::class, 'register'])->middleware('throttle:api-login')->name('register');
            Route::post('login', [AuthController::class, 'login'])->middleware('throttle:api-login')->name('login');

            Route::middleware(['auth:sanctum', 'role:pelapor,driver', 'throttle:api'])->group(function () {
                Route::post('logout', [AuthController::class, 'logout'])->name('logout');
                Route::post('fcm', [AuthController::class, 'registerDevice'])->name('fcm');
                Route::post('change-password', [AuthController::class, 'changePassword'])->name('change-password');
            });
        });

        Route::get('me', [AuthController::class, 'me'])->middleware(['auth:sanctum', 'role:pelapor,driver', 'throttle:api'])->name('me');

        // Proxy Nominatim untuk kedua aplikasi mobile (aplikasi dilarang memanggil Nominatim langsung).
        Route::prefix('geocode')->name('geocode.')
            ->middleware(['auth:sanctum', 'role:pelapor,driver', 'password.changed', 'throttle:api-geocode'])
            ->group(function () {
                Route::get('reverse', [GeocodeController::class, 'reverse'])->name('reverse');
                Route::get('search', [GeocodeController::class, 'search'])->name('search');
            });

        Route::prefix('reporter')->name('reporter.')
            ->middleware(['auth:sanctum', 'abilities:reporter', 'role:pelapor', 'password.changed'])
            ->group(function () {
                Route::post('reports', [Reporter\ReportController::class, 'store'])->middleware(['throttle:api-reports', 'idempotent'])->name('reports.store');

                Route::middleware('throttle:api')->group(function () {
                    Route::get('clinics', Reporter\ClinicController::class)->name('clinics');
                    Route::get('reports', [Reporter\ReportController::class, 'index'])->name('reports.index');
                    Route::get('reports/{report}', [Reporter\ReportController::class, 'show'])->name('reports.show');
                    Route::get('reports/{report}/driver-location', [Reporter\ReportController::class, 'driverLocation'])->name('reports.driver-location');
                    Route::get('reports/{report}/route', [Reporter\ReportController::class, 'route'])->name('reports.route');
                    Route::put('profile', Reporter\ProfileController::class)->name('profile.update');
                    Route::get('reports/{report}/chat', [ChatController::class, 'index'])->name('reports.chat.index');
                    Route::post('reports/{report}/chat/read', [ChatController::class, 'read'])->name('reports.chat.read');
                    Route::get('chat/unread-count', [ChatController::class, 'unreadCount'])->name('chat.unread-count');
                });

                Route::post('reports/{report}/chat', [ChatController::class, 'store'])->middleware('throttle:api-chat')->name('reports.chat.store');
            });

        Route::prefix('driver')->name('driver.')
            ->middleware(['auth:sanctum', 'abilities:driver', 'role:driver', 'password.changed'])
            ->group(function () {
                Route::post('location', Driver\LocationController::class)->middleware('throttle:api-location')->name('location');

                Route::middleware('throttle:api')->group(function () {
                    Route::get('profile', Driver\ProfileController::class)->name('profile');
                    Route::get('ambulances/available', Driver\AmbulanceController::class)->name('ambulances.available');
                    Route::post('shifts', [Driver\ShiftController::class, 'open'])->name('shifts.open');
                    Route::post('shifts/close', [Driver\ShiftController::class, 'close'])->name('shifts.close');
                    Route::get('dispatches/active', [Driver\DispatchController::class, 'active'])->name('dispatches.active');
                    Route::get('dispatches/{dispatch}', [Driver\DispatchController::class, 'show'])->name('dispatches.show');
                    Route::post('dispatches/{dispatch}/accept', [Driver\DispatchController::class, 'accept'])->middleware('idempotent')->name('dispatches.accept');
                    Route::get('reports/history', [Driver\ReportController::class, 'history'])->name('reports.history');
                    Route::get('reports/{report}', [Driver\ReportController::class, 'show'])->name('reports.show');
                    Route::post('reports/{report}/status', [Driver\ReportController::class, 'status'])->middleware('idempotent')->name('reports.status');
                    Route::post('reports/{report}/patients', [Driver\PatientController::class, 'store'])->name('reports.patients.store');
                    Route::put('patients/{patient}', [Driver\PatientController::class, 'update'])->name('patients.update');
                    Route::post('reports/{report}/attachments', Driver\AttachmentController::class)->name('reports.attachments.store');
                    Route::get('route', Driver\RouteController::class)->name('route');
                    Route::get('reports/{report}/chat', [ChatController::class, 'index'])->name('reports.chat.index');
                    Route::post('reports/{report}/chat/read', [ChatController::class, 'read'])->name('reports.chat.read');
                    Route::get('chat/unread-count', [ChatController::class, 'unreadCount'])->name('chat.unread-count');
                });

                Route::post('reports/{report}/chat', [ChatController::class, 'store'])->middleware('throttle:api-chat')->name('reports.chat.store');
            });

        Route::prefix('admin')->name('admin.')
            ->middleware(['auth:sanctum', 'role:admin', 'password.changed', 'throttle:api-admin'])
            ->group(function () {
                Route::get('dashboard/summary', Admin\DashboardController::class)->name('dashboard.summary');
                Route::get('notifications', Admin\NotificationController::class)->name('notifications');
                Route::get('escalations', Admin\EscalationController::class)->name('escalations');
                Route::get('options', Admin\OptionsController::class)->name('options');

                Route::get('drivers/{driver}/shifts', [Admin\DriverController::class, 'shifts'])->name('drivers.shifts');
                Route::get('drivers/{driver}/reports', [Admin\DriverController::class, 'reports'])->name('drivers.reports');
                Route::post('drivers/{driver}/reset-password', [Admin\DriverController::class, 'resetPassword'])->name('drivers.reset-password');
                Route::post('drivers/{driver}/deactivate', [Admin\DriverController::class, 'deactivate'])->name('drivers.deactivate');
                Route::post('drivers/{driver}/activate', [Admin\DriverController::class, 'activate'])->name('drivers.activate');
                Route::post('drivers/{driver}/shifts/{shift}/end', [Admin\DriverController::class, 'endShift'])->scopeBindings()->name('drivers.shifts.end');
                Route::post('drivers/{driver}/certifications', [Admin\DriverCertificationController::class, 'store'])->name('drivers.certifications.store');
                Route::apiResource('drivers', Admin\DriverController::class)->except('destroy');
                Route::put('certifications/{certification}', [Admin\DriverCertificationController::class, 'update'])->name('certifications.update');
                Route::delete('certifications/{certification}', [Admin\DriverCertificationController::class, 'destroy'])->name('certifications.destroy');

                Route::apiResource('institutions', Admin\InstitutionController::class);
                Route::apiResource('clinics', Admin\ClinicController::class);
                Route::apiResource('ambulance-types', Admin\AmbulanceTypeController::class)->only(['index', 'show', 'update']);
                Route::patch('ambulances/{ambulance}/status', [Admin\AmbulanceController::class, 'updateStatus'])->name('ambulances.status');
                Route::apiResource('ambulances', Admin\AmbulanceController::class);
                Route::apiResource('report-types', Admin\ReportTypeController::class)->only(['index', 'show', 'update']);

                Route::post('reports/{report}/cancel', [Admin\ReportController::class, 'cancel'])->name('reports.cancel');
                Route::apiResource('reports', Admin\ReportController::class)->only(['index', 'show']);

                Route::get('tracking/live', Admin\TrackingController::class)->name('tracking.live');
                Route::get('location-logs', [Admin\LocationLogController::class, 'route'])->name('location-logs');
                Route::get('location-logs/pings', [Admin\LocationLogController::class, 'pings'])->name('location-logs.pings');
                Route::get('statistics', [Admin\StatisticsController::class, 'index'])->name('statistics');
                Route::get('activity-logs', Admin\ActivityLogController::class)->name('activity-logs');
                Route::apiResource('users', Admin\ReporterController::class)->only(['index', 'show', 'update'])->parameters(['users' => 'reporter']);
            });
    });
});
