<?php

namespace App\Repositories;

use App\Models\Character;
use Illuminate\Database\Eloquent\Collection;

class CharacterRepository
{
    /**
     * Retorna todos os personagens de um determinado usuário.
     */
    public function getAllByUser(int $userId): Collection
    {
        return Character::with(['rpgClass.abilities'])
            ->where('user_id', $userId)
            ->orderBy('name')
            ->get();
    }

    /**
     * Busca um personagem pelo ID com classe e campanhas.
     */
    public function findById(int $id): ?Character
    {
        return Character::with(['rpgClass.abilities', 'user', 'campaigns'])->find($id);
    }

    /**
     * Busca um personagem pelo ID pertencente a um usuário.
     */
    public function findByIdAndUser(int $id, int $userId): ?Character
    {
        return Character::with(['rpgClass.abilities', 'campaigns'])
            ->where('id', $id)
            ->where('user_id', $userId)
            ->first();
    }

    /**
     * Cria um novo personagem.
     */
    public function create(array $data): Character
    {
        return Character::create($data);
    }

    /**
     * Atualiza os dados de um personagem.
     */
    public function update(Character $character, array $data): Character
    {
        $character->update($data);
        return $character->fresh(['rpgClass.abilities', 'campaigns']);
    }

    /**
     * Remove um personagem.
     */
    public function delete(Character $character): bool
    {
        return (bool) $character->delete();
    }
}
