<?php

use App\Enums\AmbulanceStatus;
use App\Enums\ReportStatus;
use App\Enums\ShiftEndReason;
use App\Models\AdminActivityLog;
use App\Models\Ambulance;
use App\Models\DriverLastLocation;
use App\Models\DriverLocationLog;
use App\Models\DriverProfile;
use App\Models\DriverShift;
use App\Models\Institution;
use App\Models\Report;
use App\Models\ReportAttachment;
use App\Models\ReportStatusLog;
use App\Models\ReportType;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

beforeEach(function () {
    Storage::fake('local');
    $this->admin = seedDemoAndGetAdmin();
    $this->actingAs($this->admin);
});

function driverPayload(array $overrides = []): array
{
    return array_merge([
        'name' => 'Joko Susilo',
        'phone' => '081234567899',
        'email' => 'Joko@Medrive.test',
        'password' => 'sementara123',
        'must_change_password' => '1',
        'clinic_id' => 1,
        'employee_number' => 'PKM-0099',
        'license_number' => '1234-5678-000099',
        'license_class' => 'A_umum',
        'license_expires_at' => now()->addYear()->toDateString(),
    ], $overrides);
}

it('serves every admin read endpoint with the standard envelope', function (string $uri, ?string $path = 'data') {
    $response = $this->getJson($uri)->assertOk()->assertJsonPath('success', true);

    if ($path) {
        expect($response->json($path))->not->toBeNull();
    }
})->with([
    'dashboard' => ['/api/v1/admin/dashboard/summary', 'data.cards'],
    'notifications' => ['/api/v1/admin/notifications', 'data.pending_count'],
    'escalations' => ['/api/v1/admin/escalations'],
    'options' => ['/api/v1/admin/options', 'data.clinics'],
    'drivers' => ['/api/v1/admin/drivers?shift=aktif&sort=clinic&direction=desc', 'meta.summary'],
    'driver' => ['/api/v1/admin/drivers/4', 'data.driver_profile'],
    'driver shifts' => ['/api/v1/admin/drivers/4/shifts', 'meta.pagination'],
    'driver reports' => ['/api/v1/admin/drivers/4/reports', 'meta.pagination'],
    'institutions' => ['/api/v1/admin/institutions', 'meta.pagination'],
    'institution' => ['/api/v1/admin/institutions/1', 'data.clinics_count'],
    'clinics' => ['/api/v1/admin/clinics?institution_id=1', 'data.0.institution'],
    'ambulance types' => ['/api/v1/admin/ambulance-types', 'data.0.report_types'],
    'ambulances' => ['/api/v1/admin/ambulances', 'data.0.in_use'],
    'report types' => ['/api/v1/admin/report-types', 'data.0.ambulance_types'],
    'reports' => ['/api/v1/admin/reports?status=menunggu&q=MDR', 'data.0.code'],
    'report' => ['/api/v1/admin/reports/3', 'data.dispatches'],
    'tracking' => ['/api/v1/admin/tracking/live', 'data.drivers'],
    'location route' => ['/api/v1/admin/location-logs?driver_id=4&report_id=3', 'data.summary'],
    'location pings' => ['/api/v1/admin/location-logs/pings?driver_id=4&report_id=3', 'data.0.recorded_at'],
    'statistics' => ['/api/v1/admin/statistics?range=year&year=2026', 'data.by_type'],
    'activity logs' => ['/api/v1/admin/activity-logs?module=driver', 'data.0.action'],
    'reporters' => ['/api/v1/admin/users', 'data.0.reports_made_count'],
    'reporter' => ['/api/v1/admin/users/1', 'data.devices'],
]);

it('shows demo data correctly on the dashboard summary', function () {
    $this->getJson('/api/v1/admin/dashboard/summary')
        ->assertOk()
        ->assertJsonPath('data.cards.pending_reports.value', 1)
        ->assertJsonPath('data.cards.active_reports.value', 1)
        ->assertJsonPath('data.cards.fleet.drivers', 2)
        ->assertJsonPath('data.cards.fleet.available', 1)
        ->assertJsonPath('data.latest_pending.0.code', 'MDR-261009-0002');
});

it('returns report type specific details for every demo report', function () {
    $this->getJson('/api/v1/admin/reports/1')->assertJsonPath('data.details.kind', 'kecelakaan')->assertJsonPath('data.details.is_road_blocked', true);
    $this->getJson('/api/v1/admin/reports/2')->assertJsonPath('data.details.kind', 'jenazah')->assertJsonPath('data.details.deceased_name', 'Alm. Bapak Sutrisno');
    $this->getJson('/api/v1/admin/reports/3')->assertJsonPath('data.details.kind', 'medis')->assertJsonPath('data.dispatches.1.response.label', 'Kalah cepat');
    $this->getJson('/api/v1/admin/reports/4')
        ->assertJsonPath('data.details.kind', 'ibu_hamil')
        ->assertJsonPath('data.details.gestational_age_weeks', 39)
        ->assertJsonPath('data.is_cancellable', true);
});

it('serves the notification badge data', function () {
    $this->getJson('/api/v1/admin/notifications?after_id=3')
        ->assertOk()
        ->assertJsonPath('data.pending_count', 1)
        ->assertJsonPath('data.new_reports.0.code', 'MDR-261009-0002')
        ->assertJsonPath('data.latest_pending.0.type.color', '#2F6F6A');
});

it('includes battery and mock flags from the snapshot in live tracking', function () {
    DriverLastLocation::query()->whereKey(4)->update(['battery_level' => 17, 'is_mock_location' => true]);

    $drivers = collect($this->getJson('/api/v1/admin/tracking/live')->json('data.drivers'))->keyBy('driver_id');

    expect($drivers[4]['battery_level'])->toBe(17)->and($drivers[4]['is_mock_location'])->toBeTrue();
});

it('registers a driver in one transaction and returns the credentials once', function () {
    $response = $this->post('/api/v1/admin/drivers', driverPayload([
        'photo' => UploadedFile::fake()->image('joko.jpg'),
        'certifications' => [[
            'name' => 'BTCLS',
            'issued_at' => now()->subYear()->toDateString(),
            'expires_at' => now()->addYears(4)->toDateString(),
            'file' => UploadedFile::fake()->create('btcls.pdf', 120, 'application/pdf'),
        ]],
    ]), ['Accept' => 'application/json']);

    $response->assertCreated()
        ->assertJsonPath('data.credentials.email', 'joko@medrive.test')
        ->assertJsonPath('data.credentials.password', 'sementara123')
        ->assertJsonPath('data.driver.must_change_password', true);

    $driver = User::query()->where('email', 'joko@medrive.test')->firstOrFail();
    expect($driver->driverProfile->created_by)->toBe($this->admin->id)
        ->and($driver->certifications)->toHaveCount(1);
    Storage::disk('local')->assertExists($driver->driverProfile->photo_path);

    $log = AdminActivityLog::query()->where('action', 'driver.created')->latest('id')->first();
    expect($log->description)->toBe('Mendaftarkan driver Joko Susilo (Puskesmas Tembalang)')
        ->and($log->subject_type)->toBe('users');

    $this->getJson("/api/v1/admin/drivers/{$driver->id}")->assertOk()->assertJsonMissing(['password' => 'sementara123']);
});

it('validates driver registration rules', function (array $overrides, string $field) {
    $this->postJson('/api/v1/admin/drivers', driverPayload($overrides))
        ->assertStatus(400)
        ->assertJsonValidationErrors($field, 'error.details');
})->with([
    'duplicate email' => [['email' => 'andi@medrive.test'], 'email'],
    'employee number taken in same clinic' => [['employee_number' => 'PKM-0007'], 'employee_number'],
    'license expiring today' => [['license_expires_at' => now()->toDateString()], 'license_expires_at'],
    'unknown license class' => [['license_class' => 'C'], 'license_class'],
    'short password' => [['password' => 'pendek'], 'password'],
]);

it('updates a driver and logs the changed fields', function () {
    $this->putJson('/api/v1/admin/drivers/3', [
        'name' => 'Andi Prasetyo',
        'phone' => '081234567803',
        'email' => 'andi.baru@medrive.test',
        'clinic_id' => 2,
        'employee_number' => 'PMI-0012',
        'license_number' => '1234-5678-000001',
        'license_class' => 'B1_umum',
        'license_expires_at' => '2028-03-14',
    ])->assertOk()->assertJsonPath('data.email', 'andi.baru@medrive.test');

    expect(AdminActivityLog::query()->where('action', 'driver.updated')->latest('id')->value('description'))
        ->toContain('license_class: A_umum -> B1_umum');
});

it('resets a driver password and revokes the driver tokens', function () {
    $driver = User::query()->findOrFail(5);
    $driver->createToken('hp', ['driver']);

    $password = $this->postJson('/api/v1/admin/drivers/5/reset-password')->assertOk()->json('data.credentials.password');

    expect(strlen($password))->toBe(12)
        ->and($driver->fresh()->must_change_password)->toBeTrue()
        ->and($driver->tokens()->count())->toBe(0)
        ->and(AdminActivityLog::query()->where('action', 'driver.password_reset')->exists())->toBeTrue();
});

it('blocks deactivating a driver with an open shift', function () {
    $this->postJson('/api/v1/admin/drivers/3/deactivate')
        ->assertStatus(409)
        ->assertJsonPath('error.code', 'driver_has_open_shift');

    $this->postJson('/api/v1/admin/drivers/5/deactivate')->assertOk()->assertJsonPath('data.account_status.value', 'nonaktif');
    $this->postJson('/api/v1/admin/drivers/5/activate')->assertOk()->assertJsonPath('data.account_status.value', 'aktif');
});

it('ends an open shift as admin and refuses closed ones', function () {
    $this->postJson('/api/v1/admin/drivers/3/shifts/2/end')->assertOk()->assertJsonPath('data.end_reason.value', 'dihentikan_admin');
    expect(DriverShift::query()->find(2)->end_reason)->toBe(ShiftEndReason::DihentikanAdmin);

    $this->postJson('/api/v1/admin/drivers/5/shifts/1/end')->assertStatus(409)->assertJsonPath('error.code', 'shift_already_closed');
    $this->postJson('/api/v1/admin/drivers/4/shifts/2/end')->assertNotFound();
});

it('manages certifications with activity logs', function () {
    $id = $this->postJson('/api/v1/admin/drivers/5/certifications', [
        'name' => 'PPGD', 'issued_at' => now()->subMonth()->toDateString(),
    ])->assertCreated()->json('data.id');

    $this->putJson("/api/v1/admin/certifications/{$id}", ['name' => 'PPGD Lanjut', 'issued_at' => now()->subMonth()->toDateString()])
        ->assertOk()->assertJsonPath('data.name', 'PPGD Lanjut');
    $this->deleteJson("/api/v1/admin/certifications/{$id}")->assertNoContent();

    expect(AdminActivityLog::query()->where('action', 'like', 'certification.%')->count())->toBe(3);
});

it('protects FK restricted deletes with a friendly conflict', function () {
    $this->deleteJson('/api/v1/admin/institutions/1')->assertStatus(409)
        ->assertJsonPath('error.code', 'institution_has_clinics')
        ->assertJsonPath('error.details.suggestion', 'deactivate');
    $this->deleteJson('/api/v1/admin/clinics/1')->assertStatus(409)->assertJsonPath('error.code', 'clinic_in_use');
    $this->deleteJson('/api/v1/admin/ambulances/3')->assertStatus(409)->assertJsonPath('error.code', 'ambulance_has_history');

    $institution = Institution::factory()->create();
    $this->deleteJson("/api/v1/admin/institutions/{$institution->id}")->assertNoContent();
    expect(AdminActivityLog::query()->where('action', 'institution.deleted')->exists())->toBeTrue();
});

it('creates institutions and clinics with validation', function () {
    $this->postJson('/api/v1/admin/institutions', ['code' => 'rs-baru', 'name' => 'RS Baru', 'type' => 'swasta', 'is_active' => true])
        ->assertCreated()->assertJsonPath('data.code', 'RS-BARU');

    $this->postJson('/api/v1/admin/clinics', ['institution_id' => 1, 'code' => 'K1', 'name' => 'K', 'type' => 'klinik', 'address' => 'Jl', 'latitude' => 95, 'longitude' => 110])
        ->assertStatus(400)->assertJsonValidationErrors('latitude', 'error.details');

    $this->postJson('/api/v1/admin/clinics', ['institution_id' => 1, 'code' => 'kln-x', 'name' => 'Klinik X', 'type' => 'klinik', 'address' => 'Jl. Uji', 'latitude' => -7.01, 'longitude' => 110.4, 'is_active' => true])
        ->assertCreated()->assertJsonPath('data.code', 'KLN-X');
});

it('handles ambulances: uppercase unique plates, status changes and in-use guard', function () {
    $this->postJson('/api/v1/admin/ambulances', ['clinic_id' => 1, 'ambulance_type_id' => 2, 'plate_number' => 'h  7777 zz', 'status' => 'tersedia'])
        ->assertCreated()->assertJsonPath('data.plate_number', 'H 7777 ZZ');
    $this->postJson('/api/v1/admin/ambulances', ['clinic_id' => 1, 'ambulance_type_id' => 2, 'plate_number' => 'h 1234 ab', 'status' => 'tersedia'])
        ->assertStatus(400)->assertJsonValidationErrors('plate_number', 'error.details');

    $this->patchJson('/api/v1/admin/ambulances/3/status', ['status' => 'perawatan'])->assertOk();
    expect(Ambulance::query()->find(3)->status)->toBe(AmbulanceStatus::Perawatan);
    expect(AdminActivityLog::query()->where('action', 'ambulance.status_changed')->where('subject_id', 3)->exists())->toBeTrue();

    $this->patchJson('/api/v1/admin/ambulances/1/status', ['status' => 'perawatan'])->assertStatus(409)->assertJsonPath('error.code', 'ambulance_in_use');
});

it('updates report type rules and the broadcast receivers', function () {
    $this->putJson('/api/v1/admin/report-types/3', [
        'name' => 'Ibu Hamil', 'priority' => 1, 'icon' => 'baby', 'color' => '#2f6f6a', 'is_active' => true, 'sort_order' => 3, 'ambulance_type_ids' => [2],
    ])->assertOk()->assertJsonPath('data.color', '#2F6F6A');

    expect(ReportType::query()->find(3)->ambulanceTypes()->pluck('ambulance_types.id')->all())->toBe([2]);
    expect(AdminActivityLog::query()->where('action', 'report_type.updated')->value('description'))->toContain('penerima broadcast');
});

it('cancels only waiting reports', function () {
    $this->postJson('/api/v1/admin/reports/3/cancel', ['reason' => 'Coba batalkan laporan aktif'])
        ->assertStatus(409)->assertJsonPath('error.code', 'report_not_cancellable');
    $this->postJson('/api/v1/admin/reports/4/cancel', ['reason' => ''])->assertStatus(400);

    $this->postJson('/api/v1/admin/reports/4/cancel', ['reason' => 'Laporan ganda dari pelapor yang sama'])
        ->assertOk()->assertJsonPath('data.status.value', 'dibatalkan');

    expect(Report::query()->find(4)->status)->toBe(ReportStatus::Dibatalkan)
        ->and(ReportStatusLog::query()->where('report_id', 4)->latest('id')->value('changed_by'))->toBe($this->admin->id)
        ->and(AdminActivityLog::query()->where('action', 'report.cancelled')->exists())->toBeTrue();
});

it('exports csv following the active filters', function () {
    $csv = $this->get('/api/v1/admin/reports/export?status=selesai')->assertOk()->streamedContent();

    expect($csv)->toContain('MDR-260928-0001')->not->toContain('MDR-261009-0002');
    expect($this->get('/api/v1/admin/statistics/export?range=year&year=2026')->assertOk()->streamedContent())->toContain('Total laporan');
});

it('validates location log ranges and flags mock GPS points', function () {
    $this->getJson('/api/v1/admin/location-logs?driver_id=4&from='.now()->subDays(20)->toDateTimeString().'&to='.now()->toDateTimeString())
        ->assertStatus(400)->assertJsonValidationErrors('from', 'error.details');

    DriverLocationLog::query()->where('driver_id', 4)->limit(1)->update(['is_mock_location' => true]);

    $this->getJson('/api/v1/admin/location-logs?driver_id=4&report_id=3')
        ->assertOk()
        ->assertJsonPath('data.summary.points', 4)
        ->assertJsonPath('data.summary.mock_points', 1)
        ->assertJsonPath('data.summary.last_battery', 77);
});

it('aggregates statistics for the demo year', function () {
    $response = $this->getJson('/api/v1/admin/statistics?range=year&year=2026')->assertOk();

    expect($response->json('data.summary.total.value'))->toBe(4)
        ->and($response->json('data.by_hour.8'))->toBe(2);

    $this->getJson('/api/v1/admin/statistics?range=custom')->assertStatus(400);
});

it('activates and deactivates reporter accounts with logs', function () {
    User::query()->find(1)->createToken('hp', ['reporter']);

    $this->putJson('/api/v1/admin/users/1', ['account_status' => 'nonaktif'])->assertOk()->assertJsonPath('data.account_status.value', 'nonaktif');

    expect(User::query()->find(1)->tokens()->count())->toBe(0)
        ->and(AdminActivityLog::query()->where('action', 'reporter.deactivated')->exists())->toBeTrue();
    $this->getJson('/api/v1/admin/users/3')->assertNotFound();
});

it('streams private files only to authorized users', function () {
    $path = UploadedFile::fake()->image('andi.jpg')->store('drivers/3/photo', 'local');
    DriverProfile::query()->where('user_id', 3)->update(['photo_path' => $path]);

    $this->get('/api/v1/media/driver-photo/3')->assertOk();

    actingAsMobile(User::query()->find(2));
    $this->get('/api/v1/media/driver-photo/3', ['Accept' => 'application/json'])->assertForbidden();
    $ownAttachment = ReportAttachment::query()->where('report_id', 2)->value('id');
    $otherAttachment = ReportAttachment::query()->where('report_id', 1)->value('id');
    $this->get("/api/v1/media/attachment/{$ownAttachment}", ['Accept' => 'application/json'])->assertNotFound()->assertJsonPath('error.code', 'file_not_found');
    $this->get("/api/v1/media/attachment/{$otherAttachment}", ['Accept' => 'application/json'])->assertForbidden();
});

it('keeps admin API closed to guests and mobile tokens', function () {
    auth()->logout();
    $this->getJson('/api/v1/admin/dashboard/summary')->assertUnauthorized();

    actingAsMobile(User::query()->find(1));
    $this->getJson('/api/v1/admin/drivers')->assertForbidden()->assertJsonPath('error.code', 'role_forbidden');
});
