<?php

namespace App\Services;

use App\Models\Character;
use App\Repositories\CharacterRepository;
use App\Repositories\RPGClassRepository;
use Illuminate\Database\Eloquent\Collection;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class CharacterService
{
    public function __construct(
        protected CharacterRepository $characterRepository,
        protected RPGClassRepository $rpgClassRepository
    ) {}

    /**
     * Retorna a lista de personagens pertencentes ao usuário autenticado.
     */
    public function listCharacters(int $userId): Collection
    {
        return $this->characterRepository->getAllByUser($userId);
    }

    /**
     * Obtém um personagem específico com suas relações.
     */
    public function getCharacter(int $id): Character
    {
        $character = $this->characterRepository->findById($id);

        if (! $character) {
            throw new NotFoundHttpException('Personagem não encontrado.');
        }

        return $character;
    }

    /**
     * Cria um novo personagem, aplicando características iniciais da classe escolhida.
     */
    public function createCharacter(int $userId, array $data): Character
    {
        $data['user_id'] = $userId;

        // Se uma classe for informada, herda os atributos iniciais caso não tenham sido especificados
        if (! empty($data['rpg_class_id'])) {
            $class = $this->rpgClassRepository->findById($data['rpg_class_id']);

            if ($class) {
                if (! isset($data['hp_current'])) {
                    $data['hp_current'] = $class->hp_base;
                }
                if (! isset($data['gold'])) {
                    $data['gold'] = $class->gold_initial;
                }
            }
        }

        return $this->characterRepository->create($data);
    }

    /**
     * Atualiza dados do personagem, garantindo que pertença ao usuário.
     */
    public function updateCharacter(int $id, int $userId, array $data): Character
    {
        $character = $this->characterRepository->findById($id);

        if (! $character) {
            throw new NotFoundHttpException('Personagem não encontrado.');
        }

        if ($character->user_id !== $userId) {
            throw new AccessDeniedHttpException('Apenas o criador do personagem pode editá-lo.');
        }

        unset($data['user_id']);
        return $this->characterRepository->update($character, $data);
    }

    /**
     * Remove um personagem, garantindo que pertença ao usuário.
     */
    public function deleteCharacter(int $id, int $userId): void
    {
        $character = $this->characterRepository->findById($id);

        if (! $character) {
            throw new NotFoundHttpException('Personagem não encontrado.');
        }

        if ($character->user_id !== $userId) {
            throw new AccessDeniedHttpException('Apenas o criador do personagem pode removê-lo.');
        }

        $this->characterRepository->delete($character);
    }
}
