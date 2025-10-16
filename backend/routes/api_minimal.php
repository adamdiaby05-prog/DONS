<?php

use Illuminate\Support\Facades\Route;

Route::get('/test', function () {
    return response()->json(['message' => 'Test works!']);
});

Route::get('/user', function () {
    return response()->json([
        'id' => 1,
        'name' => 'Test User'
    ]);
});

Route::get('/payments', function () {
    return response()->json([
        'success' => 1,
        'data' => []
    ]);
});
