<?php

/**
 * Intégration Barapay - Passerelle de paiement express
 * Basé sur la documentation officielle et le SDK Bpay
 */

require_once 'bpay_sdk/php/vendor/autoload.php';

use Bpay\Api\Amount;
use Bpay\Api\Payer;
use Bpay\Api\Payment;
use Bpay\Api\RedirectUrls;
use Bpay\Api\Transaction;
use Bpay\Exception\BpayException;

// Configuration des credentials Barapay
define('BARAPAY_CLIENT_ID', 'wjb7lzQVialbcwMNTPD1IojrRzPIIl');
define('BARAPAY_CLIENT_SECRET', 'eXSMVquRfnUi6u5epkKFbxym1bZxSjgfHMxJlGGKq9j1amulx97Cj4QB7vZFzuyRUm4UC9mCHYhfzWn34arIyW4G2EU9vcdcQsb1');

// Configuration du domaine (à adapter selon votre environnement)
$baseUrl = 'http://localhost'; // Changez selon votre domaine
$successUrl = $baseUrl . '/payment_success.php';
$cancelUrl = $baseUrl . '/payment_cancel.php';

/**
 * Fonction pour créer un paiement Barapay
 * 
 * @param float $amount Montant du paiement
 * @param string $currency Devise (XOF, USD, EUR, etc.)
 * @param string $orderNo Numéro de commande unique
 * @param string $paymentMethod Méthode de paiement (Bpay, Orange, MTN, Wave, etc.)
 * @return string URL de redirection vers le paiement
 * @throws BpayException
 */
function createBarapayPayment($amount, $currency = 'XOF', $orderNo = null, $paymentMethod = 'Bpay') {
    try {
        // 1. Créer l'objet Amount (montant et devise)
        $amountObj = new Amount();
        $amountObj->setTotal($amount)->setCurrency($currency);

        // 2. Créer l'objet Transaction avec le numéro de commande
        $transaction = new Transaction();
        $transaction->setAmount($amountObj);
        
        if ($orderNo) {
            $transaction->setOrderNo($orderNo);
        } else {
            $transaction->setOrderNo('CMD' . time() . rand(1000, 9999));
        }

        // 3. Définir la méthode de paiement
        $payer = new Payer();
        $payer->setPaymentMethod($paymentMethod);

        // 4. Configurer les URLs de redirection
        global $successUrl, $cancelUrl;
        $redirectUrls = new RedirectUrls();
        $redirectUrls->setSuccessUrl($successUrl)
                   ->setCancelUrl($cancelUrl);

        // 5. Créer et configurer le paiement
        $payment = new Payment();
        $payment->setCredentials([
            'client_id'     => BARAPAY_CLIENT_ID,
            'client_secret' => BARAPAY_CLIENT_SECRET
        ])
        ->setPayer($payer)
        ->setTransaction($transaction)
        ->setRedirectUrls($redirectUrls);

        // 6. Créer le paiement (cela va aussi gérer l'authentification)
        $payment->create();

        // 7. Récupérer l'URL de paiement
        return $payment->getApprovedUrl();

    } catch (BpayException $e) {
        error_log("Erreur Barapay : " . $e->getMessage());
        throw $e;
    } catch (\Exception $e) {
        error_log("Erreur générale : " . $e->getMessage());
        throw new BpayException("Erreur lors de la création du paiement : " . $e->getMessage());
    }
}

/**
 * Fonction pour traiter le callback de paiement
 * 
 * @return array Résultat du traitement
 */
function handlePaymentCallback() {
    try {
        // Récupérer les données brutes du callback
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
        
        // Logger les données reçues (debug)
        error_log("Callback Barapay reçu - Headers: " . json_encode($headers) . " - Data: " . $rawData);

        // Décoder les données JSON
        $data = json_decode($rawData, true, 512, JSON_THROW_ON_ERROR);
        
        // Vérifier la signature si présente
        if (isset($headers['X-Bpay-Signature'])) {
            $signature = $headers['X-Bpay-Signature'];
            $expectedSignature = hash_hmac('sha256', $rawData, BARAPAY_CLIENT_SECRET);
            
            if ($signature !== $expectedSignature) {
                throw new BpayException('Signature invalide');
            }
        }

        // Traiter la réponse selon le statut
        if (!isset($data['status'])) {
            throw new BpayException('Statut manquant dans la réponse');
        }

        $result = [
            'status' => $data['status'],
            'orderNo' => $data['orderNo'] ?? null,
            'transactionId' => $data['transactionId'] ?? null,
            'amount' => $data['amount'] ?? null,
            'currency' => $data['currency'] ?? null
        ];

        switch ($data['status']) {
            case 'success':
                // Paiement réussi
                error_log("Paiement réussi - Order: " . $result['orderNo'] . " - Transaction: " . $result['transactionId']);
                break;

            case 'failed':
                // Paiement échoué
                $result['reason'] = $data['reason'] ?? 'Raison inconnue';
                error_log("Paiement échoué - Order: " . $result['orderNo'] . " - Raison: " . $result['reason']);
                break;

            case 'pending':
                // Paiement en attente
                error_log("Paiement en attente - Order: " . $result['orderNo']);
                break;

            default:
                throw new BpayException('Statut de paiement inconnu: ' . $data['status']);
        }

        return $result;

    } catch (BpayException $e) {
        error_log("Erreur Barapay dans callback: " . $e->getMessage());
        throw $e;
    } catch (\JsonException $e) {
        error_log("Erreur JSON dans callback: " . $e->getMessage());
        throw new BpayException("Données JSON invalides");
    } catch (\Exception $e) {
        error_log("Erreur inattendue dans callback: " . $e->getMessage());
        throw new BpayException("Erreur interne du serveur");
    }
}

// Exemple d'utilisation
if (basename($_SERVER['PHP_SELF']) === 'barapay_payment_integration.php') {
    // Test de création de paiement
    try {
        echo "<h1>Test d'intégration Barapay</h1>";
        
        // Exemple de création de paiement
        $testAmount = 10000; // 10,000 FCFA
        $testCurrency = 'XOF';
        $testOrderNo = 'TEST_' . time();
        $testPaymentMethod = 'Bpay';
        
        echo "<h2>Création d'un paiement test</h2>";
        echo "<p>Montant: $testAmount $testCurrency</p>";
        echo "<p>Commande: $testOrderNo</p>";
        echo "<p>Méthode: $testPaymentMethod</p>";
        
        $paymentUrl = createBarapayPayment($testAmount, $testCurrency, $testOrderNo, $testPaymentMethod);
        
        echo "<h3>URL de paiement générée:</h3>";
        echo "<p><a href='" . htmlspecialchars($paymentUrl, ENT_QUOTES) . "' target='_blank'>" . htmlspecialchars($paymentUrl, ENT_QUOTES) . "</a></p>";
        
        echo "<h3>Instructions:</h3>";
        echo "<ul>";
        echo "<li>Cliquez sur le lien ci-dessus pour tester le paiement</li>";
        echo "<li>Configurez les URLs de redirection dans votre environnement</li>";
        echo "<li>Créez les fichiers payment_success.php et payment_cancel.php</li>";
        echo "<li>Configurez le callback URL dans votre compte Barapay</li>";
        echo "</ul>";
        
    } catch (BpayException $e) {
        echo "<h2>Erreur Barapay:</h2>";
        echo "<p style='color: red;'>" . htmlspecialchars($e->getMessage()) . "</p>";
    } catch (\Exception $e) {
        echo "<h2>Erreur générale:</h2>";
        echo "<p style='color: red;'>" . htmlspecialchars($e->getMessage()) . "</p>";
    }
}
