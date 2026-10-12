<?php

use App\Enums\AccountStatus;
use App\Models\AdminActivityLog;
use App\Models\DriverProfile;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

beforeEach(function () {
    Storage::fake('local');
    $this->admin = seedDemoAndGetAdmin();
});

function validDriverPayload(array $overrides = []): array
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

it('registers a driver with profile, photo and certification in one transaction', function () {
    $response = $this->actingAs($this->admin)->post(route('admin.drivers.store'), validDriverPayload([
        'photo' => UploadedFile::fake()->image('joko.jpg'),
        'certifications' => [[
            'name' => 'BTCLS',
            'certificate_number' => 'BTCLS/2026/1',
            'issuer' => 'PPNI',
            'issued_at' => now()->subYear()->toDateString(),
            'expires_at' => now()->addYears(4)->toDateString(),
            'file' => UploadedFile::fake()->create('btcls.pdf', 120, 'application/pdf'),
        ]],
    ]));

    $driver = User::query()->where('email', 'joko@medrive.test')->firstOrFail();
    $response->assertRedirect(route('admin.drivers.show', $driver));

    expect($driver->isDriver())->toBeTrue()
        ->and($driver->account_status)->toBe(AccountStatus::Aktif)
        ->and($driver->must_change_password)->toBeTrue()
        ->and($driver->driverProfile->created_by)->toBe($this->admin->id)
        ->and($driver->driverProfile->clinic_id)->toBe(1)
        ->and($driver->certifications)->toHaveCount(1);

    Storage::disk('local')->assertExists($driver->driverProfile->photo_path);
    Storage::disk('local')->assertExists($driver->certifications->first()->file_path);

    $log = AdminActivityLog::query()->where('action', 'driver.created')->latest('id')->first();
    expect($log->admin_id)->toBe($this->admin->id)
        ->and($log->subject_type)->toBe('users')
        ->and($log->subject_id)->toBe($driver->id)
        ->and($log->description)->toBe('Mendaftarkan driver Joko Susilo (Puskesmas Tembalang)')
        ->and($log->ip_address)->not->toBeNull();
});

it('shows the temporary credentials only once', function () {
    $this->actingAs($this->admin)
        ->followingRedirects()
        ->post(route('admin.drivers.store'), validDriverPayload())
        ->assertOk()
        ->assertSee('Kredensial akun driver')
        ->assertSee('sementara123');

    $driver = User::query()->where('email', 'joko@medrive.test')->firstOrFail();

    $this->actingAs($this->admin)
        ->get(route('admin.drivers.show', $driver))
        ->assertOk()
        ->assertDontSee('sementara123')
        ->assertDontSee('Kredensial akun driver');
});

it('validates driver registration rules', function (array $overrides, string $field) {
    $this->actingAs($this->admin)
        ->post(route('admin.drivers.store'), validDriverPayload($overrides))
        ->assertSessionHasErrors($field);

    expect(User::query()->where('email', 'joko@medrive.test')->exists())->toBeFalse();
})->with([
    'duplicate email' => [['email' => 'andi@medrive.test'], 'email'],
    'employee number taken in same clinic' => [['employee_number' => 'PKM-0007'], 'employee_number'],
    'license expiring today' => [['license_expires_at' => now()->toDateString()], 'license_expires_at'],
    'unknown license class' => [['license_class' => 'C'], 'license_class'],
    'short password' => [['password' => 'pendek'], 'password'],
    'photo too large' => [['photo' => UploadedFile::fake()->image('besar.jpg')->size(3000)], 'photo'],
]);

it('allows the same employee number at a different clinic', function () {
    $this->actingAs($this->admin)
        ->post(route('admin.drivers.store'), validDriverPayload(['employee_number' => 'PKM-0007', 'clinic_id' => 2]))
        ->assertSessionHasNoErrors();
});

it('updates a driver and logs the changed fields', function () {
    $this->actingAs($this->admin)
        ->put(route('admin.drivers.update', 3), [
            'name' => 'Andi Prasetyo',
            'phone' => '081234567803',
            'email' => 'andi.baru@medrive.test',
            'new_password' => 'passwordbaru1',
            'clinic_id' => 2,
            'employee_number' => 'PMI-0012',
            'license_number' => '1234-5678-000001',
            'license_class' => 'B1_umum',
            'license_expires_at' => '2028-03-14',
        ])
        ->assertRedirect(route('admin.drivers.show', 3));

    $driver = User::query()->findOrFail(3);
    expect($driver->email)->toBe('andi.baru@medrive.test')
        ->and($driver->must_change_password)->toBeTrue()
        ->and($driver->driverProfile->license_class->value)->toBe('B1_umum');

    $log = AdminActivityLog::query()->where('action', 'driver.updated')->latest('id')->first();
    expect($log->description)
        ->toContain('email: andi@medrive.test -> andi.baru@medrive.test')
        ->toContain('license_class: A_umum -> B1_umum')
        ->toContain('password direset');
});

it('refuses to deactivate a driver with an open shift', function () {
    $this->actingAs($this->admin)
        ->patch(route('admin.drivers.account-status', 3))
        ->assertRedirect(route('admin.drivers.show', ['driver' => 3, 'tab' => 'shift']))
        ->assertSessionHas('error');

    expect(User::query()->find(3)->account_status)->toBe(AccountStatus::Aktif);
});

it('deactivates and reactivates a driver without an open shift', function () {
    $this->actingAs($this->admin)->patch(route('admin.drivers.account-status', 5))->assertSessionHas('success');
    expect(User::query()->find(5)->account_status)->toBe(AccountStatus::Nonaktif);
    expect(AdminActivityLog::query()->where('action', 'driver.deactivated')->where('subject_id', 5)->exists())->toBeTrue();

    $this->actingAs($this->admin)->patch(route('admin.drivers.account-status', 5));
    expect(User::query()->find(5)->account_status)->toBe(AccountStatus::Aktif);
    expect(AdminActivityLog::query()->where('action', 'driver.activated')->exists())->toBeTrue();
});

it('streams driver photos only to admins', function () {
    $path = UploadedFile::fake()->image('andi.jpg')->store('drivers/3/photo', 'local');
    DriverProfile::query()->where('user_id', 3)->update(['photo_path' => $path]);

    $this->actingAs($this->admin)->get(route('admin.drivers.photo', 3))->assertOk();
    $this->actingAs(User::query()->find(1))->get(route('admin.drivers.photo', 3))->assertForbidden();
    auth()->logout();
    $this->get(route('admin.drivers.photo', 3))->assertRedirect(route('admin.login'));
});

it('manages driver certifications with activity logs', function () {
    $this->actingAs($this->admin)
        ->post(route('admin.drivers.certifications.store', 5), [
            'name' => 'PPGD',
            'issued_at' => now()->subMonth()->toDateString(),
            'expires_at' => now()->addYear()->toDateString(),
        ])
        ->assertSessionHasNoErrors();

    $certification = User::query()->find(5)->certifications()->where('name', 'PPGD')->firstOrFail();

    $this->actingAs($this->admin)
        ->put(route('admin.certifications.update', $certification), [
            'name' => 'PPGD Lanjut',
            'issued_at' => $certification->issued_at->toDateString(),
        ])
        ->assertSessionHasNoErrors();

    expect($certification->fresh()->name)->toBe('PPGD Lanjut');

    $this->actingAs($this->admin)->delete(route('admin.certifications.destroy', $certification));
    expect($certification->fresh())->toBeNull();

    expect(AdminActivityLog::query()->whereIn('action', ['certification.created', 'certification.updated', 'certification.deleted'])->count())->toBe(3);
});

it('rejects a certification that expires before it was issued', function () {
    $this->actingAs($this->admin)
        ->post(route('admin.drivers.certifications.store', 5), [
            'name' => 'BHD',
            'issued_at' => now()->subMonth()->toDateString(),
            'expires_at' => now()->subYear()->toDateString(),
        ])
        ->assertSessionHasErrors('expires_at');
});

it('has no driver self registration route', function () {
    $this->post('/register')->assertNotFound();
    $this->post('/api/driver/register')->assertNotFound();
});
