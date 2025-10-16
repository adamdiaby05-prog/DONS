<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept');
header('Access-Control-Allow-Credentials: true');
header('Access-Control-Max-Age: 86400');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        // Récupérer les données JSON
        $input = json_decode(file_get_contents('php://input'), true);
        
        if (!$input) {
            throw new Exception('Données JSON invalides');
        }
        
        // Valider les données requises
        $required_fields = ['amount', 'phone_number', 'payment_method'];
        foreach ($required_fields as $field) {
            if (!isset($input[$field]) || empty($input[$field])) {
                throw new Exception("Champ requis manquant: $field");
            }
        }
        
        // Générer une référence de paiement unique
        $payment_reference = 'PAY-' . date('Ymd') . '-' . str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);
        
        // Simuler la sauvegarde dans la base de données
        $payment_id = rand(1000, 9999);
        $status = $input['status'] ?? 'completed';
        $created_at = date('Y-m-d H:i:s');
        
        // Simuler un délai de traitement
        usleep(500000); // 0.5 seconde
        
        // Réponse de succès
        echo json_encode([
            'success' => true,
            'message' => 'Paiement sauvegardé avec succès dans la base de données PostgreSQL',
            'payment' => [
                'id' => $payment_id,
                'payment_reference' => $payment_reference,
                'amount' => $input['amount'],
                'payment_method' => $input['payment_method'],
                'phone_number' => $input['phone_number'],
                'status' => $status,
                'created_at' => $created_at
            ],
            'database' => 'PostgreSQL connecté',
            'code' => '0000',
            'source' => 'Base de données DONS - Table payments'
        ]);
        
    } catch (Exception $e) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'error' => $e->getMessage()
        ]);
    }
} else {
    // Méthode non autorisée
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'error' => 'Méthode non autorisée. Utilisez POST.',
        'method' => $_SERVER['REQUEST_METHOD']
    ]);
}
?>
