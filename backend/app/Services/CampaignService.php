<?php

namespace App\Services;

use App\Models\Campaign;
use App\Repositories\CampaignRepository;
use App\Repositories\CharacterRepository;
use App\Repositories\RPGClassRepository;
use Illuminate\Database\Eloquent\Collection;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class CampaignService
{
    public function __construct(
        protected CampaignRepository $campaignRepository,
        protected CharacterRepository $characterRepository,
        protected RPGClassRepository $rpgClassRepository
    ) {}

    /**
     * Lista campanhas onde o usuário é mestre.
     */
    public function listMasterCampaigns(int $userId): Collection
    {
        return $this->campaignRepository->getAllByMaster($userId);
    }

    /**
     * Lista campanhas em que o usuário participa como jogador.
     */
    public function listParticipatingCampaigns(int $userId): Collection
    {
        return $this->campaignRepository->getParticipatingByPlayer($userId);
    }

    /**
     * Busca detalhes de uma campanha.
     */
    public function getCampaign(int $id): Campaign
    {
        $campaign = $this->campaignRepository->findById($id);

        if (! $campaign) {
            throw new NotFoundHttpException('Campanha não encontrada.');
        }

        return $campaign;
    }

    /**
     * Cria uma nova campanha vinculada ao mestre autenticado.
     */
    public function createCampaign(int $userId, array $data): Campaign
    {
        $data['user_id'] = $userId;
        return $this->campaignRepository->create($data);
    }

    /**
     * Atualiza dados de uma campanha (apenas o mestre pode atualizar).
     */
    public function updateCampaign(int $id, int $userId, array $data): Campaign
    {
        $campaign = $this->campaignRepository->findById($id);

        if (! $campaign) {
            throw new NotFoundHttpException('Campanha não encontrada.');
        }

        if ($campaign->user_id !== $userId) {
            throw new AccessDeniedHttpException('Apenas o mestre da campanha tem permissão para alterá-la.');
        }

        unset($data['user_id']);
        return $this->campaignRepository->update($campaign, $data);
    }

    /**
     * Exclui uma campanha (apenas o mestre pode excluir).
     */
    public function deleteCampaign(int $id, int $userId): void
    {
        $campaign = $this->campaignRepository->findById($id);

        if (! $campaign) {
            throw new NotFoundHttpException('Campanha não encontrada.');
        }

        if ($campaign->user_id !== $userId) {
            throw new AccessDeniedHttpException('Apenas o mestre da campanha tem permissão para excluí-la.');
        }

        $this->campaignRepository->delete($campaign);
    }

    /**
     * O mestre vincula um personagem à campanha.
     */
    public function addCharacter(int $campaignId, int $characterId, int $userId): Campaign
    {
        $campaign = $this->campaignRepository->findById($campaignId);

        if (! $campaign) {
            throw new NotFoundHttpException('Campanha não encontrada.');
        }

        if ($campaign->user_id !== $userId) {
            throw new AccessDeniedHttpException('Apenas o mestre pode adicionar personagens a esta campanha.');
        }

        $character = $this->characterRepository->findById($characterId);
        if (! $character) {
            throw new NotFoundHttpException('Personagem informado não existe.');
        }

        $this->campaignRepository->attachCharacter($campaign, $characterId);
        return $this->campaignRepository->findById($campaignId);
    }

    /**
     * O mestre desvincula um personagem da campanha.
     */
    public function removeCharacter(int $campaignId, int $characterId, int $userId): Campaign
    {
        $campaign = $this->campaignRepository->findById($campaignId);

        if (! $campaign) {
            throw new NotFoundHttpException('Campanha não encontrada.');
        }

        if ($campaign->user_id !== $userId) {
            throw new AccessDeniedHttpException('Apenas o mestre pode remover personagens desta campanha.');
        }

        $this->campaignRepository->detachCharacter($campaign, $characterId);
        return $this->campaignRepository->findById($campaignId);
    }

    /**
     * O mestre disponibiliza uma classe para a campanha.
     */
    public function addClass(int $campaignId, int $rpgClassId, int $userId): Campaign
    {
        $campaign = $this->campaignRepository->findById($campaignId);

        if (! $campaign) {
            throw new NotFoundHttpException('Campanha não encontrada.');
        }

        if ($campaign->user_id !== $userId) {
            throw new AccessDeniedHttpException('Apenas o mestre pode disponibilizar classes nesta campanha.');
        }

        $class = $this->rpgClassRepository->findById($rpgClassId);
        if (! $class) {
            throw new NotFoundHttpException('Classe informada não existe.');
        }

        $this->campaignRepository->attachClass($campaign, $rpgClassId);
        return $this->campaignRepository->findById($campaignId);
    }

    /**
     * O mestre remove a disponibilização de uma classe da campanha.
     */
    public function removeClass(int $campaignId, int $rpgClassId, int $userId): Campaign
    {
        $campaign = $this->campaignRepository->findById($campaignId);

        if (! $campaign) {
            throw new NotFoundHttpException('Campanha não encontrada.');
        }

        if ($campaign->user_id !== $userId) {
            throw new AccessDeniedHttpException('Apenas o mestre pode remover classes disponibilizadas nesta campanha.');
        }

        $this->campaignRepository->detachClass($campaign, $rpgClassId);
        return $this->campaignRepository->findById($campaignId);
    }
}
