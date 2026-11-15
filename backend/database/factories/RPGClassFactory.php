<?php

namespace Database\Factories;

use App\Models\RPGClass;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<RPGClass>
 */
class RPGClassFactory extends Factory
{
    protected $model = RPGClass::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $classes = ['Guerreiro', 'Mago', 'Ladino', 'Clérigo', 'Paladino', 'Bárbaro', 'Bardo', 'Ranger', 'Druida', 'Monge'];

        return [
            'user_id' => User::factory(),
            'name' => fake()->randomElement($classes) . ' ' . fake()->unique()->numberBetween(1, 9999),
            'description' => fake()->paragraph(),
            'hp_base' => fake()->numberBetween(8, 20),
            'gold_initial' => fake()->randomFloat(2, 10, 200),
        ];
    }
}
