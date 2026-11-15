<?php

namespace App\Repositories;

use App\Models\Campaign;
use Illuminate\Database\Eloquent\Collection;

class CampaignRepository
{
    /**
     * Retorna todas as campanhas em que o usuário é mestre.
     */
    public function getAllByMaster(int $userId): Collection
    {
        return Campaign::with(['classes.abilities', 'characters.rpgClass'])
            ->where('user_id', $userId)
            ->orderByDesc('created_at')
            ->get();
    }

    /**
     * Retorna campanhas das quais o usuário participa como jogador.
     */
    public function getParticipatingByPlayer(int $userId): Collection
    {
        return Campaign::whereHas('characters', function ($query) use ($userId) {
            $query->where('user_id', $userId);
        })
        ->with(['master:id,name,email', 'classes', 'characters'])
        ->orderByDesc('created_at')
        ->get();
    }

    /**
     * Busca uma campanha pelo ID com todas as relações carregadas.
     */
    public function findById(int $id): ?Campaign
    {
        return Campaign::with([
            'master:id,name,email',
            'classes.abilities',
            'characters.rpgClass.abilities',
            'characters.user:id,name,email',
        ])->find($id);
    }

    /**
     * Busca uma campanha pelo ID onde o usuário é o mestre.
     */
    public function findByIdAndMaster(int $id, int $userId): ?Campaign
    {
        return Campaign::with([
            'classes.abilities',
            'characters.rpgClass',
            'characters.user:id,name,email',
        ])
        ->where('id', $id)
        ->where('user_id', $userId)
        ->first();
    }

    /**
     * Cria uma nova campanha.
     */
    public function create(array $data): Campaign
    {
        return Campaign::create($data);
    }

    /**
     * Atualiza dados de uma campanha.
     */
    public function update(Campaign $campaign, array $data): Campaign
    {
        $campaign->update($data);
        return $campaign->fresh(['classes', 'characters']);
    }

    /**
     * Remove uma campanha.
     */
    public function delete(Campaign $campaign): bool
    {
        return (bool) $campaign->delete();
    }

    /**
     * Vincula um personagem a uma campanha.
     */
    public function attachCharacter(Campaign $campaign, int $characterId): void
    {
        $campaign->characters()->syncWithoutDetaching([$characterId]);
    }

    /**
     * Desvincula um personagem de uma campanha.
     */
    public function detachCharacter(Campaign $campaign, int $characterId): void
    {
        $campaign->characters()->detach($characterId);
    }

    /**
     * Disponibiliza uma classe na campanha.
     */
    public function attachClass(Campaign $campaign, int $rpgClassId): void
    {
        $campaign->classes()->syncWithoutDetaching([$rpgClassId]);
    }

    /**
     * Remove a disponibilização de uma classe na campanha.
     */
    public function detachClass(Campaign $campaign, int $rpgClassId): void
    {
        $campaign->classes()->detach($rpgClassId);
    }
}
