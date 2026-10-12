<?php

use App\Models\User;
use Illuminate\Support\Facades\RateLimiter;

it('shows the login page to guests', function () {
    $this->get(route('admin.login'))
        ->assertOk()
        ->assertSee('Masuk ke dashboard admin');
});

it('redirects guests away from admin pages', function () {
    $this->get(route('admin.dashboard'))->assertRedirect(route('admin.login'));
});

it('logs an active admin in and records last_login_at', function () {
    $admin = User::factory()->admin()->create(['email' => 'pusat@medrive.test']);

    $this->post(route('admin.login.store'), ['email' => 'pusat@medrive.test', 'password' => 'password'])
        ->assertRedirect(route('admin.dashboard'));

    $this->assertAuthenticatedAs($admin);
    expect($admin->fresh()->last_login_at)->not->toBeNull();
});

it('rejects drivers and reporters at the admin login', function (string $state) {
    User::factory()->{$state}()->create(['email' => 'bukan-admin@medrive.test']);

    $this->from(route('admin.login'))
        ->post(route('admin.login.store'), ['email' => 'bukan-admin@medrive.test', 'password' => 'password'])
        ->assertRedirect(route('admin.login'))
        ->assertSessionHasErrors(['email' => 'Akun ini bukan akun admin. Driver dan pelapor masuk lewat aplikasi mobile.']);

    $this->assertGuest();
})->with(['driver', 'reporter']);

it('rejects an inactive admin', function () {
    User::factory()->admin()->inactive()->create(['email' => 'nonaktif@medrive.test']);

    $this->post(route('admin.login.store'), ['email' => 'nonaktif@medrive.test', 'password' => 'password'])
        ->assertSessionHasErrors('email');

    $this->assertGuest();
});

it('forces a password change before any other admin page', function () {
    $admin = User::factory()->admin()->mustChangePassword()->create();

    $this->actingAs($admin)->get(route('admin.dashboard'))->assertRedirect(route('admin.password.edit'));
    $this->actingAs($admin)->get(route('admin.password.edit'))->assertOk()->assertSee('Ganti password terlebih dahulu');

    $this->actingAs($admin)
        ->put(route('admin.password.update'), [
            'current_password' => 'password',
            'password' => 'rahasia-baru-123',
            'password_confirmation' => 'rahasia-baru-123',
        ])
        ->assertRedirect(route('admin.dashboard'));

    expect($admin->fresh()->must_change_password)->toBeFalse();
    $this->actingAs($admin->fresh())->get(route('admin.dashboard'))->assertOk();
});

it('forbids authenticated non-admin users from admin routes', function () {
    $driver = User::factory()->driver()->create();

    $this->actingAs($driver)->get(route('admin.dashboard'))->assertForbidden();
});

it('throttles repeated failed logins', function () {
    RateLimiter::clear('admin-login');

    foreach (range(1, 5) as $attempt) {
        $this->post(route('admin.login.store'), ['email' => 'salah@medrive.test', 'password' => 'salah']);
    }

    $this->post(route('admin.login.store'), ['email' => 'salah@medrive.test', 'password' => 'salah'])
        ->assertTooManyRequests();
});
