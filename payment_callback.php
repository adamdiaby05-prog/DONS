<?php

/**
 * Callback de paiement Barapay
 * Cette page reçoit les notifications de statut de paiement de Barapay
 */

require_once 'barapay_payment_integration.php';

// Désactiver l'affichage des erreurs en production
ini_set('display_errors', 0);
error_reporting(E_ALL);

// Fonction pour logger les erreurs
function logCallback($message, $data = []) {
    $logFile = __DIR__ . '/logs/barapay_callbacks.log';
    $logDir = dirname($logFile);
    
    if (!is_dir($logDir)) {
        mkdir($logDir, 0777, true);
    }
    
    error_log(date('Y-m-d H:i:s') . " - $message - " . json_encode($data) . "\n", 3, $logFile);
}

// Fonction pour mettre à jour le statut d'une commande
function updateOrderStatus($orderNo, $status, $transactionId = null, $reason = null) {
    // TODO: Implémenter la logique de mise à jour de votre base de données
    // Exemple:
    // $pdo = new PDO('mysql:host=localhost;dbname=your_db', 'user', 'password');
    // $stmt = $pdo->prepare("UPDATE orders SET status = ?, transaction_id = ?, reason = ?, updated_at = NOW() WHERE order_no = ?");
    // $stmt->execute([$status, $transactionId, $reason, $orderNo]);
    
    logCallback("Mise à jour commande $orderNo", [
        'status' => $status,
        'transaction_id' => $transactionId,
        'reason' => $reason
    ]);
}

// Fonction pour envoyer un email de confirmation
function sendConfirmationEmail($orderNo, $transactionId, $amount, $currency) {
    // TODO: Implémenter l'envoi d'email
    // Exemple:
    // $to = 'customer@example.com';
    // $subject = 'Confirmation de paiement - Commande ' . $orderNo;
    // $message = "Votre paiement de $amount $currency a été confirmé. Transaction: $transactionId";
    // mail($to, $subject, $message);
    
    logCallback("Email de confirmation envoyé", [
        'order_no' => $orderNo,
        'transaction_id' => $transactionId,
        'amount' => $amount,
        'currency' => $currency
    ]);
}

try {
    // 1. Récupérer les données brutes du callback
    $rawData = file_get_contents('php://input');
    
    // Fonction pour récupérer les headers (compatible avec tous les environnements)
    if (function_exists('getallheaders')) {
        $headers = getallheaders();
    } else {
        $headers = [];
        foreach ($_SERVER as $name => $value) {
            if (substr($name, 0, 5) == 'HTTP_') {
                $headers[str_replace(' ', '-', ucwords(strtolower(str_replace('_', ' ', substr($name, 5)))))] = $value;
            }
        }
    }
    
    // 2. Logger les données reçues (debug)
    logCallback("Callback reçu", [
        'headers' => $headers,
        'raw_data' => $rawData,
        'method' => $_SERVER['REQUEST_METHOD'],
        'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown'
    ]);

    // 3. Vérifier que c'est une requête POST
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        http_response_code(405);
        echo json_encode(['status' => 'error', 'message' => 'Method not allowed']);
        exit;
    }

    // 4. Décoder les données JSON
    if (empty($rawData)) {
        throw new BpayException('Aucune donnée reçue');
    }
    
    $data = json_decode($rawData, true, 512, JSON_THROW_ON_ERROR);
    
    // 5. Vérifier la signature si présente
    if (isset($headers['X-Bpay-Signature'])) {
        $signature = $headers['X-Bpay-Signature'];
        $expectedSignature = hash_hmac('sha256', $rawData, BARAPAY_CLIENT_SECRET);
        
        if ($signature !== $expectedSignature) {
            logCallback("Signature invalide", [
                'received' => $signature,
                'expected' => $expectedSignature
            ]);
            throw new BpayException('Signature invalide');
        }
        
        logCallback("Signature vérifiée avec succès");
    }

    // 6. Traiter la réponse selon le statut
    if (!isset($data['status'])) {
        throw new BpayException('Statut manquant dans la réponse');
    }

    $orderNo = $data['orderNo'] ?? null;
    $transactionId = $data['transactionId'] ?? null;
    $amount = $data['amount'] ?? null;
    $currency = $data['currency'] ?? null;

    switch ($data['status']) {
        case 'success':
            // Paiement réussi
            logCallback("Paiement réussi", [
                'order_no' => $orderNo,
                'transaction_id' => $transactionId,
                'amount' => $amount,
                'currency' => $currency
            ]);
            
            // Mettre à jour la base de données
            updateOrderStatus($orderNo, 'paid', $transactionId);
            
            // Envoyer email de confirmation
            if ($orderNo && $transactionId && $amount && $currency) {
                sendConfirmationEmail($orderNo, $transactionId, $amount, $currency);
            }
            
            http_response_code(200);
            echo json_encode([
                'status' => 'success', 
                'message' => 'Paiement traité avec succès',
                'order_no' => $orderNo,
                'transaction_id' => $transactionId
            ]);
            break;

        case 'failed':
            // Paiement échoué
            $reason = $data['reason'] ?? 'Raison inconnue';
            
            logCallback("Paiement échoué", [
                'order_no' => $orderNo,
                'reason' => $reason,
                'amount' => $amount,
                'currency' => $currency
            ]);
            
            // Mettre à jour la base de données
            updateOrderStatus($orderNo, 'failed', null, $reason);
            
            http_response_code(200); // On répond 200 même en cas d'échec pour indiquer qu'on a bien reçu
            echo json_encode([
                'status' => 'error', 
                'message' => 'Paiement échoué',
                'order_no' => $orderNo,
                'reason' => $reason
            ]);
            break;

        case 'pending':
            // Paiement en attente
            logCallback("Paiement en attente", [
                'order_no' => $orderNo,
                'amount' => $amount,
                'currency' => $currency
            ]);
            
            // Mettre à jour la base de données
            updateOrderStatus($orderNo, 'pending');
            
            http_response_code(200);
            echo json_encode([
                'status' => 'pending', 
                'message' => 'Paiement en attente',
                'order_no' => $orderNo
            ]);
            break;

        default:
            throw new BpayException('Statut de paiement inconnu: ' . $data['status']);
    }

} catch (BpayException $e) {
    logCallback("Erreur Barapay", [
        'message' => $e->getMessage(),
        'code' => $e->getCode()
    ]);
    http_response_code(400);
    echo json_encode([
        'status' => 'error', 
        'message' => $e->getMessage()
    ]);
} catch (\JsonException $e) {
    logCallback("Erreur JSON", [
        'message' => $e->getMessage(),
        'raw_data' => $rawData
    ]);
    http_response_code(400);
    echo json_encode([
        'status' => 'error', 
        'message' => 'Données JSON invalides'
    ]);
} catch (\Exception $e) {
    logCallback("Erreur inattendue", [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ]);
    http_response_code(500);
    echo json_encode([
        'status' => 'error', 
        'message' => 'Erreur interne du serveur'
    ]);
}
