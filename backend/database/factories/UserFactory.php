<?php

namespace Database\Factories;

use App\Enums\AccountStatus;
use App\Enums\UserRole;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;

/**
 * @extends Factory<User>
 */
class UserFactory extends Factory
{
    /**
     * The current password being used by the factory.
     */
    protected static ?string $password;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'name' => fake()->name(),
            'phone' => '08'.fake()->numerify('##########'),
            'email' => fake()->unique()->safeEmail(),
            'password' => static::$password ??= Hash::make('password'),
            'role' => UserRole::Pelapor,
            'account_status' => AccountStatus::Aktif,
            'must_change_password' => false,
        ];
    }

    public function admin(): static
    {
        return $this->state(fn (): array => ['role' => UserRole::Admin]);
    }

    public function driver(): static
    {
        return $this->state(fn (): array => ['role' => UserRole::Driver]);
    }

    public function reporter(): static
    {
        return $this->state(fn (): array => ['role' => UserRole::Pelapor]);
    }

    public function inactive(): static
    {
        return $this->state(fn (): array => ['account_status' => AccountStatus::Nonaktif]);
    }

    public function mustChangePassword(): static
    {
        return $this->state(fn (): array => ['must_change_password' => true]);
    }
}
