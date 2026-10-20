<?php

namespace Database\Factories;

use App\Enums\InstitutionType;
use App\Models\Institution;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Institution>
 */
class InstitutionFactory extends Factory
{
    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'code' => strtoupper(fake()->unique()->bothify('INS-###??')),
            'name' => 'Instansi '.fake()->city(),
            'type' => fake()->randomElement(InstitutionType::cases()),
            'phone' => '024'.fake()->numerify('#######'),
            'email' => fake()->safeEmail(),
            'address' => fake()->streetAddress(),
            'is_active' => true,
        ];
    }
}
