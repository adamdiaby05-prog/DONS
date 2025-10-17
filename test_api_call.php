<?php

// Test de l'API Flutter + Barapay
$data = json_encode([
    'amount' => 5000,
    'phone_number' => '+2250701234567',
    'payment_method' => 'barapay',
    'status' => 'pending'
]);

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'http://localhost:8000/test_flutter_barapay_integration.php');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
echo "Response: $response\n";
?>
