<?php

namespace App\Services;

use App\Models\ClassAbility;
use App\Models\RPGClass;
use App\Repositories\ClassAbilityRepository;
use App\Repositories\RPGClassRepository;
use Illuminate\Database\Eloquent\Collection;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class RPGClassService
{
    public function __construct(
        protected RPGClassRepository $rpgClassRepository,
        protected ClassAbilityRepository $abilityRepository
    ) {}

    /**
     * Retorna a lista de classes criadas pelo usuário autenticado.
     */
    public function listClasses(int $userId): Collection
    {
        return $this->rpgClassRepository->getAllByUser($userId);
    }

    /**
     * Obtém uma classe específica, verificando se ela existe.
     */
    public function getClass(int $id): RPGClass
    {
        $class = $this->rpgClassRepository->findById($id);

        if (! $class) {
            throw new NotFoundHttpException('Classe não encontrada.');
        }

        return $class;
    }

    /**
     * Cria uma nova classe para o usuário com possíveis habilidades iniciais.
     */
    public function createClass(int $userId, array $data): RPGClass
    {
        $data['user_id'] = $userId;
        $abilities = $data['abilities'] ?? [];
        unset($data['abilities']);

        $rpgClass = $this->rpgClassRepository->create($data);

        foreach ($abilities as $abilityData) {
            $this->abilityRepository->create([
                'rpg_class_id' => $rpgClass->id,
                'name' => $abilityData['name'],
                'description' => $abilityData['description'] ?? null,
            ]);
        }

        return $this->rpgClassRepository->findById($rpgClass->id);
    }

    /**
     * Atualiza os dados de uma classe, garantindo que pertença ao usuário.
     */
    public function updateClass(int $id, int $userId, array $data): RPGClass
    {
        $class = $this->rpgClassRepository->findById($id);

        if (! $class) {
            throw new NotFoundHttpException('Classe não encontrada.');
        }

        if ($class->user_id !== $userId) {
            throw new AccessDeniedHttpException('Apenas o criador da classe pode editá-la.');
        }

        unset($data['user_id']);
        return $this->rpgClassRepository->update($class, $data);
    }

    /**
     * Exclui uma classe, garantindo que pertença ao usuário.
     */
    public function deleteClass(int $id, int $userId): void
    {
        $class = $this->rpgClassRepository->findById($id);

        if (! $class) {
            throw new NotFoundHttpException('Classe não encontrada.');
        }

        if ($class->user_id !== $userId) {
            throw new AccessDeniedHttpException('Apenas o criador da classe pode removê-la.');
        }

        $this->rpgClassRepository->delete($class);
    }

    /**
     * Adiciona uma habilidade a uma classe existente.
     */
    public function addAbility(int $classId, int $userId, array $data): ClassAbility
    {
        $class = $this->rpgClassRepository->findById($classId);

        if (! $class) {
            throw new NotFoundHttpException('Classe não encontrada.');
        }

        if ($class->user_id !== $userId) {
            throw new AccessDeniedHttpException('Apenas o criador da classe pode adicionar habilidades a ela.');
        }

        $data['rpg_class_id'] = $class->id;
        return $this->abilityRepository->create($data);
    }

    /**
     * Remove uma habilidade de uma classe existente.
     */
    public function removeAbility(int $classId, int $abilityId, int $userId): void
    {
        $class = $this->rpgClassRepository->findById($classId);

        if (! $class) {
            throw new NotFoundHttpException('Classe não encontrada.');
        }

        if ($class->user_id !== $userId) {
            throw new AccessDeniedHttpException('Apenas o criador da classe pode remover habilidades dela.');
        }

        $ability = $this->abilityRepository->findById($abilityId);

        if (! $ability || $ability->rpg_class_id !== $classId) {
            throw new NotFoundHttpException('Habilidade não encontrada para esta classe.');
        }

        $this->abilityRepository->delete($ability);
    }
}
