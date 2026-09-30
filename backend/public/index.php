<?php

/**
 * Modern Laravel-Compatible REST API Server for Flutter App
 */

// Enable CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Content-Type: application/json; charset=UTF-8');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// 1. Parse .env Configuration
$envFile = __DIR__ . '/../.env';
$env = [];
if (file_exists($envFile)) {
    $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        $line = trim($line);
        if (empty($line) || strpos($line, '#') === 0) continue;
        if (strpos($line, '=') !== false) {
            list($name, $value) = explode('=', $line, 2);
            $env[trim($name)] = trim($value, " \t\n\r\0\x0B\"'");
        }
    }
}

$dbConnection = strtolower($env['DB_CONNECTION'] ?? 'mysql');
$dbHost = $env['DB_HOST'] ?? '127.0.0.1';
$dbPort = $env['DB_PORT'] ?? '3306';
$dbName = $env['DB_DATABASE'] ?? 'flutter_db';
$dbUser = $env['DB_USERNAME'] ?? 'root';
$dbPass = $env['DB_PASSWORD'] ?? '';

try {
    if ($dbConnection === 'mysql') {
        // Connect to MySQL server (without selecting DB) to create DB if missing
        $pdoServer = new PDO("mysql:host=$dbHost;port=$dbPort", $dbUser, $dbPass);
        $pdoServer->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $pdoServer->exec("CREATE DATABASE IF NOT EXISTS `$dbName` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");

        // Connect to target database
        $pdo = new PDO("mysql:host=$dbHost;port=$dbPort;dbname=$dbName;charset=utf8mb4", $dbUser, $dbPass);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        // Auto-create users table in MySQL
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS users (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                email VARCHAR(255) NOT NULL UNIQUE,
                password VARCHAR(255) NOT NULL,
                api_token VARCHAR(255) NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ");

        // Auto-create expenses table in MySQL
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS expenses (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                description TEXT NULL,
                amount DECIMAL(12,2) NOT NULL,
                type VARCHAR(50) NOT NULL,
                date DATETIME NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ");
    } else {
        // SQLite Fallback
        $dbDir = __DIR__ . '/../database';
        if (!file_exists($dbDir)) {
            mkdir($dbDir, 0777, true);
        }
        $dbPath = $dbDir . '/database.sqlite';
        $pdo = new PDO('sqlite:' . $dbPath);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        $pdo->exec("
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                email TEXT NOT NULL UNIQUE,
                password TEXT NOT NULL,
                api_token TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ");

        $pdo->exec("
            CREATE TABLE IF NOT EXISTS expenses (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT,
                amount REAL NOT NULL,
                type TEXT NOT NULL,
                date DATETIME NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ");
    }

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database connection failed: ' . $e->getMessage()
    ]);
    exit();
}

// 2. Parse Request
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$method = $_SERVER['REQUEST_METHOD'];
$input = json_decode(file_get_contents('php://input'), true) ?? $_POST;

// 3. API Router

// POST /api/register
if ($uri === '/api/register' && $method === 'POST') {
    $name = trim($input['name'] ?? '');
    $email = strtolower(trim($input['email'] ?? ''));
    $password = $input['password'] ?? '';

    // Validation
    $errors = [];
    if (empty($name) || strlen($name) < 2) {
        $errors['name'] = 'Full Name is required and must be at least 2 characters.';
    }
    if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errors['email'] = 'A valid email address is required.';
    }
    if (empty($password) || strlen($password) < 8) {
        $errors['password'] = 'Password must be at least 8 characters.';
    }

    if (!empty($errors)) {
        http_response_code(422);
        echo json_encode([
            'success' => false,
            'message' => 'Validation failed',
            'errors' => $errors
        ]);
        exit();
    }

    // Check Duplicate Email
    $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        http_response_code(409);
        echo json_encode([
            'success' => false,
            'message' => 'Email address is already registered. Please sign in.'
        ]);
        exit();
    }

    // Hash Password & Generate API Token
    $hashedPassword = password_hash($password, PASSWORD_BCRYPT);
    $token = bin2hex(random_bytes(32));

    $stmt = $pdo->prepare("INSERT INTO users (name, email, password, api_token) VALUES (?, ?, ?, ?)");
    $stmt->execute([$name, $email, $hashedPassword, $token]);
    $userId = $pdo->lastInsertId();

    http_response_code(201);
    echo json_encode([
        'success' => true,
        'message' => 'User registered successfully!',
        'token' => $token,
        'user' => [
            'id' => $userId,
            'name' => $name,
            'email' => $email
        ]
    ]);
    exit();
}

// POST /api/login
if ($uri === '/api/login' && $method === 'POST') {
    $email = strtolower(trim($input['email'] ?? ''));
    $password = $input['password'] ?? '';

    if (empty($email) || empty($password)) {
        http_response_code(422);
        echo json_encode([
            'success' => false,
            'message' => 'Email and password are required.'
        ]);
        exit();
    }

    $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user || !password_verify($password, $user['password'])) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Invalid email or password credentials.'
        ]);
        exit();
    }

    // Generate New Token
    $token = bin2hex(random_bytes(32));
    $updateStmt = $pdo->prepare("UPDATE users SET api_token = ? WHERE id = ?");
    $updateStmt->execute([$token, $user['id']]);

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Login successful!',
        'token' => $token,
        'user' => [
            'id' => $user['id'],
            'name' => $user['name'],
            'email' => $user['email']
        ]
    ]);
    exit();
}

// GET /api/me
if ($uri === '/api/me' && $method === 'GET') {
    $headers = getallheaders();
    $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';
    $token = str_replace('Bearer ', '', $authHeader);

    if (empty($token)) {
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'Unauthenticated']);
        exit();
    }

    $stmt = $pdo->prepare("SELECT id, name, email, created_at FROM users WHERE api_token = ?");
    $stmt->execute([$token]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'Invalid session token']);
        exit();
    }

    echo json_encode([
        'success' => true,
        'user' => $user
    ]);
    exit();
}

// GET /api/expenses
if ($uri === '/api/expenses' && $method === 'GET') {
    $stmt = $pdo->query("SELECT id, name, description, amount, type, date FROM expenses ORDER BY id DESC");
    $expenses = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'data' => $expenses
    ]);
    exit();
}

// POST /api/expenses
if ($uri === '/api/expenses' && $method === 'POST') {
    $name = trim($input['name'] ?? '');
    $description = trim($input['description'] ?? '');
    $amount = floatval($input['amount'] ?? 0);
    $type = trim($input['type'] ?? 'Expense');
    $date = $input['date'] ?? date('Y-m-d H:i:s');

    if (empty($name) || $amount <= 0) {
        http_response_code(422);
        echo json_encode([
            'success' => false,
            'message' => 'Name and valid positive amount are required.'
        ]);
        exit();
    }

    $stmt = $pdo->prepare("INSERT INTO expenses (name, description, amount, type, date) VALUES (?, ?, ?, ?, ?)");
    $stmt->execute([$name, $description, $amount, $type, $date]);
    $id = $pdo->lastInsertId();

    http_response_code(201);
    echo json_encode([
        'success' => true,
        'message' => 'Transaction saved successfully to database!',
        'data' => [
            'id' => (string)$id,
            'name' => $name,
            'description' => $description,
            'amount' => $amount,
            'type' => $type,
            'date' => $date
        ]
    ]);
    exit();
}

// POST /api/expenses/delete or DELETE /api/expenses
if (($uri === '/api/expenses/delete' || strpos($uri, '/api/expenses/') === 0) && ($method === 'POST' || $method === 'DELETE')) {
    $id = $input['id'] ?? basename($uri);
    if (!empty($id) && is_numeric($id)) {
        $stmt = $pdo->prepare("DELETE FROM expenses WHERE id = ?");
        $stmt->execute([$id]);
    }
    echo json_encode([
        'success' => true,
        'message' => 'Transaction deleted successfully!'
    ]);
    exit();
}

// Fallback Route
http_response_code(404);
echo json_encode([
    'success' => false,

    'message' => 'API endpoint not found: ' . $uri
]);
