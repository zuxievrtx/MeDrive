<?php

/*
 * Halaman admin kini hanya kerangka Blade; data dimuat Alpine dari /api/v1/admin (diuji di
 * tests/Feature/Api/AdminApiTest.php). Test ini memastikan setiap kerangka terender, menunjuk ke
 * endpoint API yang benar, dan route model binding menolak id dengan role yang salah.
 */

beforeEach(function () {
    $this->admin = seedDemoAndGetAdmin();
});

it('renders every admin page shell', function (string $routeName, array $parameters, string $apiPath) {
    $html = $this->actingAs($this->admin)->get(route($routeName, $parameters))->assertOk()->getContent();

    // URL dari @js() ditulis dengan garis miring ter-escape (\/api\/v1\/...).
    expect(str_replace('\\/', '/', $html))->toContain($apiPath);
})->with([
    'dashboard' => ['admin.dashboard', [], '/api/v1/admin/dashboard/summary'],
    'drivers' => ['admin.drivers.index', [], '/api/v1/admin/drivers'],
    'driver create' => ['admin.drivers.create', [], '/api/v1/admin/drivers'],
    'driver edit' => ['admin.drivers.edit', ['driver' => 3], '/api/v1/admin/drivers/3'],
    'driver profil' => ['admin.drivers.show', ['driver' => 4, 'tab' => 'profil'], '/api/v1/admin/drivers/4'],
    'driver lokasi' => ['admin.drivers.show', ['driver' => 4, 'tab' => 'lokasi'], '/api/v1/admin/drivers/4'],
    'institutions' => ['admin.institutions.index', [], '/api/v1/admin/institutions'],
    'institution create' => ['admin.institutions.create', [], '/api/v1/admin/institutions'],
    'institution edit' => ['admin.institutions.edit', ['institution' => 1], '/api/v1/admin/institutions/1'],
    'clinics' => ['admin.clinics.index', [], '/api/v1/admin/clinics'],
    'clinic create' => ['admin.clinics.create', [], '/api/v1/admin/clinics'],
    'clinic edit' => ['admin.clinics.edit', ['clinic' => 1], '/api/v1/admin/clinics/1'],
    'ambulances' => ['admin.ambulances.index', [], '/api/v1/admin/ambulances'],
    'ambulance create' => ['admin.ambulances.create', [], '/api/v1/admin/ambulances'],
    'ambulance edit' => ['admin.ambulances.edit', ['ambulance' => 1], '/api/v1/admin/ambulances/1'],
    'ambulance types' => ['admin.ambulance-types.index', [], '/api/v1/admin/ambulance-types'],
    'ambulance type edit' => ['admin.ambulance-types.edit', ['ambulance_type' => 1], '/api/v1/admin/ambulance-types/1'],
    'report types' => ['admin.report-types.index', [], '/api/v1/admin/report-types'],
    'report type edit' => ['admin.report-types.edit', ['report_type' => 3], '/api/v1/admin/report-types/3'],
    'reports' => ['admin.reports.index', [], '/api/v1/admin/reports'],
    'report detail' => ['admin.reports.show', ['report' => 3], '/api/v1/admin/reports/3'],
    'tracking' => ['admin.tracking.index', [], '/api/v1/admin/tracking/live'],
    'location logs' => ['admin.location-logs.index', [], '/api/v1/admin/location-logs'],
    'statistics' => ['admin.statistics.index', [], '/api/v1/admin/statistics'],
    'activity logs' => ['admin.activity-logs.index', [], '/api/v1/admin/activity-logs'],
    'reporters' => ['admin.users.index', [], '/api/v1/admin/users'],
    'reporter detail' => ['admin.users.show', ['reporter' => 1], '/api/v1/admin/users/1'],
]);

it('renders the password page with a server-side form', function () {
    $this->actingAs($this->admin)->get(route('admin.password.edit'))->assertOk()->assertSee(route('admin.password.update'), escape: false);
});

it('does not resolve drivers, reporters or reports through the wrong route', function () {
    $this->actingAs($this->admin)->get(route('admin.drivers.show', 1))->assertNotFound();
    $this->actingAs($this->admin)->get(route('admin.users.show', 3))->assertNotFound();
    $this->actingAs($this->admin)->get(route('admin.reports.show', 999))->assertNotFound();
});
