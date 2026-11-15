<?php

namespace Database\Factories;

use App\Models\Character;
use App\Models\RPGClass;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Character>
 */
class CharacterFactory extends Factory
{
    protected $model = Character::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $races = ['Humano', 'Elfo', 'Anão', 'Halfling', 'Meio-Orc', 'Draconato', 'Tiefling', 'Gnomo'];

        return [
            'user_id' => User::factory(),
            'rpg_class_id' => RPGClass::factory(),
            'name' => fake()->firstName() . ' ' . fake()->lastName(),
            'race' => fake()->randomElement($races),
            'level' => fake()->numberBetween(1, 10),
            'hp_current' => fake()->numberBetween(10, 80),
            'strength' => fake()->numberBetween(8, 18),
            'dexterity' => fake()->numberBetween(8, 18),
            'constitution' => fake()->numberBetween(8, 18),
            'intelligence' => fake()->numberBetween(8, 18),
            'wisdom' => fake()->numberBetween(8, 18),
            'charisma' => fake()->numberBetween(8, 18),
            'gold' => fake()->randomFloat(2, 0, 500),
            'history' => fake()->paragraphs(2, true),
            'description' => fake()->sentence(),
        ];
    }
}
