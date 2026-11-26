<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BookmarkController;
use App\Http\Controllers\Api\PublicApiController;
use App\Http\Controllers\Api\TopicController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Public (tanpa auth)
|--------------------------------------------------------------------------
*/
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login',    [AuthController::class, 'login']);

// Proxy dummyjson
Route::prefix('public')->group(function () {
    Route::get('/posts',     [PublicApiController::class, 'index']);
    Route::get('/posts/{id}', [PublicApiController::class, 'show'])->whereNumber('id');
});

/*
|--------------------------------------------------------------------------
| Protected (Sanctum)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user',   [AuthController::class, 'user']);
    Route::put('/user', [AuthController::class, 'updateProfile']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // Topics (read-only, karena di-seed)
    Route::get('/topics',         [TopicController::class, 'index']);
    Route::get('/topics/{topic}', [TopicController::class, 'show']);

    Route::get('/bookmarks/check', [BookmarkController::class, 'check']);
    Route::apiResource('bookmarks', BookmarkController::class);
});