<?php

namespace App\Http\Controllers;

use App\Http\Requests\Campaign\AttachCharacterRequest;
use App\Http\Requests\Campaign\AttachClassRequest;
use App\Http\Requests\Campaign\StoreCampaignRequest;
use App\Http\Requests\Campaign\UpdateCampaignRequest;
use App\Services\CampaignService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CampaignController extends Controller
{
    public function __construct(
        protected CampaignService $campaignService
    ) {}

    /**
     * Lista as campanhas onde o usuário é o mestre.
     */
    public function index(Request $request): JsonResponse
    {
        $campaigns = $this->campaignService->listMasterCampaigns($request->user()->id);

        return response()->json([
            'data' => $campaigns,
        ], 200);
    }

    /**
     * Lista as campanhas das quais o usuário participa como jogador.
     */
    public function indexPlayer(Request $request): JsonResponse
    {
        $campaigns = $this->campaignService->listParticipatingCampaigns($request->user()->id);

        return response()->json([
            'data' => $campaigns,
        ], 200);
    }

    /**
     * Cria uma nova campanha vinculada ao mestre autenticado.
     */
    public function store(StoreCampaignRequest $request): JsonResponse
    {
        $campaign = $this->campaignService->createCampaign($request->user()->id, $request->validated());

        return response()->json([
            'message' => 'Campanha criada com sucesso.',
            'data' => $campaign,
        ], 201);
    }

    /**
     * Exibe os detalhes de uma campanha.
     */
    public function show(int $id): JsonResponse
    {
        $campaign = $this->campaignService->getCampaign($id);

        return response()->json([
            'data' => $campaign,
        ], 200);
    }

    /**
     * Atualiza dados de uma campanha (restrito ao mestre).
     */
    public function update(UpdateCampaignRequest $request, int $id): JsonResponse
    {
        $campaign = $this->campaignService->updateCampaign($id, $request->user()->id, $request->validated());

        return response()->json([
            'message' => 'Campanha atualizada com sucesso.',
            'data' => $campaign,
        ], 200);
    }

    /**
     * Remove uma campanha (restrito ao mestre).
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $this->campaignService->deleteCampaign($id, $request->user()->id);

        return response()->json([
            'message' => 'Campanha removida com sucesso.',
        ], 200);
    }

    /**
     * Vincula um personagem à campanha (restrito ao mestre).
     */
    public function addCharacter(AttachCharacterRequest $request, int $id): JsonResponse
    {
        $campaign = $this->campaignService->addCharacter($id, $request->validated()['character_id'], $request->user()->id);

        return response()->json([
            'message' => 'Personagem adicionado à campanha com sucesso.',
            'data' => $campaign,
        ], 200);
    }

    /**
     * Desvincula um personagem da campanha (restrito ao mestre).
     */
    public function removeCharacter(Request $request, int $id, int $characterId): JsonResponse
    {
        $campaign = $this->campaignService->removeCharacter($id, $characterId, $request->user()->id);

        return response()->json([
            'message' => 'Personagem removido da campanha com sucesso.',
            'data' => $campaign,
        ], 200);
    }

    /**
     * Disponibiliza uma classe na campanha (restrito ao mestre).
     */
    public function addClass(AttachClassRequest $request, int $id): JsonResponse
    {
        $campaign = $this->campaignService->addClass($id, $request->validated()['rpg_class_id'], $request->user()->id);

        return response()->json([
            'message' => 'Classe disponibilizada na campanha com sucesso.',
            'data' => $campaign,
        ], 200);
    }

    /**
     * Remove a disponibilização de uma classe na campanha (restrito ao mestre).
     */
    public function removeClass(Request $request, int $id, int $classId): JsonResponse
    {
        $campaign = $this->campaignService->removeClass($id, $classId, $request->user()->id);

        return response()->json([
            'message' => 'Disponibilidade da classe removida da campanha com sucesso.',
            'data' => $campaign,
        ], 200);
    }
}
