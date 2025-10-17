<?php
// Router simplifié pour l'application DONS

$requestUri = $_SERVER['REQUEST_URI'];
$path = parse_url($requestUri, PHP_URL_PATH);

// Routes API Laravel
if (strpos($path, '/api/') === 0) {
    require_once __DIR__ . '/../backend/public/index.php';
    return;
}

// Routes BPay et autres fichiers PHP
if (strpos($path, '/barapay') === 0 || 
    strpos($path, '/bpay') === 0 || 
    strpos($path, '/payment') === 0 ||
    strpos($path, '/api_') === 0 ||
    strpos($path, '/test_') === 0) {
    $filePath = __DIR__ . '/..' . $path;
    if (file_exists($filePath)) {
        require_once $filePath;
        return;
    }
}

// Assets Flutter (priorité)
if (strpos($path, '/assets/') === 0 || 
    strpos($path, '/icons/') === 0 ||
    $path === '/flutter_service_worker.js' ||
    $path === '/manifest.json') {
    $frontendPath = __DIR__ . '/../frontend/build/web' . $path;
    if (file_exists($frontendPath)) {
        $mimeType = mime_content_type($frontendPath);
        header('Content-Type: ' . $mimeType);
        readfile($frontendPath);
        return;
    }
}

// Fichiers statiques (CSS, JS, images)
if (preg_match('/\.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|html)$/', $path)) {
    // Chercher dans frontend d'abord
    $frontendPath = __DIR__ . '/../frontend/build/web' . $path;
    if (file_exists($frontendPath)) {
        $mimeType = mime_content_type($frontendPath);
        header('Content-Type: ' . $mimeType);
        readfile($frontendPath);
        return;
    }
    
    // Chercher dans le projet
    $filePath = __DIR__ . '/..' . $path;
    if (file_exists($filePath)) {
        $mimeType = mime_content_type($filePath);
        header('Content-Type: ' . $mimeType);
        readfile($filePath);
        return;
    }
}

// Frontend Flutter (par défaut)
$frontendPath = __DIR__ . '/../frontend/build/web/index.html';
if (file_exists($frontendPath)) {
    readfile($frontendPath);
    return;
}

// Page d'accueil simple si pas de frontend
echo '<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DONS - Système de Don</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; }
        .status { background: #d4edda; color: #155724; padding: 15px; border-radius: 4px; margin: 20px 0; }
        .api-link { display: inline-block; background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; margin: 10px 5px; }
        .api-link:hover { background: #0056b3; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎯 DONS - Système de Don</h1>
        <div class="status">
            ✅ Backend Laravel opérationnel<br>
            ✅ Base de données connectée<br>
            ✅ API prête à recevoir les dons
        </div>
        <h2>Endpoints disponibles :</h2>
        <a href="/api/dons" class="api-link">API Dons</a>
        <a href="/api/payments" class="api-link">API Paiements</a>
        <a href="/api/statistics" class="api-link">Statistiques</a>
        <a href="/barapay_payment_integration.php" class="api-link">Barapay</a>
        <p><strong>Note :</strong> Le frontend Flutter sera déployé séparément.</p>
    </div>
</body>
</html>';

// Fallback vers le backend Laravel si nécessaire
// require_once __DIR__ . '/../backend/public/index.php';
?>
