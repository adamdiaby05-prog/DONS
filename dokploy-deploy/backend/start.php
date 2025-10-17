<?php
/**
 * Script de démarrage pour l'API DONS Backend
 * Compatible avec Dokploy et autres plateformes de déploiement
 */

// Configuration des erreurs
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Headers CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=utf-8');

// Gestion des requêtes OPTIONS (preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Vérifier que PHP fonctionne
if (php_sapi_name() === 'cli-server') {
    echo "🚀 API DONS Backend démarrée avec succès!\n";
    echo "📍 URL: http://0.0.0.0:8000\n";
    echo "🔗 Endpoints disponibles:\n";
    echo "   - POST /api_save_payment_simple.php\n";
    echo "   - GET /api_payments_status.php\n";
    echo "   - GET /api_payments_history.php\n";
    echo "✅ Serveur prêt à recevoir des requêtes!\n";
} else {
    // Réponse pour les requêtes HTTP
    $response = [
        'success' => true,
        'message' => 'API DONS Backend is running!',
        'version' => '1.0.0',
        'status' => 'active',
        'endpoints' => [
            'POST /api_save_payment_simple.php' => 'Créer un nouveau paiement',
            'GET /api_payments_status.php?payment_id=ID' => 'Vérifier le statut d\'un paiement',
            'GET /api_payments_history.php' => 'Historique des paiements'
        ],
        'timestamp' => date('Y-m-d H:i:s'),
        'server' => 'Dokploy PHP'
    ];
    
    echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
