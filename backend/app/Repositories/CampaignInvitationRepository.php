<?php

namespace App\Repositories;

use App\Models\CampaignInvitation;
use Illuminate\Database\Eloquent\Collection;

class CampaignInvitationRepository
{
    /**
     * Cria um novo convite para a campanha.
     */
    public function create(array $data): CampaignInvitation
    {
        return CampaignInvitation::create($data);
    }

    /**
     * Busca convite por ID com relações.
     */
    public function findById(int $id): ?CampaignInvitation
    {
        return CampaignInvitation::with([
            'campaign.master:id,name,email',
            'character.user:id,name,email',
            'character.rpgClass',
        ])->find($id);
    }

    /**
     * Busca convite por campanha e personagem.
     */
    public function findByCampaignAndCharacter(int $campaignId, int $characterId): ?CampaignInvitation
    {
        return CampaignInvitation::where('campaign_id', $campaignId)
            ->where('character_id', $characterId)
            ->first();
    }

    /**
     * Retorna todos os convites pendentes direcionados a personagens de um jogador.
     */
    public function getPendingByUser(int $userId): Collection
    {
        return CampaignInvitation::where('status', 'pendente')
            ->whereHas('character', function ($query) use ($userId) {
                $query->where('user_id', $userId);
            })
            ->with([
                'campaign.master:id,name,email',
                'character.rpgClass',
            ])
            ->orderByDesc('created_at')
            ->get();
    }

    /**
     * Retorna convites de uma determinada campanha.
     */
    public function getByCampaign(int $campaignId): Collection
    {
        return CampaignInvitation::where('campaign_id', $campaignId)
            ->with([
                'character.user:id,name,email',
                'character.rpgClass',
            ])
            ->orderByDesc('created_at')
            ->get();
    }

    /**
     * Atualiza o status do convite.
     */
    public function updateStatus(CampaignInvitation $invitation, string $status): CampaignInvitation
    {
        $invitation->update(['status' => $status]);
        return $invitation->fresh(['campaign', 'character']);
    }
}
