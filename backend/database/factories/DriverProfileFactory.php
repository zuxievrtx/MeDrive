<?php

namespace Database\Factories;

use App\Enums\LicenseClass;
use App\Models\Clinic;
use App\Models\DriverProfile;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<DriverProfile>
 */
class DriverProfileFactory extends Factory
{
    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => User::factory()->driver(),
            'clinic_id' => Clinic::factory(),
            'employee_number' => strtoupper(fake()->unique()->bothify('EMP-####')),
            'license_number' => fake()->numerify('####-####-######'),
            'license_class' => LicenseClass::AUmum,
            'license_expires_at' => now()->addYears(2)->toDateString(),
        ];
    }
}
