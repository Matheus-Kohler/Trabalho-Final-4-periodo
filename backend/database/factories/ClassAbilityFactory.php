<?php

namespace Database\Factories;

use App\Models\ClassAbility;
use App\Models\RPGClass;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<ClassAbility>
 */
class ClassAbilityFactory extends Factory
{
    protected $model = ClassAbility::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $abilities = [
            'Golpe Poderoso',
            'Bola de Fogo',
            'Furtividade das Sombras',
            'Cura pelas Mãos',
            'Fúria Primitiva',
            'Inspiração de Bardo',
            'Tiro Certeiro',
            'Forma Selvagem',
            'Passo do Vento',
            'Escudo Arcano',
        ];

        return [
            'rpg_class_id' => RPGClass::factory(),
            'name' => fake()->randomElement($abilities),
            'description' => fake()->sentence(),
        ];
    }
}
