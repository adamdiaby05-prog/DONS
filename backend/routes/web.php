<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'message' => 'Serveur DONS - Système de gestion de cotisations',
        'version' => '1.0.0',
        'timestamp' => now(),
        'status' => 'success',
        'api_url' => url('/api'),
        'documentation' => [
            'API Base' => url('/api'),
            'Test API' => url('/api/test'),
            'Campaign API' => url('/api/campaign'),
            'Payments API' => url('/api/payments')
        ]
    ]);
});
