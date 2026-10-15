<?php

use App\Enums\ShiftEndReason;
use App\Models\Ambulance;
use App\Models\Clinic;
use App\Models\DriverProfile;
use App\Models\DriverShift;
use App\Models\User;
use Database\Seeders\MasterDataSeeder;

beforeEach(function () {
    $this->seed(MasterDataSeeder::class);
    $this->clinic = Clinic::factory()->create();
    $this->driver = User::factory()->driver()->create();
    DriverProfile::factory()->create(['user_id' => $this->driver->id, 'clinic_id' => $this->clinic->id]);
    $this->ambulance = Ambulance::factory()->create(['clinic_id' => $this->clinic->id]);
    actingAsMobile($this->driver);
});

it('lists only available ambulances from the driver clinic', function () {
    $busy = Ambulance::factory()->create(['clinic_id' => $this->clinic->id]);
    $otherDriver = User::factory()->driver()->create();
    DriverProfile::factory()->create(['user_id' => $otherDriver->id, 'clinic_id' => $this->clinic->id]);
    DriverShift::create(['driver_id' => $otherDriver->id, 'ambulance_id' => $busy->id, 'started_at' => now()]);
    Ambulance::factory()->create(['clinic_id' => $this->clinic->id, 'status' => 'perawatan']);
    Ambulance::factory()->create();

    $this->getJson('/api/v1/driver/ambulances/available')
        ->assertOk()
        ->assertJsonCount(1, 'data')
        ->assertJsonPath('data.0.id', $this->ambulance->id);
});

it('opens a shift and rejects a second open shift', function () {
    $this->postJson('/api/v1/driver/shifts', ['ambulance_id' => $this->ambulance->id])
        ->assertCreated()
        ->assertJsonPath('data.is_open', true);

    $spare = Ambulance::factory()->create(['clinic_id' => $this->clinic->id]);

    $this->postJson('/api/v1/driver/shifts', ['ambulance_id' => $spare->id])
        ->assertStatus(409)
        ->assertJsonPath('error.code', 'shift_already_open');
});

it('rejects an ambulance that is already used by another driver', function () {
    $other = User::factory()->driver()->create();
    DriverProfile::factory()->create(['user_id' => $other->id, 'clinic_id' => $this->clinic->id]);
    DriverShift::create(['driver_id' => $other->id, 'ambulance_id' => $this->ambulance->id, 'started_at' => now()]);

    $this->postJson('/api/v1/driver/shifts', ['ambulance_id' => $this->ambulance->id])
        ->assertStatus(409)
        ->assertJsonPath('error.code', 'ambulance_in_use');
});

it('rejects ambulances from another clinic or under maintenance', function () {
    $foreign = Ambulance::factory()->create();
    $maintenance = Ambulance::factory()->create(['clinic_id' => $this->clinic->id, 'status' => 'perawatan']);

    $this->postJson('/api/v1/driver/shifts', ['ambulance_id' => $foreign->id])
        ->assertUnprocessable()->assertJsonPath('error.code', 'ambulance_not_allowed');
    $this->postJson('/api/v1/driver/shifts', ['ambulance_id' => $maintenance->id])
        ->assertStatus(409)->assertJsonPath('error.code', 'ambulance_unavailable');
});

it('requires a reason to close a shift', function () {
    $this->postJson('/api/v1/driver/shifts', ['ambulance_id' => $this->ambulance->id])->assertCreated();

    $this->postJson('/api/v1/driver/shifts/close', [])
        ->assertStatus(400)
        ->assertJsonPath('error.details.reason.0', 'Alasan menutup shift wajib diisi.');

    $this->postJson('/api/v1/driver/shifts/close', ['reason' => 'Jam kerja selesai'])
        ->assertOk()
        ->assertJsonPath('data.end_reason.value', 'selesai_shift');

    expect(DriverShift::query()->where('driver_id', $this->driver->id)->value('end_reason'))->toBe(ShiftEndReason::SelesaiShift);
});

it('does not let an on-duty driver close the shift', function () {
    $this->postJson('/api/v1/driver/shifts', ['ambulance_id' => $this->ambulance->id])->assertCreated();
    DriverProfile::query()->where('user_id', $this->driver->id)->update(['is_on_duty' => true]);

    $this->postJson('/api/v1/driver/shifts/close', ['reason' => 'Pulang'])
        ->assertStatus(409)->assertJsonPath('error.code', 'report_in_progress');
});
