<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\GroupController;
use App\Http\Controllers\ContributionController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\MemberController;
use App\Http\Controllers\AdminContributionController;
use App\Http\Controllers\CampaignController;
use App\Http\Middleware\CorsMiddleware;
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

// Gestion des requêtes OPTIONS (preflight CORS) - Route globale
Route::options('{any}', function () {
    return response('', 200)
        ->header('Access-Control-Allow-Origin', '*')
        ->header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        ->header('Access-Control-Allow-Headers', 'Content-Type, Authorization, Accept, X-Requested-With, X-CSRF-TOKEN')
        ->header('Access-Control-Allow-Credentials', 'true')
        ->header('Access-Control-Max-Age', '86400');
})->where('any', '.*');

// Routes OPTIONS spécifiques pour les endpoints protégés
Route::options('user', function () {
    return response('', 200)
        ->header('Access-Control-Allow-Origin', '*')
        ->header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        ->header('Access-Control-Allow-Headers', 'Content-Type, Authorization, Accept, X-Requested-With, X-CSRF-TOKEN')
        ->header('Access-Control-Allow-Credentials', 'true')
        ->header('Access-Control-Max-Age', '86400');
});

Route::options('payments', function () {
    return response('', 200)
        ->header('Access-Control-Allow-Origin', '*')
        ->header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        ->header('Access-Control-Allow-Headers', 'Content-Type, Authorization, Accept, X-Requested-With, X-CSRF-TOKEN')
        ->header('Access-Control-Allow-Credentials', 'true')
        ->header('Access-Control-Max-Age', '86400');
});

// Route racine de l'API
Route::get('/', function () {
    return response()->json([
        'message' => 'API DONS - Système de gestion de cotisations',
        'version' => '1.0.0',
        'timestamp' => now(),
        'status' => 'success',
        'endpoints' => [
            'GET /api/test' => 'Test de connexion',
            'GET /api/campaign' => 'Informations de campagne',
            'POST /api/payments/initiate' => 'Initier un paiement',
            'GET /api/payments' => 'Liste des paiements'
        ]
    ]);
});

// Route de test
Route::get('/test', function () {
    return response()->json([
        'message' => 'API DONS fonctionne correctement !',
        'timestamp' => now(),
        'database' => 'PostgreSQL connecté',
        'status' => 'success'
    ]);
});

// Route de test simple pour debug
Route::get('/debug', function () {
    return response()->json([
        'message' => 'Debug route works!',
        'timestamp' => now()
    ]);
});

// Route de test pour l'authentification
Route::get('/test-auth', function (Request $request) {
    return response()->json([
        'message' => 'Test auth',
        'user' => $request->user(),
        'authenticated' => auth()->check()
    ]);
})->middleware('auth:sanctum');

// Route de test pour les paiements
Route::get('/payments/test', function () {
    return response()->json([
        'message' => 'API Paiements fonctionne correctement !',
        'timestamp' => now(),
        'endpoints' => [
            'POST /api/payments/initiate' => 'Initier un nouveau paiement',
            'GET /api/payments' => 'Liste des paiements',
            'GET /api/payments/{id}' => 'Détails d\'un paiement',
        ]
    ]);
});

// Routes pour la campagne (publiques)
Route::prefix('campaign')->group(function () {
    Route::get('/', [CampaignController::class, 'getCampaign']);
    Route::get('/priorities', [CampaignController::class, 'getPriorities']);
});

// Routes pour les paiements (publiques pour les tests)
Route::prefix('payments')->middleware(CorsMiddleware::class)->group(function () {
    Route::get('/', [PaymentController::class, 'index']);
    Route::post('/', [PaymentController::class, 'store']);
    Route::get('/{payment}', [PaymentController::class, 'show']);
    Route::post('/{payment}/webhook', [PaymentController::class, 'webhook']);
});

// Route de test pour l'authentification (publique pour les tests CORS)
Route::get('/user', function (Request $request) {
    $headers = $request->headers->all();
    $auth_header = $request->header('Authorization', '');
    
    if (strpos($auth_header, 'Bearer ') === 0) {
        // Simuler un utilisateur connecté pour les tests CORS
        return response()->json([
            'id' => 1,
            'first_name' => 'Admin',
            'last_name' => 'Test',
            'phone_number' => '0701234567',
            'email' => 'admin@test.com',
            'phone_verified' => true,
            'is_admin' => true,
            'test_mode' => true
        ]);
    } else {
        return response()->json([
            'success' => 0,
            'message' => 'Token d\'authentification requis'
        ], 401);
    }
});

// Route de test pour les paiements (publique pour les tests CORS)
Route::get('/payments', function (Request $request) {
    $page = $request->get('page', 1);
    
    return response()->json([
        'success' => 1,
        'data' => [
            [
                'id' => 1,
                'amount' => 5000,
                'status' => 'completed',
                'created_at' => now()->format('Y-m-d H:i:s'),
                'test_mode' => true
            ],
            [
                'id' => 2,
                'amount' => 3000,
                'status' => 'pending',
                'created_at' => now()->format('Y-m-d H:i:s'),
                'test_mode' => true
            ]
        ],
        'pagination' => [
            'current_page' => $page,
            'total' => 2,
            'per_page' => 10
        ]
    ]);
});

// Routes publiques (authentification)
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/send-otp', [AuthController::class, 'sendOtp']);
Route::post('/verify-otp', [AuthController::class, 'verifyOtp']);

// Routes protégées (nécessitent une authentification)
Route::middleware('auth:sanctum')->group(function () {
    
    // Authentification
    Route::post('/logout', [AuthController::class, 'logout']);
    
    // Groupes
    Route::prefix('groups')->group(function () {
        Route::get('/', [GroupController::class, 'index']);
        Route::post('/', [GroupController::class, 'store']);
        Route::get('/{group}', [GroupController::class, 'show']);
        Route::put('/{group}', [GroupController::class, 'update']);
        Route::post('/{group}/members', [GroupController::class, 'addMember']);
        Route::delete('/{group}/members', [GroupController::class, 'removeMember']);
        Route::get('/{group}/dashboard', [GroupController::class, 'dashboard']);
    });
    
    // Cotisations
    Route::prefix('contributions')->group(function () {
        Route::get('/', [ContributionController::class, 'index']);
        Route::get('/{contribution}', [ContributionController::class, 'show']);
        Route::post('/{contribution}/pay', [ContributionController::class, 'pay']);
    });
    
    // Route pour initier un nouveau paiement (sans authentification pour les tests)
    Route::post('/payments/initiate', [PaymentController::class, 'initiatePayment']);
    
    // Notifications
    Route::get('/notifications', function (Request $request) {
        return $request->user()->notifications()->latest()->paginate(20);
    });
    
    Route::put('/notifications/{notification}/read', function (Request $request, $notificationId) {
        $notification = $request->user()->notifications()->findOrFail($notificationId);
        $notification->update(['status' => 'sent']);
        return response()->json(['success' => 1]);
    });
});

// Routes d'administration (temporairement sans authentification pour les tests)
Route::prefix('admin')->group(function () {
    Route::get('/dashboard', [AdminController::class, 'dashboard']);
    Route::get('/groups', [AdminController::class, 'getAllGroups']);
    Route::post('/groups', [AdminController::class, 'createGroup']);
    Route::delete('/groups/{group}', [AdminController::class, 'deleteGroup']);
    
    // Gestion des membres
    Route::prefix('members')->group(function () {
        Route::get('/', [MemberController::class, 'index']);
        Route::post('/', [MemberController::class, 'store']);
        Route::get('/available-groups', [MemberController::class, 'getAvailableGroups']);
        Route::post('/add-to-group', [MemberController::class, 'addToGroup']);
        Route::post('/remove-from-group', [MemberController::class, 'removeFromGroup']);
        Route::get('/{member}', [MemberController::class, 'show']);
        Route::put('/{member}', [MemberController::class, 'update']);
        Route::delete('/{member}', [MemberController::class, 'destroy']);
    });

    // Gestion des cotisations
    Route::prefix('contributions')->group(function () {
        Route::get('/', [AdminContributionController::class, 'index']);
        Route::post('/', [AdminContributionController::class, 'store']);
        Route::get('/{contribution}', [AdminContributionController::class, 'show']);
        Route::put('/{contribution}', [AdminContributionController::class, 'update']);
        Route::delete('/{contribution}', [AdminContributionController::class, 'destroy']);
    });

    // Rapports et export
    Route::prefix('reports')->group(function () {
        Route::post('/financial', [AdminController::class, 'generateFinancialReport']);
        Route::post('/members', [AdminController::class, 'generateMembersReport']);
        Route::post('/contributions', [AdminController::class, 'generateContributionsReport']);
        Route::post('/groups', [AdminController::class, 'generateGroupsReport']);
    });

    Route::prefix('export')->group(function () {
        Route::post('/excel', [AdminController::class, 'exportToExcel']);
        Route::post('/pdf', [AdminController::class, 'exportToPDF']);
        Route::post('/csv', [AdminController::class, 'exportToCSV']);
    });

    // Paramètres
    Route::prefix('settings')->group(function () {
        Route::get('/', [AdminController::class, 'getSettings']);
        Route::put('/', [AdminController::class, 'updateSettings']);
    });
});
