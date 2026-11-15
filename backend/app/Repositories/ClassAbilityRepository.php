<?php

namespace App\Repositories;

use App\Models\ClassAbility;
use Illuminate\Database\Eloquent\Collection;

class ClassAbilityRepository
{
    /**
     * Retorna todas as habilidades de uma classe.
     */
    public function getByClassId(int $rpgClassId): Collection
    {
        return ClassAbility::where('rpg_class_id', $rpgClassId)->get();
    }

    /**
     * Busca uma habilidade por ID.
     */
    public function findById(int $id): ?ClassAbility
    {
        return ClassAbility::find($id);
    }

    /**
     * Cria uma nova habilidade para uma classe.
     */
    public function create(array $data): ClassAbility
    {
        return ClassAbility::create($data);
    }

    /**
     * Atualiza uma habilidade existente.
     */
    public function update(ClassAbility $ability, array $data): ClassAbility
    {
        $ability->update($data);
        return $ability->fresh();
    }

    /**
     * Remove uma habilidade.
     */
    public function delete(ClassAbility $ability): bool
    {
        return (bool) $ability->delete();
    }
}
