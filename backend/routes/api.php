<?php

use App\Http\Controllers\AuthController;

/*
|--------------------------------------------------------------------------
| API Routes for Flutter Application
|--------------------------------------------------------------------------
*/

$router->post('/api/register', [AuthController::class, 'register']);
$router->post('/api/login', [AuthController::class, 'login']);
$router->get('/api/me', [AuthController::class, 'me']);
