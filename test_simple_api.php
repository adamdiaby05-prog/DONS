<?php

/**
 * Test de l'API simplifiée Flutter + Barapay
 */

echo "=== TEST DE L'API SIMPLIFIÉE FLUTTER + BARAPAY ===\n\n";

// Données de test
$testData = [
    'amount' => 15000,
    'phone_number' => '+2250701234567',
    'payment_method' => 'barapay',
    'status' => 'pending'
];

echo "Données de test:\n";
echo json_encode($testData, JSON_PRETTY_PRINT) . "\n\n";

// Test de l'API simplifiée
echo "=== TEST: Appel à l'API simplifiée ===\n";

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'http://localhost:8000/api_save_payment_simple.php');
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

// Analyser la réponse
if ($httpCode == 200) {
    $data = json_decode($response, true);
    if ($data && $data['success'] == true) {
        echo "✅ API fonctionne correctement !\n";
        
        if (isset($data['checkout_url'])) {
            echo "🔗 URL de paiement Barapay: " . $data['checkout_url'] . "\n";
            echo "📋 Référence Barapay: " . $data['barapay_reference'] . "\n";
            echo "💰 Montant: " . $data['payment']['amount'] . " FCFA\n";
            echo "📱 Téléphone: " . $data['payment']['phone_number'] . "\n";
        }
        
        echo "\n🎉 L'intégration Flutter + Barapay est prête !\n";
        echo "Vous pouvez maintenant utiliser l'application Flutter sur http://localhost:3000/#/client/amount\n";
    } else {
        echo "❌ Erreur dans la réponse API\n";
    }
} else {
    echo "❌ Erreur HTTP: $httpCode\n";
}

?>
