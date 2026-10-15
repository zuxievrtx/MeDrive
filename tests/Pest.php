<?php

use App\Models\Ambulance;
use App\Models\Clinic;
use App\Models\DriverLastLocation;
use App\Models\DriverProfile;
use App\Models\DriverShift;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

/*
|--------------------------------------------------------------------------
| Test Case
|--------------------------------------------------------------------------
| Semua test feature berjalan di MySQL (medrive_db_test) karena skema v3 memakai ENUM,
| CHECK constraint, dan kolom generated.
*/

pest()->extend(TestCase::class)
    ->use(RefreshDatabase::class)
    ->in('Feature');

/**
 * Muat data master + data contoh ERD v3 lalu kembalikan akun admin pusat (id 6).
 */
function seedDemoAndGetAdmin(): User
{
    test()->seed();

    return User::query()->findOrFail(6);
}

/**
 * Login sebagai user aplikasi mobile dengan ability token sesuai peran.
 */
function actingAsMobile(User $user): User
{
    Sanctum::actingAs($user, [$user->isDriver() ? 'driver' : 'reporter']);

    return $user;
}

/**
 * Driver dengan shift terbuka dan posisi terakhir di koordinat tertentu (klinik di titik yang sama).
 *
 * @param  array<string, mixed>  $userAttributes
 */
function onShiftDriver(float $latitude, float $longitude, int $ambulanceTypeId = 1, array $userAttributes = []): User
{
    $clinic = Clinic::factory()->create(['latitude' => $latitude, 'longitude' => $longitude]);
    $driver = User::factory()->driver()->create($userAttributes);
    DriverProfile::factory()->create(['user_id' => $driver->id, 'clinic_id' => $clinic->id]);
    $ambulance = Ambulance::factory()->create(['clinic_id' => $clinic->id, 'ambulance_type_id' => $ambulanceTypeId]);
    $shift = DriverShift::create(['driver_id' => $driver->id, 'ambulance_id' => $ambulance->id, 'started_at' => now()->subHour()]);

    DriverLastLocation::create([
        'driver_id' => $driver->id,
        'shift_id' => $shift->id,
        'latitude' => $latitude,
        'longitude' => $longitude,
        'recorded_at' => now(),
    ]);

    return $driver;
}

/**
 * Titik yang berjarak kira-kira $km ke utara dari koordinat asal (1 derajat lintang ~ 111,2 km).
 *
 * @return array{0: float, 1: float}
 */
function pointNorthOf(float $latitude, float $longitude, float $km): array
{
    return [$latitude + $km / 111.19, $longitude];
}
