<?php

use Illuminate\Support\Facades\Route;

// Simple test routes
Route::get('/test', function () {
    return response()->json(['message' => 'API Test works!']);
});

Route::get('/user', function () {
    return response()->json([
        'id' => 1,
        'name' => 'Test User',
        'email' => 'test@example.com'
    ]);
});

Route::get('/payments', function () {
    return response()->json([
        'success' => 1,
        'data' => [
            ['id' => 1, 'amount' => 5000, 'status' => 'completed']
        ]
    ]);
});
