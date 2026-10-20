<?php

namespace Database\Factories;

use App\Enums\AmbulanceStatus;
use App\Models\Ambulance;
use App\Models\AmbulanceType;
use App\Models\Clinic;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Ambulance>
 */
class AmbulanceFactory extends Factory
{
    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'clinic_id' => Clinic::factory(),
            'ambulance_type_id' => fn (): int => AmbulanceType::query()->value('id'),
            'plate_number' => 'H '.fake()->unique()->numberBetween(1000, 9999).' '.fake()->randomElement(['AB', 'CD', 'EF', 'GH']),
            'vehicle_name' => 'Toyota HiAce',
            'year' => fake()->numberBetween(2015, 2025),
            'status' => AmbulanceStatus::Tersedia,
        ];
    }
}
