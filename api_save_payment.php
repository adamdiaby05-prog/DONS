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

// Inclure l'intégration Barapay
require_once 'barapay_payment_integration.php';

// Configuration de la base de données PostgreSQL
$host = 'localhost';
$port = '5432';
$dbname = 'dons';
$user = 'postgres';
$password = '0000';

try {
    // Connexion à PostgreSQL
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
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
        
        // Vérifier si c'est un paiement Barapay
        $is_barapay_payment = ($input['payment_method'] === 'barapay' || 
                              $input['payment_method'] === 'Bpay' || 
                              $input['payment_method'] === 'mobile_money');
        
        $checkout_url = null;
        $barapay_reference = null;
        
        if ($is_barapay_payment) {
            try {
                // Créer un paiement Barapay
                $orderNo = 'DONS_' . time() . '_' . rand(1000, 9999);
                $paymentUrl = createBarapayPayment(
                    $input['amount'],
                    'XOF',
                    $orderNo,
                    'Bpay'
                );
                
                $checkout_url = $paymentUrl;
                $barapay_reference = $orderNo;
                
            } catch (Exception $e) {
                // En cas d'erreur Barapay, continuer avec un paiement normal
                error_log("Erreur Barapay: " . $e->getMessage());
            }
        }
        
        // Préparer la requête d'insertion
        $sql = "INSERT INTO payments (
            contribution_id, 
            payment_reference, 
            amount, 
            payment_method, 
            phone_number, 
            status, 
            gateway_response, 
            processed_at, 
            created_at, 
            updated_at
        ) VALUES (
            :contribution_id,
            :payment_reference,
            :amount,
            :payment_method,
            :phone_number,
            :status,
            :gateway_response,
            :processed_at,
            :created_at,
            :updated_at
        ) RETURNING id";
        
        $stmt = $pdo->prepare($sql);
        
        // Valeurs par défaut
        $contribution_id = 1; // ID de contribution par défaut
        $status = $input['status'] ?? 'completed';
        
        // Gateway response avec informations Barapay si applicable
        $gateway_response_data = [
            'source' => 'Flutter App',
            'timestamp' => date('c'),
            'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown'
        ];
        
        if ($is_barapay_payment && $checkout_url) {
            $gateway_response_data['barapay'] = [
                'checkout_url' => $checkout_url,
                'reference' => $barapay_reference,
                'integration' => 'Barapay SDK'
            ];
        }
        
        $gateway_response = json_encode($gateway_response_data);
        $processed_at = date('Y-m-d H:i:s');
        $created_at = date('Y-m-d H:i:s');
        $updated_at = date('Y-m-d H:i:s');
        
        // Exécuter la requête
        $stmt->execute([
            ':contribution_id' => $contribution_id,
            ':payment_reference' => $payment_reference,
            ':amount' => $input['amount'],
            ':payment_method' => $input['payment_method'],
            ':phone_number' => $input['phone_number'],
            ':status' => $status,
            ':gateway_response' => $gateway_response,
            ':processed_at' => $processed_at,
            ':created_at' => $created_at,
            ':updated_at' => $updated_at
        ]);
        
        // Récupérer l'ID du paiement créé
        $payment_id = $stmt->fetchColumn();
        
        // Préparer la réponse
        $response = [
            'success' => true,
            'message' => 'Paiement sauvegardé avec succès dans la base de données',
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
            'code' => '0000'
        ];
        
        // Ajouter les informations Barapay si applicable
        if ($is_barapay_payment && $checkout_url) {
            $response['checkout_url'] = $checkout_url;
            $response['barapay_reference'] = $barapay_reference;
            $response['payment']['barapay_reference'] = $barapay_reference;
        }
        
        // Réponse de succès
        echo json_encode($response);
        
    } else {
        // Méthode non autorisée
        http_response_code(405);
        echo json_encode([
            'success' => false,
            'error' => 'Méthode non autorisée. Utilisez POST.',
            'method' => $_SERVER['REQUEST_METHOD']
        ]);
    }
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Erreur de base de données: ' . $e->getMessage(),
        'database' => 'PostgreSQL non connecté'
    ]);
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
