<?php

namespace Tests\Feature;

use App\Models\Campaign;
use App\Models\Character;
use App\Models\RPGClass;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ResourceCrudTest extends TestCase
{
    use RefreshDatabase;

    public function test_campaign_can_be_created_read_updated_and_deleted_by_its_master(): void
    {
        $master = User::factory()->create();
        Sanctum::actingAs($master);

        $created = $this->postJson('/api/campaigns', [
            'name' => 'A Mina Perdida',
            'description' => 'Uma aventura de teste.',
            'status' => 'ativa',
        ])->assertCreated()
            ->assertJsonPath('data.name', 'A Mina Perdida');

        $campaignId = $created->json('data.id');

        $this->getJson("/api/campaigns/{$campaignId}")
            ->assertOk()
            ->assertJsonPath('data.user_id', $master->id);

        $this->putJson("/api/campaigns/{$campaignId}", [
            'name' => 'A Mina Perdida — Revisada',
            'status' => 'pausada',
        ])->assertOk()
            ->assertJsonPath('data.name', 'A Mina Perdida — Revisada')
            ->assertJsonPath('data.status', 'pausada');

        $this->deleteJson("/api/campaigns/{$campaignId}")
            ->assertOk();

        $this->assertDatabaseMissing('campaigns', ['id' => $campaignId]);
    }

    public function test_character_can_be_created_read_updated_and_deleted_by_its_owner(): void
    {
        $owner = User::factory()->create();
        Sanctum::actingAs($owner);

        $created = $this->postJson('/api/characters', [
            'name' => 'Thorin',
            'race' => 'Anão',
            'level' => 3,
            'hp_current' => 24,
            'strength' => 16,
            'dexterity' => 10,
            'constitution' => 15,
            'intelligence' => 11,
            'wisdom' => 12,
            'charisma' => 9,
            'gold' => 50,
        ])->assertCreated()
            ->assertJsonPath('data.name', 'Thorin');

        $characterId = $created->json('data.id');

        $this->getJson("/api/characters/{$characterId}")
            ->assertOk()
            ->assertJsonPath('data.user_id', $owner->id);

        $this->putJson("/api/characters/{$characterId}", [
            'name' => 'Thorin Escudo de Carvalho',
        ])->assertOk()
            ->assertJsonPath('data.name', 'Thorin Escudo de Carvalho');

        $this->deleteJson("/api/characters/{$characterId}")
            ->assertOk();

        $this->assertDatabaseMissing('characters', ['id' => $characterId]);
    }

    public function test_class_and_its_abilities_support_create_read_update_and_delete(): void
    {
        $owner = User::factory()->create();
        Sanctum::actingAs($owner);

        $created = $this->postJson('/api/classes', [
            'name' => 'Guerreiro',
            'description' => 'Especialista em combate.',
            'hp_base' => 12,
            'gold_initial' => 50,
            'abilities' => [
                ['name' => 'Bloqueio', 'description' => 'Reduz dano.'],
            ],
        ])->assertCreated()
            ->assertJsonPath('data.name', 'Guerreiro')
            ->assertJsonCount(1, 'data.abilities');

        $classId = $created->json('data.id');
        $abilityId = $created->json('data.abilities.0.id');

        $this->getJson("/api/classes/{$classId}")
            ->assertOk()
            ->assertJsonPath('data.abilities.0.name', 'Bloqueio');

        $this->putJson("/api/classes/{$classId}", [
            'name' => 'Guerreiro Veterano',
            'hp_base' => 14,
        ])->assertOk()
            ->assertJsonPath('data.name', 'Guerreiro Veterano')
            ->assertJsonPath('data.hp_base', 14);

        $newAbility = $this->postJson("/api/classes/{$classId}/abilities", [
            'name' => 'Investida',
        ])->assertCreated()
            ->assertJsonPath('data.name', 'Investida');

        $this->deleteJson("/api/classes/{$classId}/abilities/{$abilityId}")
            ->assertOk();

        $this->deleteJson("/api/classes/{$classId}")
            ->assertOk();

        $this->assertDatabaseMissing('rpg_classes', ['id' => $classId]);
        $this->assertDatabaseMissing('class_abilities', [
            'id' => $newAbility->json('data.id'),
        ]);
    }

    public function test_users_cannot_update_or_delete_campaigns_characters_or_classes_they_do_not_own(): void
    {
        $owner = User::factory()->create();
        $otherUser = User::factory()->create();
        $campaign = Campaign::create([
            'user_id' => $owner->id,
            'name' => 'Campanha privada',
            'status' => 'ativa',
        ]);
        $character = Character::create([
            'user_id' => $owner->id,
            'name' => 'Personagem privado',
            'race' => 'Humano',
        ]);
        $rpgClass = RPGClass::create([
            'user_id' => $owner->id,
            'name' => 'Classe privada',
            'hp_base' => 10,
            'gold_initial' => 0,
        ]);
        Sanctum::actingAs($otherUser);

        $this->putJson("/api/campaigns/{$campaign->id}", [
            'name' => 'Alteração não autorizada',
        ])->assertForbidden();
        $this->deleteJson("/api/campaigns/{$campaign->id}")
            ->assertForbidden();

        $this->putJson("/api/characters/{$character->id}", [
            'name' => 'Alteração não autorizada',
        ])->assertForbidden();
        $this->deleteJson("/api/characters/{$character->id}")
            ->assertForbidden();

        $this->putJson("/api/classes/{$rpgClass->id}", [
            'name' => 'Alteração não autorizada',
        ])->assertForbidden();
        $this->deleteJson("/api/classes/{$rpgClass->id}")
            ->assertForbidden();
    }

    public function test_player_can_accept_an_invitation_to_a_new_campaign(): void
    {
        $master = User::factory()->create();
        $player = User::factory()->create();
        $campaign = Campaign::create([
            'user_id' => $master->id,
            'name' => 'Campanha para convite',
            'status' => 'ativa',
        ]);
        $character = Character::create([
            'user_id' => $player->id,
            'name' => 'Personagem convidado',
            'race' => 'Elfo',
        ]);

        Sanctum::actingAs($master);
        $this->getJson(
            "/api/campaigns/{$campaign->id}/invitations/available-characters?email={$player->email}"
        )->assertOk()
            ->assertJsonPath('data.0.id', $character->id);

        $invitation = $this->postJson(
            "/api/campaigns/{$campaign->id}/invitations",
            ['character_id' => $character->id]
        )->assertCreated()
            ->assertJsonPath('data.status', 'pendente');

        $invitationId = $invitation->json('data.id');

        Sanctum::actingAs($player);
        $this->getJson('/api/invitations/pending')
            ->assertOk()
            ->assertJsonPath('data.0.id', $invitationId);

        $this->postJson("/api/invitations/{$invitationId}/accept")
            ->assertOk()
            ->assertJsonPath('data.status', 'aceito');

        $this->assertDatabaseHas('campaign_character', [
            'campaign_id' => $campaign->id,
            'character_id' => $character->id,
        ]);
    }
}
