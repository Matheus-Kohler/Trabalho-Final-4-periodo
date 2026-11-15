<?php

namespace App\Http\Controllers;

use App\Http\Requests\RPGClass\StoreClassAbilityRequest;
use App\Http\Requests\RPGClass\StoreRPGClassRequest;
use App\Http\Requests\RPGClass\UpdateRPGClassRequest;
use App\Services\RPGClassService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RPGClassController extends Controller
{
    public function __construct(
        protected RPGClassService $classService
    ) {}

    /**
     * Lista todas as classes criadas pelo usuário autenticado.
     */
    public function index(Request $request): JsonResponse
    {
        $classes = $this->classService->listClasses($request->user()->id);

        return response()->json([
            'data' => $classes,
        ], 200);
    }

    /**
     * Cria uma nova classe com possíveis habilidades.
     */
    public function store(StoreRPGClassRequest $request): JsonResponse
    {
        $class = $this->classService->createClass($request->user()->id, $request->validated());

        return response()->json([
            'message' => 'Classe criada com sucesso.',
            'data' => $class,
        ], 201);
    }

    /**
     * Exibe os detalhes de uma classe específica.
     */
    public function show(int $id): JsonResponse
    {
        $class = $this->classService->getClass($id);

        return response()->json([
            'data' => $class,
        ], 200);
    }

    /**
     * Atualiza os dados de uma classe.
     */
    public function update(UpdateRPGClassRequest $request, int $id): JsonResponse
    {
        $class = $this->classService->updateClass($id, $request->user()->id, $request->validated());

        return response()->json([
            'message' => 'Classe atualizada com sucesso.',
            'data' => $class,
        ], 200);
    }

    /**
     * Remove uma classe.
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $this->classService->deleteClass($id, $request->user()->id);

        return response()->json([
            'message' => 'Classe removida com sucesso.',
        ], 200);
    }

    /**
     * Adiciona uma habilidade à classe.
     */
    public function addAbility(StoreClassAbilityRequest $request, int $id): JsonResponse
    {
        $ability = $this->classService->addAbility($id, $request->user()->id, $request->validated());

        return response()->json([
            'message' => 'Habilidade adicionada com sucesso.',
            'data' => $ability,
        ], 201);
    }

    /**
     * Remove uma habilidade da classe.
     */
    public function removeAbility(Request $request, int $classId, int $abilityId): JsonResponse
    {
        $this->classService->removeAbility($classId, $abilityId, $request->user()->id);

        return response()->json([
            'message' => 'Habilidade removida com sucesso.',
        ], 200);
    }
}
