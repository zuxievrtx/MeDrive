<?php

namespace Database\Factories;

use App\Enums\ClinicType;
use App\Models\Clinic;
use App\Models\Institution;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Clinic>
 */
class ClinicFactory extends Factory
{
    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'institution_id' => Institution::factory(),
            'code' => strtoupper(fake()->unique()->bothify('KLN-###??')),
            'name' => 'Klinik '.fake()->lastName(),
            'type' => fake()->randomElement(ClinicType::cases()),
            'phone' => '024'.fake()->numerify('#######'),
            'address' => fake()->streetAddress(),
            'latitude' => fake()->latitude(-7.1, -6.9),
            'longitude' => fake()->longitude(110.3, 110.5),
            'is_active' => true,
        ];
    }
}
