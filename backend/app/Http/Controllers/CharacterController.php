<?php

namespace App\Http\Controllers;

use App\Http\Requests\Character\StoreCharacterRequest;
use App\Http\Requests\Character\UpdateCharacterRequest;
use App\Services\CharacterService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CharacterController extends Controller
{
    public function __construct(
        protected CharacterService $characterService
    ) {}

    /**
     * Lista todos os personagens do usuário autenticado.
     */
    public function index(Request $request): JsonResponse
    {
        $characters = $this->characterService->listCharacters($request->user()->id);

        return response()->json([
            'data' => $characters,
        ], 200);
    }

    /**
     * Cria um novo personagem.
     */
    public function store(StoreCharacterRequest $request): JsonResponse
    {
        $character = $this->characterService->createCharacter($request->user()->id, $request->validated());

        return response()->json([
            'message' => 'Personagem criado com sucesso.',
            'data' => $character,
        ], 201);
    }

    /**
     * Exibe os detalhes de um personagem específico.
     */
    public function show(int $id): JsonResponse
    {
        $character = $this->characterService->getCharacter($id);

        return response()->json([
            'data' => $character,
        ], 200);
    }

    /**
     * Atualiza os dados de um personagem.
     */
    public function update(UpdateCharacterRequest $request, int $id): JsonResponse
    {
        $character = $this->characterService->updateCharacter($id, $request->user()->id, $request->validated());

        return response()->json([
            'message' => 'Personagem atualizado com sucesso.',
            'data' => $character,
        ], 200);
    }

    /**
     * Remove um personagem.
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $this->characterService->deleteCharacter($id, $request->user()->id);

        return response()->json([
            'message' => 'Personagem removido com sucesso.',
        ], 200);
    }
}
