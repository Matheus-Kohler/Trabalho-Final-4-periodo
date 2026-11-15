<?php

namespace Database\Seeders;

use App\Models\Campaign;
use App\Models\Character;
use App\Models\ClassAbility;
use App\Models\RPGClass;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Usuário Mestre padrão para testes
        $master = User::firstOrCreate(
            ['email' => 'mestre@rpgmanager.com'],
            [
                'name' => 'Mestre das Sombras',
                'password' => Hash::make('password123'),
            ]
        );

        // 2. Usuário Jogador padrão para testes
        $player = User::firstOrCreate(
            ['email' => 'jogador@rpgmanager.com'],
            [
                'name' => 'Jogador Aventureiro',
                'password' => Hash::make('password123'),
            ]
        );

        // 3. Classes criadas pelo Mestre com habilidades
        $warrior = RPGClass::firstOrCreate(
            ['user_id' => $master->id, 'name' => 'Guerreiro'],
            [
                'description' => 'Especialista em combate corpo a corpo, armaduras pesadas e maestria com armas.',
                'hp_base' => 12,
                'gold_initial' => 50.00,
            ]
        );

        ClassAbility::firstOrCreate(
            ['rpg_class_id' => $warrior->id, 'name' => 'Ataque Poderoso'],
            ['description' => 'Desfere um golpe devastador adicionando bônus de dano de força.']
        );
        ClassAbility::firstOrCreate(
            ['rpg_class_id' => $warrior->id, 'name' => 'Retomar o Fôlego'],
            ['description' => 'Recupera uma quantidade de pontos de vida em combate.']
        );

        $mage = RPGClass::firstOrCreate(
            ['user_id' => $master->id, 'name' => 'Mago'],
            [
                'description' => 'Estudioso das artes arcanas capaz de moldar a realidade e conjurar feitiços.',
                'hp_base' => 6,
                'gold_initial' => 80.00,
            ]
        );

        ClassAbility::firstOrCreate(
            ['rpg_class_id' => $mage->id, 'name' => 'Míssil Mágico'],
            ['description' => 'Projéteis arcanos certeiros que atingem o alvo sem chance de erro.']
        );
        ClassAbility::firstOrCreate(
            ['rpg_class_id' => $mage->id, 'name' => 'Escudo Arcano'],
            ['description' => 'Cria uma barreira de proteção invisível que bloqueia ataques.']
        );

        $rogue = RPGClass::firstOrCreate(
            ['user_id' => $master->id, 'name' => 'Ladino'],
            [
                'description' => 'Mestre da furtividade, armadilhas e ataques furtivos nas sombras.',
                'hp_base' => 8,
                'gold_initial' => 100.00,
            ]
        );

        ClassAbility::firstOrCreate(
            ['rpg_class_id' => $rogue->id, 'name' => 'Ataque Furtivo'],
            ['description' => 'Causa dano extra crítico quando o inimigo está distraído ou flanqueado.']
        );

        // 4. Personagens
        // Personagem do jogador com a classe Guerreiro
        $thorin = Character::firstOrCreate(
            ['user_id' => $player->id, 'name' => 'Thorin Machado de Prata'],
            [
                'rpg_class_id' => $warrior->id,
                'race' => 'Anão',
                'level' => 3,
                'hp_current' => 28,
                'strength' => 16,
                'dexterity' => 12,
                'constitution' => 16,
                'intelligence' => 10,
                'wisdom' => 12,
                'charisma' => 8,
                'gold' => 75.50,
                'history' => 'Guerreiro exilado das montanhas profundas em busca de honra e glória.',
                'description' => 'Anão robusto de barba trançada e machado de guerra duplo.',
            ]
        );

        // Personagem do jogador com a classe Mago
        $elion = Character::firstOrCreate(
            ['user_id' => $player->id, 'name' => 'Elion Folha de Outono'],
            [
                'rpg_class_id' => $mage->id,
                'race' => 'Elfo',
                'level' => 2,
                'hp_current' => 14,
                'strength' => 8,
                'dexterity' => 15,
                'constitution' => 12,
                'intelligence' => 17,
                'wisdom' => 13,
                'charisma' => 10,
                'gold' => 120.00,
                'history' => 'Erudito arcano enviado pela torre dos magos para investigar anomalias mágicas.',
                'description' => 'Elfo esguio com túnica azul-marinho e cajado de cristal.',
            ]
        );

        // 5. Campanha criada pelo Mestre
        $campaign = Campaign::firstOrCreate(
            ['user_id' => $master->id, 'name' => 'A Mina Perdida de Phandelver'],
            [
                'description' => 'Uma expedição perigosa às ruínas da lendária forja das magias esquecidas.',
                'status' => 'ativa',
            ]
        );

        // Vínculo: Mestre disponibiliza as classes Guerreiro e Mago nesta campanha
        $campaign->classes()->syncWithoutDetaching([$warrior->id, $mage->id]);

        // Vínculo: Adiciona os personagens do jogador à campanha
        $campaign->characters()->syncWithoutDetaching([$thorin->id, $elion->id]);
    }
}
