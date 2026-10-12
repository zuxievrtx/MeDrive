<?php

use App\Models\Report;

/*
 * Setiap halaman admin dirender dengan data contoh ERD v3 (Andi & Rina shift terbuka,
 * laporan #3 dalam perjalanan, laporan #4 menunggu). Lazy loading dimatikan di luar produksi,
 * jadi test ini juga menangkap N+1 yang terlewat.
 */

beforeEach(function () {
    $this->admin = seedDemoAndGetAdmin();
});

it('renders the dashboard with the demo data', function () {
    $this->actingAs($this->admin)
        ->get(route('admin.dashboard'))
        ->assertOk()
        ->assertSee('MDR-261009-0002')
        ->assertSee('Laporan menunggu driver')
        ->assertSee('Ibu Hamil');
});

it('renders every admin page', function (string $routeName, array $parameters = []) {
    $this->actingAs($this->admin)->get(route($routeName, $parameters))->assertOk();
})->with([
    'drivers' => ['admin.drivers.index'],
    'drivers filtered' => ['admin.drivers.index', ['shift' => 'aktif', 'sort' => 'clinic', 'direction' => 'desc', 'q' => 'a']],
    'driver create' => ['admin.drivers.create'],
    'driver edit' => ['admin.drivers.edit', ['driver' => 3]],
    'driver profil' => ['admin.drivers.show', ['driver' => 4, 'tab' => 'profil']],
    'driver sertifikat' => ['admin.drivers.show', ['driver' => 4, 'tab' => 'sertifikat']],
    'driver shift' => ['admin.drivers.show', ['driver' => 4, 'tab' => 'shift']],
    'driver laporan' => ['admin.drivers.show', ['driver' => 4, 'tab' => 'laporan']],
    'driver lokasi' => ['admin.drivers.show', ['driver' => 4, 'tab' => 'lokasi']],
    'driver lokasi tanpa data' => ['admin.drivers.show', ['driver' => 5, 'tab' => 'lokasi']],
    'institutions' => ['admin.institutions.index'],
    'institution create' => ['admin.institutions.create'],
    'institution edit' => ['admin.institutions.edit', ['institution' => 1]],
    'clinics' => ['admin.clinics.index'],
    'clinic create' => ['admin.clinics.create'],
    'clinic edit' => ['admin.clinics.edit', ['clinic' => 1]],
    'ambulances' => ['admin.ambulances.index'],
    'ambulance create' => ['admin.ambulances.create'],
    'ambulance edit' => ['admin.ambulances.edit', ['ambulance' => 1]],
    'ambulance types' => ['admin.ambulance-types.index'],
    'ambulance type edit' => ['admin.ambulance-types.edit', ['ambulance_type' => 1]],
    'report types' => ['admin.report-types.index'],
    'report type edit' => ['admin.report-types.edit', ['report_type' => 3]],
    'reports' => ['admin.reports.index'],
    'reports filtered' => ['admin.reports.index', ['status' => 'menunggu', 'type' => 3, 'from' => '2026-10-01', 'to' => '2026-10-31', 'clinic_id' => 1, 'q' => 'MDR']],
    'tracking' => ['admin.tracking.index'],
    'location logs empty' => ['admin.location-logs.index'],
    'location logs for report' => ['admin.location-logs.index', ['driver_id' => 4, 'report_id' => 3]],
    'statistics' => ['admin.statistics.index'],
    'activity logs' => ['admin.activity-logs.index'],
    'activity logs filtered' => ['admin.activity-logs.index', ['module' => 'driver', 'admin_id' => 6]],
    'reporters' => ['admin.users.index'],
    'reporter detail' => ['admin.users.show', ['reporter' => 1]],
    'password' => ['admin.password.edit'],
]);

it('renders the detail page of every demo report', function () {
    foreach (Report::query()->pluck('code', 'id') as $id => $code) {
        $this->actingAs($this->admin)->get(route('admin.reports.show', $id))->assertOk()->assertSee($code);
    }
});

it('shows report type specific details', function () {
    $this->actingAs($this->admin)->get(route('admin.reports.show', 1))->assertSee('Detail kecelakaan')->assertSee('Jalan tertutup');
    $this->actingAs($this->admin)->get(route('admin.reports.show', 2))->assertSee('Alm. Bapak Sutrisno');
    $this->actingAs($this->admin)->get(route('admin.reports.show', 3))->assertSee('Riwayat hipertensi')->assertSee('Kalah cepat');
    $this->actingAs($this->admin)->get(route('admin.reports.show', 4))->assertSee('39 minggu')->assertSee('Puskesmas Tembalang');
});

it('does not resolve drivers or reporters through the wrong route', function () {
    $this->actingAs($this->admin)->get(route('admin.drivers.show', 1))->assertNotFound();
    $this->actingAs($this->admin)->get(route('admin.users.show', 3))->assertNotFound();
});

it('serves the notification badge data', function () {
    $this->actingAs($this->admin)
        ->getJson(route('admin.notifications', ['after_id' => 3]))
        ->assertOk()
        ->assertJsonPath('pending_count', 1)
        ->assertJsonPath('new_reports.0.code', 'MDR-261009-0002')
        ->assertJsonPath('latest_pending.0.type.color', '#2F6F6A');
});
