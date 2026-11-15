<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\CampaignController;
use App\Http\Controllers\CampaignInvitationController;
use App\Http\Controllers\CharacterController;
use App\Http\Controllers\RPGClassController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Rotas Públicas (Autenticação)
|--------------------------------------------------------------------------
*/
Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
});

/*
|--------------------------------------------------------------------------
| Rotas Protegidas por Autenticação Sanctum
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {
    // Auth & Perfil
    Route::prefix('auth')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/me', [AuthController::class, 'me']);
    });

    // 1. Classes do RPG (CRUD completo)
    Route::apiResource('classes', RPGClassController::class);
    Route::post('/classes/{id}/abilities', [RPGClassController::class, 'addAbility']);
    Route::delete('/classes/{classId}/abilities/{abilityId}', [RPGClassController::class, 'removeAbility']);

    // 2. Personagens (CRUD completo)
    Route::apiResource('characters', CharacterController::class);

    // 3. Campanhas (CRUD completo + visão mestre/jogador)
    Route::get('/campaigns/participating', [CampaignController::class, 'indexPlayer']);
    Route::apiResource('campaigns', CampaignController::class);

    // Vínculos da Campanha (gerenciados pelo mestre)
    Route::post('/campaigns/{id}/characters', [CampaignController::class, 'addCharacter']);
    Route::delete('/campaigns/{id}/characters/{characterId}', [CampaignController::class, 'removeCharacter']);
    Route::post('/campaigns/{id}/classes', [CampaignController::class, 'addClass']);
    Route::delete('/campaigns/{id}/classes/{classId}', [CampaignController::class, 'removeClass']);

    // 4. Convites de Campanha
    Route::get('/campaigns/{id}/invitations/available-characters', [CampaignInvitationController::class, 'availableCharacters']);
    Route::post('/campaigns/{id}/invitations', [CampaignInvitationController::class, 'store']);
    Route::get('/invitations/pending', [CampaignInvitationController::class, 'pending']);
    Route::post('/invitations/{id}/accept', [CampaignInvitationController::class, 'accept']);
    Route::post('/invitations/{id}/reject', [CampaignInvitationController::class, 'reject']);
});
