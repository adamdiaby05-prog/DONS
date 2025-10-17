<?php
/**
 * Serveur de test simple pour l'application Flutter
 * Ce fichier doit être accessible sur http://localhost:8000/test_simple.php
 */

// Configuration CORS pour Flutter
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept, Authorization');
header('Content-Type: application/json');

// Gérer les requêtes OPTIONS (CORS preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$request_uri = $_SERVER['REQUEST_URI'];
$method = $_SERVER['REQUEST_METHOD'];

// Endpoint de test principal
if ($request_uri === '/test_simple.php' && $method === 'GET') {
    echo json_encode([
        'success' => true,
        'message' => 'Serveur de test Flutter fonctionne correctement !',
        'timestamp' => date('c'),
        'server' => 'Test Simple Server',
        'status' => 'success',
        'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown'
    ]);
    exit();
}

// Endpoint pour sauvegarder un paiement (POST)
if ($request_uri === '/test_simple.php' && $method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        http_response_code(422);
        echo json_encode([
            'success' => false,
            'error' => 'Données JSON invalides'
        ]);
        exit();
    }
    
    // Validation des champs requis
    $required_fields = ['amount', 'phone_number', 'payment_method'];
    foreach ($required_fields as $field) {
        if (empty($input[$field])) {
            http_response_code(422);
            echo json_encode([
                'success' => false,
                'error' => "Le champ $field est requis"
            ]);
            exit();
        }
    }
    
    // Simuler la sauvegarde du paiement
    $payment_data = [
        'id' => rand(1000, 9999),
        'payment_reference' => 'PAY_' . date('Ymd') . '_' . rand(1000, 9999),
        'amount' => (float)$input['amount'],
        'phone_number' => $input['phone_number'],
        'payment_method' => $input['payment_method'],
        'status' => $input['status'] ?? 'pending',
        'created_at' => date('c')
    ];
    
    echo json_encode([
        'success' => true,
        'message' => 'Paiement sauvegardé avec succès',
        'payment' => $payment_data,
        'database' => 'Simulation réussie'
    ]);
    exit();
}

// Endpoint par défaut
http_response_code(404);
echo json_encode([
    'success' => false,
    'error' => 'Endpoint non trouvé',
    'request_uri' => $request_uri,
    'method' => $method,
    'available_endpoints' => [
        'GET /test_simple.php' => 'Test de connexion',
        'POST /test_simple.php' => 'Sauvegarder un paiement'
    ]
]);
?>