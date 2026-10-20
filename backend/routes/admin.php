<?php

use App\Http\Controllers\Admin\AdminPageController as Page;
use App\Http\Controllers\Admin\Auth\LoginController;
use App\Http\Controllers\Admin\Auth\PasswordController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Dashboard Admin Medrive (prefix /admin, nama route admin.*)
|--------------------------------------------------------------------------
| Login tetap memakai session web. Halaman lain hanya kerangka Blade: data dibaca
| dan ditulis Alpine.js lewat /api/v1/admin dengan cookie session yang sama.
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
        Route::get('/', [Page::class, 'dashboard'])->name('dashboard');

        Route::get('drivers', [Page::class, 'drivers'])->name('drivers.index');
        Route::get('drivers/create', [Page::class, 'createDriver'])->name('drivers.create');
        Route::get('drivers/{driver}', [Page::class, 'showDriver'])->name('drivers.show');
        Route::get('drivers/{driver}/edit', [Page::class, 'editDriver'])->name('drivers.edit');

        Route::get('institutions', [Page::class, 'institutions'])->name('institutions.index');
        Route::get('institutions/create', [Page::class, 'institutionForm'])->name('institutions.create');
        Route::get('institutions/{institution}/edit', [Page::class, 'institutionForm'])->name('institutions.edit');

        Route::get('clinics', [Page::class, 'clinics'])->name('clinics.index');
        Route::get('clinics/create', [Page::class, 'clinicForm'])->name('clinics.create');
        Route::get('clinics/{clinic}/edit', [Page::class, 'clinicForm'])->name('clinics.edit');

        Route::get('ambulances', [Page::class, 'ambulances'])->name('ambulances.index');
        Route::get('ambulances/create', [Page::class, 'ambulanceForm'])->name('ambulances.create');
        Route::get('ambulances/{ambulance}/edit', [Page::class, 'ambulanceForm'])->name('ambulances.edit');

        Route::get('ambulance-types', [Page::class, 'ambulanceTypes'])->name('ambulance-types.index');
        Route::get('ambulance-types/{ambulance_type}/edit', [Page::class, 'editAmbulanceType'])->name('ambulance-types.edit');

        Route::get('report-types', [Page::class, 'reportTypes'])->name('report-types.index');
        Route::get('report-types/{report_type}/edit', [Page::class, 'editReportType'])->name('report-types.edit');

        Route::get('reports', [Page::class, 'reports'])->name('reports.index');
        Route::get('reports/{report}', [Page::class, 'showReport'])->name('reports.show');

        Route::get('tracking', [Page::class, 'tracking'])->name('tracking.index');
        Route::get('location-logs', [Page::class, 'locationLogs'])->name('location-logs.index');
        Route::get('statistics', [Page::class, 'statistics'])->name('statistics.index');
        Route::get('activity-logs', [Page::class, 'activityLogs'])->name('activity-logs.index');
        Route::get('users', [Page::class, 'reporters'])->name('users.index');
        Route::get('users/{reporter}', [Page::class, 'showReporter'])->name('users.show');
    });
});
