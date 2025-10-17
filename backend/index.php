<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept');

// Répondre aux requêtes OPTIONS pour CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Page d'accueil du serveur
$response = [
    'success' => true,
    'message' => 'Serveur Barapay API actif',
    'version' => '1.0.0',
    'endpoints' => [
        'POST /api_save_payment_simple.php' => 'Créer un paiement',
        'GET /api_payments_status.php' => 'Vérifier le statut d\'un paiement',
        'GET /api_payments_history.php' => 'Historique des paiements'
    ],
    'timestamp' => date('Y-m-d H:i:s'),
    'server' => 'PHP ' . phpversion()
];

echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
?>