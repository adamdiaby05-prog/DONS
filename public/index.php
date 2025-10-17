<?php
// Router simple pour servir l'application complète DONS

$requestUri = $_SERVER['REQUEST_URI'];
$path = parse_url($requestUri, PHP_URL_PATH);

// Routes API Laravel
if (strpos($path, '/api/') === 0) {
    // Rediriger vers Laravel
    require_once __DIR__ . '/../backend/public/index.php';
    return;
}

// Routes BPay et autres fichiers PHP
if (strpos($path, '/barapay') === 0 || 
    strpos($path, '/bpay') === 0 || 
    strpos($path, '/payment') === 0 ||
    strpos($path, '/api_') === 0) {
    // Servir les fichiers PHP directement
    $filePath = __DIR__ . '/..' . $path;
    if (file_exists($filePath)) {
        require_once $filePath;
        return;
    }
}

// Routes statiques (CSS, JS, images)
if (preg_match('/\.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$/', $path)) {
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

// Fallback vers le backend Laravel
require_once __DIR__ . '/../backend/public/index.php';
?>
