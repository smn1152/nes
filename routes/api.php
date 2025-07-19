<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// API Version 1
Route::prefix('v1')->group(function () {
    // Public routes
    Route::get('/products', [\App\Http\Controllers\ProductController::class, 'index']);
    Route::get('/products/{product}', [\App\Http\Controllers\ProductController::class, 'show']);
    
    // Protected routes
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/products', [\App\Http\Controllers\ProductController::class, 'store']);
        Route::put('/products/{product}', [\App\Http\Controllers\ProductController::class, 'update']);
        Route::delete('/products/{product}', [\App\Http\Controllers\ProductController::class, 'destroy']);
    });
});
