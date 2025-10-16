<?php

use Illuminate\Support\Facades\Route;

Route::get('/test-simple', function () {
    return response()->json(['message' => 'Simple test works!']);
});
