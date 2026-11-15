<?php

namespace App\Services;

use App\Models\CampaignInvitation;
use App\Repositories\CampaignInvitationRepository;
use App\Repositories\CampaignRepository;
use App\Repositories\CharacterRepository;
use Illuminate\Database\Eloquent\Collection;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class CampaignInvitationService
{
    public function __construct(
        protected CampaignInvitationRepository $invitationRepository,
        protected CampaignRepository $campaignRepository,
        protected CharacterRepository $characterRepository
    ) {}

    /**
     * Lista personagens de um jogador específico (por e-mail) disponíveis para serem convidados para a campanha.
     * Apenas o mestre da campanha tem acesso.
     */
    public function listAvailableCharacters(int $campaignId, int $masterUserId, ?string $playerEmail = null): Collection
    {
        $campaign = $this->campaignRepository->findById($campaignId);
        if (! $campaign) {
            throw new NotFoundHttpException('Campanha não encontrada.');
        }

        if ($campaign->user_id !== $masterUserId) {
            throw new AccessDeniedHttpException('Apenas o mestre da campanha pode convidar personagens.');
        }

        return $this->characterRepository->getAvailableForCampaignInvite($campaignId, $playerEmail);
    }

    /**
     * O mestre envia um convite para o personagem entrar na campanha.
     */
    public function sendInvitation(int $campaignId, int $characterId, int $masterUserId): CampaignInvitation
    {
        $campaign = $this->campaignRepository->findById($campaignId);
        if (! $campaign) {
            throw new NotFoundHttpException('Campanha não encontrada.');
        }

        if ($campaign->user_id !== $masterUserId) {
            throw new AccessDeniedHttpException('Apenas o mestre da campanha pode enviar convites.');
        }

        $character = $this->characterRepository->findById($characterId);
        if (! $character) {
            throw new NotFoundHttpException('Personagem informado não existe.');
        }

        // Verifica se já faz parte da campanha
        if ($campaign->characters()->where('character_id', $characterId)->exists()) {
            throw new BadRequestHttpException('Este personagem já participa desta campanha.');
        }

        // Verifica se já há convite existente
        $existing = $this->invitationRepository->findByCampaignAndCharacter($campaignId, $characterId);
        if ($existing) {
            if ($existing->status === 'pendente') {
                throw new BadRequestHttpException('Já existe um convite pendente para este personagem.');
            }
            // Se foi recusado ou anterior, reativa como pendente
            return $this->invitationRepository->updateStatus($existing, 'pendente');
        }

        return $this->invitationRepository->create([
            'campaign_id' => $campaignId,
            'character_id' => $characterId,
            'status' => 'pendente',
        ]);
    }

    /**
     * Lista todos os convites pendentes para personagens do usuário logado.
     */
    public function listPendingInvitations(int $userId): Collection
    {
        return $this->invitationRepository->getPendingByUser($userId);
    }

    /**
     * O jogador aceita um convite de campanha para o seu personagem.
     */
    public function acceptInvitation(int $invitationId, int $userId): CampaignInvitation
    {
        $invitation = $this->invitationRepository->findById($invitationId);
        if (! $invitation) {
            throw new NotFoundHttpException('Convite não encontrado.');
        }

        if ($invitation->character->user_id !== $userId) {
            throw new AccessDeniedHttpException('Apenas o proprietário do personagem pode aceitar o convite.');
        }

        if ($invitation->status !== 'pendente') {
            throw new BadRequestHttpException('Este convite já foi respondido.');
        }

        // Atualiza status para aceito
        $invitation = $this->invitationRepository->updateStatus($invitation, 'aceito');

        // Vincula personagem à campanha
        $this->campaignRepository->attachCharacter($invitation->campaign, $invitation->character_id);

        return $invitation;
    }

    /**
     * O jogador recusa um convite de campanha para o seu personagem.
     */
    public function rejectInvitation(int $invitationId, int $userId): CampaignInvitation
    {
        $invitation = $this->invitationRepository->findById($invitationId);
        if (! $invitation) {
            throw new NotFoundHttpException('Convite não encontrado.');
        }

        if ($invitation->character->user_id !== $userId) {
            throw new AccessDeniedHttpException('Apenas o proprietário do personagem pode recusar o convite.');
        }

        if ($invitation->status !== 'pendente') {
            throw new BadRequestHttpException('Este convite já foi respondido.');
        }

        return $this->invitationRepository->updateStatus($invitation, 'recusado');
    }
}
