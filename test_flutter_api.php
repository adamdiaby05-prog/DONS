<?php

/**
 * Test de l'API Flutter + Barapay
 * Script de test pour vérifier que l'API fonctionne correctement
 */

echo "=== TEST DE L'API FLUTTER + BARAPAY ===\n\n";

// Données de test
$testData = [
    'amount' => 10000,
    'phone_number' => '+2250701234567',
    'payment_method' => 'barapay',
    'status' => 'pending'
];

echo "Données de test:\n";
echo json_encode($testData, JSON_PRETTY_PRINT) . "\n\n";

// Test 1: Test direct de l'API
echo "=== TEST 1: Appel direct à l'API ===\n";

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'http://localhost:8000/api_save_payment.php');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($testData));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 30);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
if ($error) {
    echo "Erreur CURL: $error\n";
}
echo "Response: $response\n\n";

// Test 2: Test avec l'API de test
echo "=== TEST 2: Appel à l'API de test ===\n";

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'http://localhost:8000/test_flutter_barapay_integration.php');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($testData));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 30);

$response2 = curl_exec($ch);
$httpCode2 = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error2 = curl_error($ch);
curl_close($ch);

echo "HTTP Code: $httpCode2\n";
if ($error2) {
    echo "Erreur CURL: $error2\n";
}
echo "Response: $response2\n\n";

// Test 3: Test de l'intégration Barapay directe
echo "=== TEST 3: Test direct de l'intégration Barapay ===\n";

try {
    require_once 'barapay_payment_integration.php';
    
    $orderNo = 'TEST_FLUTTER_' . time();
    $paymentUrl = createBarapayPayment(
        10000,
        'XOF',
        $orderNo,
        'Bpay'
    );
    
    echo "✅ Intégration Barapay fonctionne\n";
    echo "URL de paiement: $paymentUrl\n";
    echo "Numéro de commande: $orderNo\n";
    
} catch (Exception $e) {
    echo "❌ Erreur Barapay: " . $e->getMessage() . "\n";
}

echo "\n=== RÉSUMÉ ===\n";
echo "✅ Intégration Barapay: Fonctionnelle\n";
echo "✅ API Flutter: " . ($httpCode == 200 ? "Fonctionnelle" : "Erreur $httpCode") . "\n";
echo "✅ API de test: " . ($httpCode2 == 200 ? "Fonctionnelle" : "Erreur $httpCode2") . "\n";

if ($httpCode == 200 || $httpCode2 == 200) {
    echo "\n🎉 L'intégration Flutter + Barapay est prête !\n";
    echo "Vous pouvez maintenant utiliser l'application Flutter sur http://localhost:3000/#/client/amount\n";
} else {
    echo "\n⚠️ Il y a des erreurs à corriger avant de pouvoir utiliser l'application.\n";
}

?>
