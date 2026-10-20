<?php

namespace Database\Factories;

use App\Models\Report;
use App\Models\ReportType;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * Laporan baru berstatus menunggu, seperti yang dibuat aplikasi pelapor.
 *
 * @extends Factory<Report>
 */
class ReportFactory extends Factory
{
    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'code' => 'MDR-'.now()->format('ymd').'-'.fake()->unique()->numerify('####'),
            'report_type_id' => fn (): int => ReportType::query()->value('id'),
            'reporter_id' => User::factory(),
            'latitude' => fake()->latitude(-7.1, -6.9),
            'longitude' => fake()->longitude(110.3, 110.5),
            'address' => fake()->streetAddress(),
            'description' => 'Laporan uji: '.fake()->sentence(),
        ];
    }
}
