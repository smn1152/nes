<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// Product routes
Route::get('/products', [App\Http\Controllers\ProductController::class, 'index'])->name('products.index');
Route::get('/products/{slug}', [App\Http\Controllers\ProductController::class, 'show'])->name('products.show');

// Laravel Pulse Dashboard
Route::middleware(['auth'])->prefix('admin')->group(function () {
    Route::get('/pulse', function () { return view('pulse::dashboard'); })->name('pulse.dashboard');
});

// Product routes
Route::get('/products', [App\Http\Controllers\ProductController::class, 'index'])->name('products.index');
Route::get('/products/{slug}', [App\Http\Controllers\ProductController::class, 'show'])->name('products.show');

// Laravel Pulse Dashboard
Route::middleware(['auth'])->prefix('admin')->group(function () {
    Route::get('/pulse', function () { return view('pulse::dashboard'); })->name('pulse.dashboard');
});
