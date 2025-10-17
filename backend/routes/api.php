<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Route API principale
Route::get('/', function () {
    return response()->json([
        'message' => 'Serveur DONS - Système de gestion de cotisations',
        'version' => '1.0.0',
        'timestamp' => now()->toISOString(),
        'status' => 'success',
        'api_url' => url('/api'),
        'documentation' => [
            'API Base' => url('/api'),
            'Test API' => url('/api/test'),
            'Campaign API' => url('/api/campaign'),
            'Payments API' => url('/api/payments')
        ]
    ]);
});

// Route de test
Route::get('/test', function () {
    try {
        // Test de connexion à la base de données
        DB::connection()->getPdo();
        
        return response()->json([
            'message' => 'Test de connexion réussi',
            'status' => 'success',
            'database' => 'connected',
            'timestamp' => now()->toISOString()
        ]);
    } catch (Exception $e) {
        return response()->json([
            'message' => 'Erreur de connexion à la base de données',
            'status' => 'error',
            'error' => $e->getMessage(),
            'timestamp' => now()->toISOString()
        ], 500);
    }
});

// Route des campagnes
Route::get('/campaign', function () {
    return response()->json([
        'message' => 'API des campagnes DONS',
        'status' => 'success',
        'endpoints' => [
            'GET /api/campaign' => 'Liste des campagnes',
            'POST /api/campaign' => 'Créer une campagne',
            'GET /api/campaign/{id}' => 'Détails d\'une campagne',
            'PUT /api/campaign/{id}' => 'Modifier une campagne',
            'DELETE /api/campaign/{id}' => 'Supprimer une campagne'
        ],
        'timestamp' => now()->toISOString()
    ]);
});

// Route des paiements
Route::get('/payments', function () {
    return response()->json([
        'message' => 'API des paiements DONS',
        'status' => 'success',
        'endpoints' => [
            'GET /api/payments' => 'Liste des paiements',
            'POST /api/payments' => 'Créer un paiement',
            'GET /api/payments/{id}' => 'Détails d\'un paiement',
            'PUT /api/payments/{id}' => 'Modifier un paiement',
            'DELETE /api/payments/{id}' => 'Supprimer un paiement'
        ],
        'timestamp' => now()->toISOString()
    ]);
});

// Route des groupes
Route::get('/groups', function () {
    return response()->json([
        'message' => 'API des groupes DONS',
        'status' => 'success',
        'endpoints' => [
            'GET /api/groups' => 'Liste des groupes',
            'POST /api/groups' => 'Créer un groupe',
            'GET /api/groups/{id}' => 'Détails d\'un groupe',
            'PUT /api/groups/{id}' => 'Modifier un groupe',
            'DELETE /api/groups/{id}' => 'Supprimer un groupe'
        ],
        'timestamp' => now()->toISOString()
    ]);
});

// Route des membres
Route::get('/members', function () {
    return response()->json([
        'message' => 'API des membres DONS',
        'status' => 'success',
        'endpoints' => [
            'GET /api/members' => 'Liste des membres',
            'POST /api/members' => 'Créer un membre',
            'GET /api/members/{id}' => 'Détails d\'un membre',
            'PUT /api/members/{id}' => 'Modifier un membre',
            'DELETE /api/members/{id}' => 'Supprimer un membre'
        ],
        'timestamp' => now()->toISOString()
    ]);
});

// Route de santé
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'message' => 'API DONS fonctionne correctement',
        'timestamp' => now()->toISOString(),
        'version' => '1.0.0'
    ]);
});