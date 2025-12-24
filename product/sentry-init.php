<?php
/**
 * Sentry SDK Initialization
 *
 * This file is auto-prepended to all PHP requests when SENTRY_ENABLED=true.
 * Requires: composer require sentry/sentry
 */

// Only initialize if Sentry is enabled and SDK is installed
if (getenv('SENTRY_ENABLED') !== 'true') {
    return;
}

// Check if Sentry SDK is installed
if (!file_exists(__DIR__ . '/vendor/autoload.php')) {
    return;
}

require_once __DIR__ . '/vendor/autoload.php';

if (!class_exists('\Sentry\SentrySdk')) {
    // Sentry SDK not installed
    error_log('Sentry enabled but sentry/sentry package not installed. Run: composer require sentry/sentry');
    return;
}

$dsn = getenv('SENTRY_DSN');
if (empty($dsn)) {
    error_log('Sentry enabled but SENTRY_DSN not set');
    return;
}

// Initialize Sentry
\Sentry\init([
    'dsn' => $dsn,
    'environment' => getenv('SENTRY_ENVIRONMENT') ?: 'production',
    'release' => getenv('APP_VERSION') ?: '1.0.0',
    'server_name' => getenv('APP_HOSTNAME') ?: gethostname(),

    // Performance monitoring
    'traces_sample_rate' => (float)(getenv('SENTRY_TRACE_SAMPLE_RATE') ?: 0.1),

    // Additional options
    'send_default_pii' => false,
    'max_breadcrumbs' => 50,

    // Before send callback for filtering
    'before_send' => function (\Sentry\Event $event, ?\Sentry\EventHint $hint): ?\Sentry\Event {
        // Filter out health check errors
        $request = $event->getRequest();
        if ($request && isset($request['url']) && str_contains($request['url'], '/health')) {
            return null;
        }
        return $event;
    },
]);

// Set user context if available
if ($userId = getenv('SENTRY_USER_ID')) {
    \Sentry\configureScope(function (\Sentry\State\Scope $scope) use ($userId): void {
        $scope->setUser(['id' => $userId]);
    });
}

// Set additional tags
\Sentry\configureScope(function (\Sentry\State\Scope $scope): void {
    $scope->setTag('php_version', PHP_VERSION);
    $scope->setTag('php_sapi', PHP_SAPI);

    if ($hostname = getenv('APP_HOSTNAME')) {
        $scope->setTag('hostname', $hostname);
    }
});
