<?php

namespace App\Http\Controllers;

use App\Http\Requests\Invitation\SendInvitationRequest;
use App\Services\CampaignInvitationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CampaignInvitationController extends Controller
{
    public function __construct(
        protected CampaignInvitationService $invitationService
    ) {}

    /**
     * Lista personagens de um jogador específico disponíveis para serem convidados para uma campanha.
     */
    public function availableCharacters(Request $request, int $campaignId): JsonResponse
    {
        $email = $request->query('email') ?? $request->query('search');
        $characters = $this->invitationService->listAvailableCharacters(
            $campaignId,
            $request->user()->id,
            $email
        );

        return response()->json([
            'data' => $characters,
        ], 200);
    }

    /**
     * O mestre envia um convite para um personagem entrar na campanha.
     */
    public function store(SendInvitationRequest $request, int $campaignId): JsonResponse
    {
        $invitation = $this->invitationService->sendInvitation(
            $campaignId,
            (int) $request->validated('character_id'),
            $request->user()->id
        );

        return response()->json([
            'message' => 'Convite enviado com sucesso.',
            'data' => $invitation,
        ], 201);
    }

    /**
     * Lista todos os convites pendentes recebidos pelo jogador autenticado.
     */
    public function pending(Request $request): JsonResponse
    {
        $invitations = $this->invitationService->listPendingInvitations($request->user()->id);

        return response()->json([
            'data' => $invitations,
        ], 200);
    }

    /**
     * O jogador aceita o convite e insere seu personagem na campanha.
     */
    public function accept(Request $request, int $id): JsonResponse
    {
        $invitation = $this->invitationService->acceptInvitation($id, $request->user()->id);

        return response()->json([
            'message' => 'Convite aceito! O personagem agora faz parte da campanha.',
            'data' => $invitation,
        ], 200);
    }

    /**
     * O jogador recusa o convite para a campanha.
     */
    public function reject(Request $request, int $id): JsonResponse
    {
        $invitation = $this->invitationService->rejectInvitation($id, $request->user()->id);

        return response()->json([
            'message' => 'Convite recusado com sucesso.',
            'data' => $invitation,
        ], 200);
    }
}
