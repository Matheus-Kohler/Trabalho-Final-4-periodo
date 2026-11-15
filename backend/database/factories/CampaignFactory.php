<?php

namespace Database\Factories;

use App\Models\Campaign;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Campaign>
 */
class CampaignFactory extends Factory
{
    protected $model = Campaign::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $campaigns = [
            'A Mina Perdida de Phandelver',
            'A Maldição do Castelo Ravenloft',
            'Ascensão dos Lordes Dragões',
            'O Despertar do Rei Lich',
            'Sombras sobre Baldur',
            'O Segredo do Templo Esquecido',
        ];

        return [
            'user_id' => User::factory(),
            'name' => fake()->randomElement($campaigns) . ' - ' . fake()->unique()->numberBetween(1, 9999),
            'description' => fake()->paragraph(),
            'status' => fake()->randomElement(['ativa', 'pausada', 'encerrada']),
        ];
    }
}
