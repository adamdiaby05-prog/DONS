<?php
// Configuration CORS pour Dokploy
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=utf-8');

// Gestion des requêtes OPTIONS (preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Page d'accueil de l'API
$response = [
    'success' => true,
    'message' => 'API DONS Backend is running!',
    'version' => '1.0.0',
    'endpoints' => [
        'POST /api_save_payment_simple.php' => 'Créer un nouveau paiement',
        'GET /api_payments_status.php?payment_id=ID' => 'Vérifier le statut d\'un paiement',
        'GET /api_payments_history.php' => 'Historique des paiements'
    ],
    'timestamp' => date('Y-m-d H:i:s'),
    'server' => 'Dokploy PHP'
];

echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
?>