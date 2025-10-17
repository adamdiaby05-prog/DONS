<?php

require_once dirname(__DIR__) . '/vendor/autoload.php';

use Bpay\Api\Payment;
use Bpay\Exception\BpayException;

// Désactiver l'affichage des erreurs en production
ini_set('display_errors', 0);
error_reporting(E_ALL);

// Fonction pour logger les erreurs
function logError($message, $data = []) {
    error_log(date('Y-m-d H:i:s') . " - $message - " . json_encode($data) . "\n", 3, __DIR__ . '/payment_errors.log');
}

try {
    // 1. Récupérer les données brutes du callback
    $rawData = file_get_contents('php://input');
    $headers = getallheaders();
    
    // 2. Logger les données reçues (debug)
    error_log("Callback reçu - Headers: " . json_encode($headers) . " - Data: " . $rawData, 3, __DIR__ . '/callbacks.log');

    // 3. Décoder les données JSON
    $data = json_decode($rawData, true, 512, JSON_THROW_ON_ERROR);
    
    // 4. Vérifier la signature si présente
    if (isset($headers['X-Bpay-Signature'])) {
        $signature = $headers['X-Bpay-Signature'];
        $expectedSignature = hash_hmac('sha256', $rawData, 'votre_client_secret');
        
        if ($signature !== $expectedSignature) {
            throw new BpayException('Signature invalide');
        }
    }

    // 5. Traiter la réponse selon le statut
    if (!isset($data['status'])) {
        throw new BpayException('Statut manquant dans la réponse');
    }

    switch ($data['status']) {
        case 'success':
            // Paiement réussi
            $orderNo = $data['orderNo'] ?? null;
            $transactionId = $data['transactionId'] ?? null;
            
            // TODO: Mettre à jour votre base de données
            // updateOrder($orderNo, 'paid', $transactionId);
            
            http_response_code(200);
            echo json_encode(['status' => 'success', 'message' => 'Paiement traité avec succès']);
            break;

        case 'failed':
            // Paiement échoué
            $orderNo = $data['orderNo'] ?? null;
            $reason = $data['reason'] ?? 'Raison inconnue';
            
            // TODO: Mettre à jour votre base de données
            // updateOrder($orderNo, 'failed', null, $reason);
            
            logError('Paiement échoué', ['orderNo' => $orderNo, 'reason' => $reason]);
            http_response_code(200); // On répond 200 même en cas d'échec pour indiquer qu'on a bien reçu
            echo json_encode(['status' => 'error', 'message' => 'Paiement échoué']);
            break;

        case 'pending':
            // Paiement en attente
            $orderNo = $data['orderNo'] ?? null;
            
            // TODO: Mettre à jour votre base de données
            // updateOrder($orderNo, 'pending');
            
            http_response_code(200);
            echo json_encode(['status' => 'pending', 'message' => 'Paiement en attente']);
            break;

        default:
            throw new BpayException('Statut de paiement inconnu: ' . $data['status']);
    }

} catch (BpayException $e) {
    logError('Erreur Bpay', ['message' => $e->getMessage()]);
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
} catch (\JsonException $e) {
    logError('Erreur JSON', ['message' => $e->getMessage(), 'data' => $rawData]);
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Données JSON invalides']);
} catch (\Exception $e) {
    logError('Erreur inattendue', ['message' => $e->getMessage()]);
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Erreur interne du serveur']);
} 