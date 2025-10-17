<?php
// Script pour vérifier que tous les fichiers sont inclus dans le déploiement

$requiredFiles = [
    // Backend Laravel
    'backend/',
    'backend/public/',
    'backend/app/',
    'backend/config/',
    'backend/database/',
    'backend/routes/',
    'backend/vendor/',
    
    // Frontend Flutter
    'frontend/',
    'frontend/lib/',
    'frontend/web/',
    'frontend/build/',
    
    // Fichiers PHP
    'api_payments_direct.php',
    'api_payments_simple.php',
    'api_save_payment_simple.php',
    'api_save_payment.php',
    'barapay_payment_integration.php',
    'payment_callback.php',
    'payment_cancel.php',
    'payment_success.php',
    
    // BPay SDK
    'bpay_sdk/',
    'backend/bpay_sdk/',
    
    // Fichiers de test
    'test_api_call.php',
    'test_barapay_integration.php',
    'test_flutter_api.php',
    'test_flutter_barapay_integration.php',
    'test_simple_api.php',
    'test_simple.php',
    
    // Scripts de base de données
    'script-complet-dons.sql',
    'create-tables.sql',
    'init-database.php',
    'test-database-tables.php',
    'test-db-connection.php',
    
    // Configuration
    'nixpacks.toml',
    'public/index.php',
    'backend/env.production'
];

echo "Vérification des fichiers requis pour le déploiement DONS :\n\n";

foreach ($requiredFiles as $file) {
    if (file_exists($file)) {
        echo "✅ $file\n";
    } else {
        echo "❌ $file (manquant)\n";
    }
}

echo "\nVérification terminée.\n";
?>
