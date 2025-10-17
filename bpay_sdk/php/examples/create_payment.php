<?php

require_once dirname(__DIR__) . '/vendor/autoload.php';

use Bpay\Api\Amount;
use Bpay\Api\Payer;
use Bpay\Api\Payment;
use Bpay\Api\RedirectUrls;
use Bpay\Api\Transaction;
use Bpay\Exception\BpayException;

try {
    // 1. Créer l'objet Amount (montant et devise)
    $amount = new Amount();
    $amount->setTotal(10000)  // 10,000 FCFA
           ->setCurrency('XOF');

    // 2. Créer l'objet Transaction avec le numéro de commande
    $transaction = new Transaction();
    $transaction->setAmount($amount)
                ->setOrderNo('CMD' . time()); // Numéro unique de commande

    // 3. Définir la méthode de paiement
    $payer = new Payer();
    $payer->setPaymentMethod('Bpay'); // ou 'Orange', 'MTN', 'Wave', etc.

    // 4. Configurer les URLs de redirection
    $redirectUrls = new RedirectUrls();
    $redirectUrls->setSuccessUrl('http://localhost/payment/success')
                 ->setCancelUrl('http://localhost/payment/cancel');

    // 5. Créer et configurer le paiement
    $payment = new Payment();
    $payment->setCredentials([
        'client_id'     => 'CLIENT_ID',
        'client_secret' => 'CLIENT_SECRET'
    ])
    ->setPayer($payer)
    ->setTransaction($transaction)
    ->setRedirectUrls($redirectUrls);

    // 6. Créer le paiement (cela va aussi gérer l'authentification)
    $payment->create();

    // 7. Récupérer l'URL de paiement
    $approvedUrl = $payment->getApprovedUrl();

    // 8. Rediriger l'utilisateur ou retourner l'URL
    if (php_sapi_name() !== 'cli') {
        if (!headers_sent()) {
            header('Location: ' . $approvedUrl);
            exit;
        } else {
            echo "<script>window.location.href = '" . htmlspecialchars($approvedUrl, ENT_QUOTES) . "';</script>";
            echo "Si vous n'êtes pas redirigé automatiquement, <a href='" . 
                 htmlspecialchars($approvedUrl, ENT_QUOTES) . "'>cliquez ici</a>";
        }
    } else {
        echo "URL de paiement : " . $approvedUrl . PHP_EOL;
    }

} catch (BpayException $e) {
    // Gestion des erreurs Bpay
    error_log("Erreur Bpay : " . $e->getMessage());
    die("Erreur Bpay : " . $e->getMessage() . PHP_EOL);
} catch (\Exception $e) {
    // Gestion des autres erreurs
    error_log("Erreur : " . $e->getMessage());
    die("Erreur : " . $e->getMessage() . PHP_EOL);
} 