<?php

use App\Enums\AmbulanceStatus;
use App\Models\AdminActivityLog;
use App\Models\Ambulance;
use App\Models\Clinic;
use App\Models\Institution;
use App\Models\ReportType;

beforeEach(function () {
    $this->admin = seedDemoAndGetAdmin();
});

it('creates and updates an institution with activity logs', function () {
    $this->actingAs($this->admin)
        ->post(route('admin.institutions.store'), ['code' => 'rs-baru', 'name' => 'RS Baru', 'type' => 'swasta', 'is_active' => '1'])
        ->assertRedirect(route('admin.institutions.index'));

    $institution = Institution::query()->where('code', 'RS-BARU')->firstOrFail();

    $this->actingAs($this->admin)
        ->put(route('admin.institutions.update', $institution), ['code' => 'RS-BARU', 'name' => 'RS Baru Sejahtera', 'type' => 'swasta', 'is_active' => '0'])
        ->assertSessionHasNoErrors();

    expect($institution->fresh()->is_active)->toBeFalse();
    expect(AdminActivityLog::query()->whereIn('action', ['institution.created', 'institution.updated'])->count())->toBe(2);
});

it('rejects a duplicate institution code', function () {
    $this->actingAs($this->admin)
        ->post(route('admin.institutions.store'), ['code' => 'pmi-smg', 'name' => 'PMI lain', 'type' => 'sosial'])
        ->assertSessionHasErrors('code');
});

it('refuses to delete an institution that still has clinics', function () {
    $this->actingAs($this->admin)->delete(route('admin.institutions.destroy', 1))->assertSessionHas('error');
    expect(Institution::query()->find(1))->not->toBeNull();
});

it('deletes an institution without clinics', function () {
    $institution = Institution::factory()->create();

    $this->actingAs($this->admin)->delete(route('admin.institutions.destroy', $institution))->assertSessionHas('success');
    expect($institution->fresh())->toBeNull();
    expect(AdminActivityLog::query()->where('action', 'institution.deleted')->exists())->toBeTrue();
});

it('requires valid clinic coordinates', function (array $coordinates) {
    $this->actingAs($this->admin)
        ->post(route('admin.clinics.store'), [
            'institution_id' => 1, 'code' => 'KLN-X', 'name' => 'Klinik X', 'type' => 'klinik', 'address' => 'Jl. Uji', ...$coordinates,
        ])
        ->assertSessionHasErrors(array_keys($coordinates)[0]);
})->with([
    'missing latitude' => [['latitude' => '', 'longitude' => '110.4']],
    'latitude out of range' => [['latitude' => '95', 'longitude' => '110.4']],
    'longitude out of range' => [['longitude' => '200', 'latitude' => '-7']],
]);

it('creates a clinic with coordinates', function () {
    $this->actingAs($this->admin)
        ->post(route('admin.clinics.store'), [
            'institution_id' => 1, 'code' => 'kln-x', 'name' => 'Klinik X', 'type' => 'klinik', 'address' => 'Jl. Uji',
            'latitude' => '-7.0100000', 'longitude' => '110.4000000', 'is_active' => '1',
        ])
        ->assertSessionHasNoErrors();

    expect(Clinic::query()->where('code', 'KLN-X')->value('latitude'))->toBe('-7.0100000');
});

it('refuses to delete a clinic with drivers or ambulances', function () {
    $this->actingAs($this->admin)->delete(route('admin.clinics.destroy', 1))->assertSessionHas('error');
    expect(Clinic::query()->find(1))->not->toBeNull();
});

it('stores plate numbers in uppercase and keeps them unique', function () {
    $this->actingAs($this->admin)
        ->post(route('admin.ambulances.store'), ['clinic_id' => 1, 'ambulance_type_id' => 2, 'plate_number' => 'h  7777 zz', 'status' => 'tersedia', 'year' => 2024])
        ->assertSessionHasNoErrors();

    expect(Ambulance::query()->where('plate_number', 'H 7777 ZZ')->exists())->toBeTrue();
    expect(AdminActivityLog::query()->where('action', 'ambulance.created')->exists())->toBeTrue();

    $this->actingAs($this->admin)
        ->post(route('admin.ambulances.store'), ['clinic_id' => 1, 'ambulance_type_id' => 2, 'plate_number' => 'h 1234 ab', 'status' => 'tersedia'])
        ->assertSessionHasErrors('plate_number');
});

it('logs ambulance status changes', function () {
    $this->actingAs($this->admin)
        ->patch(route('admin.ambulances.status', 3), ['status' => 'perawatan'])
        ->assertSessionHas('success');

    expect(Ambulance::query()->find(3)->status)->toBe(AmbulanceStatus::Perawatan);
    expect(AdminActivityLog::query()->where('action', 'ambulance.status_changed')->where('subject_id', 3)->exists())->toBeTrue();
});

it('blocks status changes for an ambulance used by an open shift', function () {
    $this->actingAs($this->admin)
        ->patch(route('admin.ambulances.status', 1), ['status' => 'perawatan'])
        ->assertSessionHas('error');

    expect(Ambulance::query()->find(1)->status)->toBe(AmbulanceStatus::Tersedia);
});

it('refuses to delete an ambulance with shift history', function () {
    $this->actingAs($this->admin)->delete(route('admin.ambulances.destroy', 3))->assertSessionHas('error');
    expect(Ambulance::query()->find(3))->not->toBeNull();
});

it('updates report type rules and the broadcast receivers', function () {
    $this->actingAs($this->admin)
        ->put(route('admin.report-types.update', 3), [
            'name' => 'Ibu Hamil',
            'priority' => 1,
            'icon' => 'baby',
            'color' => '#2f6f6a',
            'is_active' => '1',
            'sort_order' => 3,
            'ambulance_type_ids' => [2],
        ])
        ->assertRedirect(route('admin.report-types.index'));

    $type = ReportType::query()->with('ambulanceTypes')->findOrFail(3);
    expect($type->priority)->toBe(1)
        ->and($type->color)->toBe('#2F6F6A')
        ->and($type->ambulanceTypes->pluck('id')->all())->toBe([2]);

    $log = AdminActivityLog::query()->where('action', 'report_type.updated')->firstOrFail();
    expect($log->description)->toContain('penerima broadcast: Ambulans Gawat Darurat, Ambulans Transport -> Ambulans Transport');
});

it('requires at least one ambulance type for an active report type', function () {
    $this->actingAs($this->admin)
        ->put(route('admin.report-types.update', 3), [
            'name' => 'Ibu Hamil', 'priority' => 2, 'is_active' => '1', 'sort_order' => 3, 'ambulance_type_ids' => [],
        ])
        ->assertSessionHasErrors('ambulance_type_ids');
});

it('only lets admins edit the name and description of ambulance types', function () {
    $this->actingAs($this->admin)
        ->put(route('admin.ambulance-types.update', 1), ['name' => 'Ambulans Gawat Darurat (ALS)', 'description' => 'Baru', 'code' => 'diubah'])
        ->assertRedirect(route('admin.ambulance-types.index'));

    $this->assertDatabaseHas('ambulance_types', ['id' => 1, 'code' => 'gawat_darurat', 'name' => 'Ambulans Gawat Darurat (ALS)']);
});

it('deactivates a reporter account with a log entry', function () {
    $this->actingAs($this->admin)->patch(route('admin.users.account-status', 1))->assertSessionHas('success');

    $this->assertDatabaseHas('users', ['id' => 1, 'account_status' => 'nonaktif']);
    expect(AdminActivityLog::query()->where('action', 'reporter.deactivated')->exists())->toBeTrue();
});
