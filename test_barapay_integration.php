<?php

/**
 * Test d'intégration Barapay
 * Script de test pour vérifier le bon fonctionnement de l'intégration
 */

require_once 'barapay_payment_integration.php';

// Configuration de test
$testConfig = [
    'amount' => 5000, // 5,000 FCFA
    'currency' => 'XOF',
    'orderNo' => 'TEST_' . time(),
    'paymentMethod' => 'Bpay'
];

?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test d'intégration Barapay</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 20px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .test-section {
            margin: 20px 0;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        .success {
            background: #d4edda;
            border-color: #c3e6cb;
            color: #155724;
        }
        .error {
            background: #f8d7da;
            border-color: #f5c6cb;
            color: #721c24;
        }
        .info {
            background: #d1ecf1;
            border-color: #bee5eb;
            color: #0c5460;
        }
        .btn {
            display: inline-block;
            padding: 12px 24px;
            background: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin: 10px 5px;
            transition: background 0.3s;
        }
        .btn:hover {
            background: #0056b3;
        }
        .btn-success {
            background: #28a745;
        }
        .btn-success:hover {
            background: #1e7e34;
        }
        .btn-danger {
            background: #dc3545;
        }
        .btn-danger:hover {
            background: #c82333;
        }
        .code {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            font-family: monospace;
            overflow-x: auto;
            margin: 10px 0;
        }
        .config-table {
            width: 100%;
            border-collapse: collapse;
            margin: 15px 0;
        }
        .config-table th, .config-table td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        .config-table th {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🧪 Test d'intégration Barapay</h1>
        
        <div class="test-section info">
            <h2>📋 Configuration de test</h2>
            <table class="config-table">
                <tr>
                    <th>Paramètre</th>
                    <th>Valeur</th>
                </tr>
                <tr>
                    <td>Client ID</td>
                    <td><?php echo htmlspecialchars(BARAPAY_CLIENT_ID); ?></td>
                </tr>
                <tr>
                    <td>Client Secret</td>
                    <td><?php echo htmlspecialchars(substr(BARAPAY_CLIENT_SECRET, 0, 20) . '...'); ?></td>
                </tr>
                <tr>
                    <td>Montant de test</td>
                    <td><?php echo number_format($testConfig['amount'], 0, ',', ' '); ?> <?php echo $testConfig['currency']; ?></td>
                </tr>
                <tr>
                    <td>Numéro de commande</td>
                    <td><?php echo $testConfig['orderNo']; ?></td>
                </tr>
                <tr>
                    <td>Méthode de paiement</td>
                    <td><?php echo $testConfig['paymentMethod']; ?></td>
                </tr>
            </table>
        </div>

        <?php
        // Test 1: Vérification des credentials
        echo '<div class="test-section">';
        echo '<h2>🔐 Test 1: Vérification des credentials</h2>';
        
        if (defined('BARAPAY_CLIENT_ID') && defined('BARAPAY_CLIENT_SECRET')) {
            if (!empty(BARAPAY_CLIENT_ID) && !empty(BARAPAY_CLIENT_SECRET)) {
                echo '<div class="success">✅ Credentials configurés correctement</div>';
                echo '<p>Client ID: ' . htmlspecialchars(BARAPAY_CLIENT_ID) . '</p>';
                echo '<p>Client Secret: ' . htmlspecialchars(substr(BARAPAY_CLIENT_SECRET, 0, 20) . '...') . '</p>';
            } else {
                echo '<div class="error">❌ Credentials manquants ou vides</div>';
            }
        } else {
            echo '<div class="error">❌ Constants BARAPAY_CLIENT_ID et BARAPAY_CLIENT_SECRET non définies</div>';
        }
        echo '</div>';

        // Test 2: Test de création de paiement
        echo '<div class="test-section">';
        echo '<h2>💳 Test 2: Création de paiement</h2>';
        
        try {
            $paymentUrl = createBarapayPayment(
                $testConfig['amount'],
                $testConfig['currency'],
                $testConfig['orderNo'],
                $testConfig['paymentMethod']
            );
            
            echo '<div class="success">✅ Paiement créé avec succès</div>';
            echo '<p><strong>URL de paiement générée:</strong></p>';
            echo '<div class="code">' . htmlspecialchars($paymentUrl) . '</div>';
            echo '<p><a href="' . htmlspecialchars($paymentUrl, ENT_QUOTES) . '" target="_blank" class="btn btn-success">Tester le paiement</a></p>';
            
        } catch (BpayException $e) {
            echo '<div class="error">❌ Erreur Barapay: ' . htmlspecialchars($e->getMessage()) . '</div>';
            echo '<p><strong>Code d\'erreur:</strong> ' . $e->getCode() . '</p>';
        } catch (\Exception $e) {
            echo '<div class="error">❌ Erreur générale: ' . htmlspecialchars($e->getMessage()) . '</div>';
        }
        echo '</div>';

        // Test 3: Vérification des fichiers requis
        echo '<div class="test-section">';
        echo '<h2>📁 Test 3: Vérification des fichiers</h2>';
        
        $requiredFiles = [
            'bpay_sdk/php/vendor/autoload.php' => 'Autoloader Composer',
            'barapay_payment_integration.php' => 'Fichier d\'intégration principal',
            'payment_success.php' => 'Page de succès',
            'payment_cancel.php' => 'Page d\'annulation',
            'payment_callback.php' => 'Callback de paiement'
        ];
        
        foreach ($requiredFiles as $file => $description) {
            if (file_exists($file)) {
                echo '<div class="success">✅ ' . $description . ' (' . $file . ')</div>';
            } else {
                echo '<div class="error">❌ ' . $description . ' manquant (' . $file . ')</div>';
            }
        }
        echo '</div>';

        // Test 4: Vérification des URLs de redirection
        echo '<div class="test-section">';
        echo '<h2>🔗 Test 4: URLs de redirection</h2>';
        
        $baseUrl = 'http://localhost'; // À adapter selon votre environnement
        $successUrl = $baseUrl . '/payment_success.php';
        $cancelUrl = $baseUrl . '/payment_cancel.php';
        $callbackUrl = $baseUrl . '/payment_callback.php';
        
        echo '<p><strong>URLs configurées:</strong></p>';
        echo '<ul>';
        echo '<li>Succès: <code>' . $successUrl . '</code></li>';
        echo '<li>Annulation: <code>' . $cancelUrl . '</code></li>';
        echo '<li>Callback: <code>' . $callbackUrl . '</code></li>';
        echo '</ul>';
        
        echo '<div class="info">';
        echo '<h3>⚠️ Configuration requise</h3>';
        echo '<p>Pour que l\'intégration fonctionne correctement, vous devez :</p>';
        echo '<ol>';
        echo '<li>Configurer ces URLs dans votre compte Barapay</li>';
        echo '<li>Adapter les URLs selon votre domaine de production</li>';
        echo '<li>Configurer le callback URL dans les paramètres de votre compte</li>';
        echo '</ol>';
        echo '</div>';
        echo '</div>';

        // Test 5: Test de callback simulé
        echo '<div class="test-section">';
        echo '<h2>📞 Test 5: Simulation de callback</h2>';
        
        $simulatedCallback = [
            'status' => 'success',
            'orderNo' => $testConfig['orderNo'],
            'transactionId' => 'BPAY_' . time(),
            'amount' => $testConfig['amount'],
            'currency' => $testConfig['currency']
        ];
        
        echo '<p><strong>Callback simulé:</strong></p>';
        echo '<div class="code">' . json_encode($simulatedCallback, JSON_PRETTY_PRINT) . '</div>';
        
        try {
            // Simuler le traitement du callback
            $result = handlePaymentCallback();
            echo '<div class="success">✅ Callback traité avec succès</div>';
            echo '<div class="code">' . json_encode($result, JSON_PRETTY_PRINT) . '</div>';
        } catch (\Exception $e) {
            echo '<div class="error">❌ Erreur lors du traitement du callback: ' . htmlspecialchars($e->getMessage()) . '</div>';
        }
        echo '</div>';
        ?>

        <div class="test-section info">
            <h2>📚 Instructions de déploiement</h2>
            <ol>
                <li><strong>Configurer les URLs</strong> dans votre compte Barapay</li>
                <li><strong>Adapter les URLs</strong> selon votre domaine de production</li>
                <li><strong>Tester en mode sandbox</strong> avant la production</li>
                <li><strong>Configurer les logs</strong> pour le monitoring</li>
                <li><strong>Implémenter la base de données</strong> pour stocker les commandes</li>
            </ol>
        </div>

        <div style="text-align: center; margin-top: 30px;">
            <a href="barapay_payment_integration.php" class="btn">Retour à l'intégration</a>
            <a href="/" class="btn btn-secondary">Accueil</a>
        </div>
    </div>
</body>
</html>
