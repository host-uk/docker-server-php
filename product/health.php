<?php
/**
 * Health Check Endpoint
 * Returns 200 OK if all dependencies are healthy
 */

header('Content-Type: application/json');

$health = [
    'status' => 'healthy',
    'timestamp' => time(),
    'checks' => [],
    'info' => [
        'php_version' => PHP_VERSION,
        'hostname' => gethostname(),
    ]
];

$allHealthy = true;

// Database check (if DB credentials are provided)
if (getenv('DB_HOST') || getenv('MYSQL_HOST')) {
    try {
        $db = getenv('DB_HOST') ?: getenv('MYSQL_HOST') ?: 'localhost';
        $user = getenv('DB_USER') ?: getenv('MYSQL_USER') ?: 'root';
        $pass = getenv('DB_PASSWORD') ?: getenv('MYSQL_PASSWORD') ?: '';
        $name = getenv('DB_NAME') ?: getenv('MYSQL_DATABASE') ?: 'test';

        $pdo = new PDO("mysql:host=$db;dbname=$name", $user, $pass, [
            PDO::ATTR_TIMEOUT => 2,
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
        ]);

        $pdo->query("SELECT 1");

        $health['checks']['database'] = 'healthy';
    } catch (Exception $e) {
        $health['checks']['database'] = 'unhealthy: ' . $e->getMessage();
        $allHealthy = false;
    }
}

// Redis check (if enabled and configured)
if (extension_loaded('redis') && getenv('REDIS_HOST')) {
    try {
        $redis = new Redis();
        $redis->connect(
            getenv('REDIS_HOST'),
            (int)(getenv('REDIS_PORT') ?: 6379),
            2  // timeout
        );
        $redis->ping();

        $health['checks']['redis'] = 'healthy';
    } catch (Exception $e) {
        $health['checks']['redis'] = 'unhealthy: ' . $e->getMessage();
        $allHealthy = false;
    }
}

// Filesystem check
try {
    $testFile = sys_get_temp_dir() . '/health_check_' . time();
    file_put_contents($testFile, 'test');
    $content = file_get_contents($testFile);
    unlink($testFile);

    if ($content !== 'test') {
        throw new Exception('Filesystem read/write mismatch');
    }

    $health['checks']['filesystem'] = 'healthy';
} catch (Exception $e) {
    $health['checks']['filesystem'] = 'unhealthy: ' . $e->getMessage();
    $allHealthy = false;
}

// OPcache check (if enabled)
if (function_exists('opcache_get_status')) {
    $opcache = opcache_get_status(false);
    if ($opcache && $opcache['opcache_enabled']) {
        $health['checks']['opcache'] = 'healthy';
        $health['info']['opcache_memory_usage'] = round($opcache['memory_usage']['used_memory'] / 1024 / 1024, 2) . 'MB';
    } else {
        $health['checks']['opcache'] = 'disabled';
    }
}

// Set response code
$health['status'] = $allHealthy ? 'healthy' : 'unhealthy';
http_response_code($allHealthy ? 200 : 503);

// Return JSON
echo json_encode($health, JSON_PRETTY_PRINT);
