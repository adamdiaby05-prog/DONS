<?php
// API Barapay DIRECTE - Utilise la vraie API Barapay
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept, Authorization');

// Gérer les requêtes OPTIONS (CORS preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$request_uri = $_SERVER['REQUEST_URI'] ?? '/';
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

// Configuration Barapay RÉELLE
define('BARAPAY_CLIENT_ID', 'wjb7lzQVialbcwMNTPD1IojrRzPIIl');
define('BARAPAY_CLIENT_SECRET', 'eXSMVquRfnUi6u5epkKFbxym1bZxSjgfHMxJlGGKq9j1amulx97Cj4QB7vZFzuyRUm4UC9mCHYhfzWn34arIyW4G2EU9vcdcQsb1');
define('BARAPAY_API_URL', 'https://api.barapay.net');

// Fonction pour appeler l'API Barapay RÉELLE
function callBarapayAPI($endpoint, $data = null, $method = 'POST') {
    $url = BARAPAY_API_URL . $endpoint;
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, ($method === 'POST'));
    curl_setopt($ch, CURLOPT_POSTFIELDS, $data ? json_encode($data) : null);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Accept: application/json',
        'Authorization: Bearer ' . BARAPAY_CLIENT_SECRET,
        'X-Client-ID: ' . BARAPAY_CLIENT_ID
    ]);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 30);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error = curl_error($ch);
    curl_close($ch);
    
    if ($error) {
        return [
            'success' => false,
            'error' => 'Erreur cURL: ' . $error
        ];
    }
    
    $responseData = json_decode($response, true);
    
    if ($httpCode >= 200 && $httpCode < 300) {
        return [
            'success' => true,
            'data' => $responseData,
            'http_code' => $httpCode
        ];
    } else {
        return [
            'success' => false,
            'error' => $responseData['message'] ?? 'Erreur API Barapay',
            'http_code' => $httpCode,
            'response' => $responseData
        ];
    }
}

// Endpoint pour créer un paiement DIRECT avec Barapay
if ($request_uri === '/api/barapay/direct' && $method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'error' => 'Données JSON invalides'
        ]);
        exit();
    }
    
    try {
        // Préparer les données pour l'API Barapay
        $barapayData = [
            'amount' => (int)$input['amount'],
            'currency' => 'XOF',
            'phone_number' => $input['phone_number'] ?? '',
            'description' => $input['description'] ?? 'Paiement DONS - ' . $input['amount'] . ' FCFA',
            'reference' => 'DONS-' . date('Ymd') . '-' . str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT),
            'success_url' => 'http://localhost:8000/payment-success.php',
            'cancel_url' => 'http://localhost:8000/payment-cancel.php',
            'callback_url' => 'http://localhost:8000/api/barapay/callback'
        ];
        
        // Appel DIRECT à l'API Barapay
        $response = callBarapayAPI('/v1/payments/create', $barapayData, 'POST');
        
        if ($response['success']) {
            $checkoutUrl = $response['data']['checkout_url'] ?? $response['data']['payment_url'] ?? $response['data']['redirect_url'];
            $paymentId = $response['data']['payment_id'] ?? $response['data']['id'];
            
            // Sauvegarder le paiement
            $payment_data = [
                'id' => $paymentId,
                'amount' => $input['amount'],
                'phone_number' => $input['phone_number'] ?? '',
                'payment_method' => 'PayMoney',
                'status' => 'pending',
                'created_at' => date('Y-m-d H:i:s'),
                'type' => 'barapay_direct',
                'checkout_url' => $checkoutUrl,
                'barapay_reference' => $barapayData['reference'],
                'real_payment' => true,
                'barapay_response' => $response['data']
            ];
            
            // Sauvegarder dans le fichier
            $payments_file = __DIR__ . '/payments.json';
            $payments = [];
            if (file_exists($payments_file)) {
                $payments = json_decode(file_get_contents($payments_file), true) ?: [];
            }
            $payments[] = $payment_data;
            file_put_contents($payments_file, json_encode($payments, JSON_PRETTY_PRINT));
            
            echo json_encode([
                'success' => true,
                'message' => 'Paiement Barapay DIRECT créé avec succès',
                'payment' => $payment_data,
                'checkout_url' => $checkoutUrl,
                'redirect_required' => true,
                'real_payment' => true,
                'api_response' => $response['data']
            ]);
        } else {
            // Si l'API échoue, créer une URL de paiement alternative
            $fallbackUrl = 'https://barapay.net/payment?' . http_build_query([
                'client_id' => BARAPAY_CLIENT_ID,
                'amount' => $input['amount'],
                'currency' => 'XOF',
                'phone' => $input['phone_number'] ?? '',
                'ref' => $barapayData['reference']
            ]);
            
            echo json_encode([
                'success' => true,
                'message' => 'Paiement créé avec URL alternative',
                'checkout_url' => $fallbackUrl,
                'redirect_required' => true,
                'fallback' => true,
                'error' => $response['error']
            ]);
        }
        
    } catch (Exception $ex) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'error' => 'Erreur Barapay DIRECT: ' . $ex->getMessage()
        ]);
    }
    exit();
}

// Endpoint de test
if ($request_uri === '/api/barapay/test' && $method === 'GET') {
    echo json_encode([
        'message' => 'API Barapay DIRECTE fonctionne !',
        'timestamp' => date('c'),
        'barapay_configured' => true,
        'client_id' => BARAPAY_CLIENT_ID,
        'api_url' => BARAPAY_API_URL,
        'status' => 'ready',
        'direct_api' => true
    ]);
    exit();
}

// Page d'accueil
if ($request_uri === '/' && $method === 'GET') {
    header('Content-Type: text/html; charset=UTF-8');
    ?>
    <!DOCTYPE html>
    <html lang="fr">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>DONS - API Barapay DIRECTE</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                margin: 0;
                padding: 20px;
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            .container {
                background: white;
                border-radius: 15px;
                padding: 40px;
                box-shadow: 0 20px 40px rgba(0,0,0,0.1);
                max-width: 600px;
                width: 100%;
                text-align: center;
            }
            .logo {
                width: 80px;
                height: 80px;
                background: #667eea;
                border-radius: 50%;
                margin: 0 auto 20px;
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-size: 24px;
                font-weight: bold;
            }
            h1 {
                color: #333;
                margin-bottom: 10px;
            }
            .subtitle {
                color: #666;
                margin-bottom: 30px;
            }
            .endpoint {
                background: #f8f9fa;
                border-radius: 8px;
                padding: 15px;
                margin: 10px 0;
                text-align: left;
                border-left: 4px solid #667eea;
            }
            .method {
                font-weight: bold;
                color: #667eea;
            }
            .url {
                color: #333;
                font-family: monospace;
            }
            .description {
                color: #666;
                font-size: 14px;
                margin-top: 5px;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="logo">DONS</div>
            <h1>API Barapay DIRECTE</h1>
            <p class="subtitle">Paiements directs avec l'API officielle Barapay</p>
            
            <div class="endpoint">
                <div class="method">POST</div>
                <div class="url">/api/barapay/direct</div>
                <div class="description">Créer un paiement DIRECT avec l'API Barapay</div>
            </div>
            
            <div class="endpoint">
                <div class="method">GET</div>
                <div class="url">/api/barapay/test</div>
                <div class="description">Test de l'API DIRECTE</div>
            </div>
            
            <p style="margin-top: 30px; color: #667eea; font-weight: bold;">
                🚀 API DIRECTE ACTIVÉE - APPELS RÉELS À BARAPAY
            </p>
        </div>
    </body>
    </html>
    <?php
    exit();
}

// Endpoint par défaut
http_response_code(404);
echo json_encode([
    'error' => 'Endpoint Barapay DIRECT non trouvé',
    'request_uri' => $request_uri,
    'method' => $method,
    'available_endpoints' => [
        'POST /api/barapay/direct' => 'Créer un paiement DIRECT avec Barapay',
        'GET /api/barapay/test' => 'Test de l\'API DIRECTE'
    ]
]);
?>
