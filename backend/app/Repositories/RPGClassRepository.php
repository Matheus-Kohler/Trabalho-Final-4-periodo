<?php

namespace App\Repositories;

use App\Models\RPGClass;
use Illuminate\Database\Eloquent\Collection;

class RPGClassRepository
{
    /**
     * Retorna todas as classes criadas por um usuário específico.
     */
    public function getAllByUser(int $userId): Collection
    {
        return RPGClass::with('abilities')
            ->where('user_id', $userId)
            ->orderBy('name')
            ->get();
    }

    /**
     * Busca uma classe pelo ID com suas habilidades.
     */
    public function findById(int $id): ?RPGClass
    {
        return RPGClass::with(['abilities', 'user'])->find($id);
    }

    /**
     * Busca uma classe pelo ID pertencente a um usuário específico.
     */
    public function findByIdAndUser(int $id, int $userId): ?RPGClass
    {
        return RPGClass::with('abilities')
            ->where('id', $id)
            ->where('user_id', $userId)
            ->first();
    }

    /**
     * Cria uma nova classe.
     */
    public function create(array $data): RPGClass
    {
        return RPGClass::create($data);
    }

    /**
     * Atualiza uma classe existente.
     */
    public function update(RPGClass $rpgClass, array $data): RPGClass
    {
        $rpgClass->update($data);
        return $rpgClass->fresh(['abilities']);
    }

    /**
     * Remove uma classe.
     */
    public function delete(RPGClass $rpgClass): bool
    {
        return (bool) $rpgClass->delete();
    }
}
