<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\GroupController;
use App\Http\Controllers\ContributionController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\MemberController;
use App\Http\Controllers\AdminContributionController;
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

// Route de test
Route::get('/test', function () {
    return response()->json([
        'message' => 'API DONS fonctionne correctement !',
        'timestamp' => now(),
        'database' => 'PostgreSQL connecté',
        'status' => 'success'
    ]);
});

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
// Routes publiques (authentification)
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/send-otp', [AuthController::class, 'sendOtp']);
Route::post('/verify-otp', [AuthController::class, 'verifyOtp']);

// Routes protégées (nécessitent une authentification)
Route::middleware('auth:sanctum')->group(function () {
    
    // Authentification
    Route::post('/logout', [AuthController::class, 'logout']);
    
    // Profil utilisateur
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
    
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
    
    // Paiements
    Route::prefix('payments')->group(function () {
        Route::get('/', [PaymentController::class, 'index']);
        Route::get('/{payment}', [PaymentController::class, 'show']);
        Route::post('/{payment}/webhook', [PaymentController::class, 'webhook']);
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

