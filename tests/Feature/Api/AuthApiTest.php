<?php

use App\Enums\UserRole;
use App\Models\User;
use App\Models\UserDevice;
use Database\Seeders\MasterDataSeeder;

beforeEach(fn () => $this->seed(MasterDataSeeder::class));

it('registers a reporter and always forces the pelapor role', function () {
    $response = $this->postJson('/api/v1/auth/register', [
        'name' => 'Warga Semarang',
        'phone' => '081200000001',
        'email' => 'Warga@Medrive.test',
        'password' => 'rahasia123',
        'password_confirmation' => 'rahasia123',
        'role' => 'driver',
    ]);

    $response->assertCreated()
        ->assertJsonPath('success', true)
        ->assertJsonPath('data.token_type', 'Bearer')
        ->assertJsonPath('data.user.role.value', 'pelapor')
        ->assertJsonPath('data.must_change_password', false);

    expect(User::query()->where('email', 'warga@medrive.test')->value('role'))->toBe(UserRole::Pelapor);
});

it('returns the standard error format for validation failures in Indonesian', function () {
    User::factory()->create(['email' => 'ada@medrive.test']);

    $this->postJson('/api/v1/auth/register', ['email' => 'ada@medrive.test'])
        ->assertStatus(400)
        ->assertJsonPath('success', false)
        ->assertJsonPath('error.code', 'validation_failed')
        ->assertJsonPath('error.message', 'Data tidak valid.')
        ->assertJsonPath('error.details.email.0', 'Email sudah dipakai.')
        ->assertJsonPath('error.details.name.0', 'Nama wajib diisi.');
});

it('rejects API requests without Accept application/json', function () {
    $this->post('/api/v1/auth/login', ['email' => 'x@y.z', 'password' => 'x'])
        ->assertStatus(400)
        ->assertJsonPath('error.code', 'accept_header_required');
});

it('logs drivers and reporters in with role specific abilities', function (string $state, string $ability) {
    $user = User::factory()->{$state}()->create(['email' => 'mobile@medrive.test']);

    $response = $this->postJson('/api/v1/auth/login', ['email' => 'mobile@medrive.test', 'password' => 'password'])->assertOk();

    expect($user->tokens()->first()->abilities)->toBe([$ability])
        ->and($response->json('data.token'))->not->toBeEmpty()
        ->and($user->fresh()->last_login_at)->not->toBeNull();
})->with([['reporter', 'reporter'], ['driver', 'driver']]);

it('refuses admins and inactive accounts at the mobile login', function () {
    User::factory()->admin()->create(['email' => 'admin@x.test']);
    User::factory()->reporter()->inactive()->create(['email' => 'off@x.test']);

    $this->postJson('/api/v1/auth/login', ['email' => 'admin@x.test', 'password' => 'password'])
        ->assertForbidden()->assertJsonPath('error.code', 'admin_use_dashboard');
    $this->postJson('/api/v1/auth/login', ['email' => 'off@x.test', 'password' => 'password'])
        ->assertForbidden()->assertJsonPath('error.code', 'account_inactive');
    $this->postJson('/api/v1/auth/login', ['email' => 'off@x.test', 'password' => 'salah'])
        ->assertUnauthorized()->assertJsonPath('error.code', 'invalid_credentials');
});

it('rate limits the login endpoint', function () {
    foreach (range(1, 5) as $attempt) {
        $this->postJson('/api/v1/auth/login', ['email' => 'limit@x.test', 'password' => 'salah']);
    }

    $this->postJson('/api/v1/auth/login', ['email' => 'limit@x.test', 'password' => 'salah'])
        ->assertStatus(429)
        ->assertJsonPath('error.code', 'too_many_requests');
});

it('blocks features until a driver changes the temporary password', function () {
    $driver = User::factory()->driver()->mustChangePassword()->create();
    $token = $driver->createToken('hp', ['driver'])->plainTextToken;
    $headers = ['Authorization' => 'Bearer '.$token];

    $this->getJson('/api/v1/driver/profile', $headers)
        ->assertForbidden()
        ->assertJsonPath('error.code', 'password_change_required')
        ->assertJsonPath('error.details.must_change_password', true);

    $this->getJson('/api/v1/me', $headers)->assertOk()->assertJsonPath('data.must_change_password', true);
    $this->postJson('/api/v1/auth/fcm', ['fcm_token' => 'tok-1', 'platform' => 'android'], $headers)->assertOk();

    $this->postJson('/api/v1/auth/change-password', [
        'current_password' => 'password',
        'password' => 'rahasiaBaru1',
        'password_confirmation' => 'rahasiaBaru1',
    ], $headers)->assertOk()->assertJsonPath('data.must_change_password', false);

    expect($driver->fresh()->must_change_password)->toBeFalse();
});

it('upserts FCM devices by token', function () {
    $reporter = actingAsMobile(User::factory()->reporter()->create());
    $other = User::factory()->reporter()->create();
    UserDevice::query()->create(['user_id' => $other->id, 'fcm_token' => 'shared-token', 'platform' => 'android']);

    $this->postJson('/api/v1/auth/fcm', ['fcm_token' => 'shared-token', 'platform' => 'ios', 'device_model' => 'iPhone 15', 'app_version' => '1.3.0'])->assertOk();

    $device = UserDevice::query()->where('fcm_token', 'shared-token')->sole();
    expect($device->user_id)->toBe($reporter->id)->and($device->platform)->toBe('ios')->and($device->last_seen_at)->not->toBeNull();
});

it('revokes the current token on logout', function () {
    $user = User::factory()->reporter()->create();
    $token = $user->createToken('hp', ['reporter'])->plainTextToken;

    $this->postJson('/api/v1/auth/logout', [], ['Authorization' => 'Bearer '.$token])->assertNoContent();

    expect($user->tokens()->count())->toBe(0);
    $this->app['auth']->forgetGuards();
    $this->getJson('/api/v1/me', ['Authorization' => 'Bearer '.$token])->assertUnauthorized()->assertJsonPath('error.code', 'unauthenticated');
});

it('keeps reporters and drivers out of each other endpoints', function () {
    actingAsMobile(User::factory()->reporter()->create());
    $this->getJson('/api/v1/driver/profile')->assertForbidden();

    actingAsMobile(User::factory()->driver()->create());
    $this->getJson('/api/v1/reporter/reports')->assertForbidden();
    $this->getJson('/api/v1/admin/dashboard/summary')->assertForbidden();
});

it('has no driver self registration endpoint', function () {
    $this->postJson('/api/v1/driver/register', [])->assertNotFound();
    $this->postJson('/api/v1/auth/register-driver', [])->assertNotFound();
});
