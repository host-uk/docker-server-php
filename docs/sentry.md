# Sentry Integration

Docker Server PHP includes optional integration with [Sentry](https://sentry.io) for error monitoring and performance tracing.

## Overview

When enabled, Sentry automatically captures:

- PHP errors and exceptions
- Performance traces
- Request context and breadcrumbs
- Release and environment information

## Setup

### 1. Install Sentry SDK

Add the Sentry PHP SDK to your application:

```bash
composer require sentry/sentry
```

### 2. Get Your DSN

Obtain your DSN from Sentry:

- **Sentry.io**: Project Settings → Client Keys (DSN)
- **Self-hosted**: Your Sentry instance URL + project key

### 3. Configure Environment

```bash
# Enable Sentry
SENTRY_ENABLED=true

# Your Sentry DSN
SENTRY_DSN=https://key@sentry.example.com/project-id

# Environment name
SENTRY_ENVIRONMENT=production

# Trace sample rate (0.0 to 1.0)
SENTRY_TRACE_SAMPLE_RATE=0.1

# Application version
APP_VERSION=1.0.0

# Optional: Server hostname
APP_HOSTNAME=api.example.com
```

### 4. Restart Container

The configuration is applied at container startup:

```bash
docker compose restart
```

## Configuration Options

| Variable | Default | Description |
|----------|---------|-------------|
| `SENTRY_ENABLED` | `false` | Enable/disable Sentry |
| `SENTRY_DSN` | - | Sentry DSN (required) |
| `SENTRY_ENVIRONMENT` | `production` | Environment name |
| `SENTRY_TRACE_SAMPLE_RATE` | `0.1` | Performance sampling (0.0-1.0) |
| `APP_VERSION` | `1.0.0` | Release version |
| `APP_HOSTNAME` | hostname | Server identifier |

## How It Works

When `SENTRY_ENABLED=true`:

1. The entrypoint script creates a PHP configuration that auto-prepends `sentry-init.php`
2. Every PHP request automatically initializes Sentry
3. Errors and exceptions are captured and sent to Sentry
4. Performance traces are sampled based on `SENTRY_TRACE_SAMPLE_RATE`

## Initialization Script

The `sentry-init.php` script handles:

```php
// Automatic SDK initialization
\Sentry\init([
    'dsn' => getenv('SENTRY_DSN'),
    'environment' => getenv('SENTRY_ENVIRONMENT'),
    'release' => getenv('APP_VERSION'),
    'traces_sample_rate' => (float)getenv('SENTRY_TRACE_SAMPLE_RATE'),
]);

// PHP version and hostname tags
\Sentry\configureScope(function ($scope) {
    $scope->setTag('php_version', PHP_VERSION);
    $scope->setTag('hostname', getenv('APP_HOSTNAME'));
});
```

## Performance Monitoring

### Sample Rate

The `SENTRY_TRACE_SAMPLE_RATE` controls what percentage of requests are traced:

- `1.0` = 100% of requests (development)
- `0.1` = 10% of requests (production recommended)
- `0.01` = 1% of requests (high-traffic production)

### Custom Transactions

Create custom performance spans in your code:

```php
$span = \Sentry\startSpan([
    'op' => 'db.query',
    'description' => 'SELECT * FROM users',
]);

// Your code here

$span->finish();
```

## Filtering Events

### Health Check Exclusion

The initialization script automatically filters out health check errors:

```php
'before_send' => function ($event) {
    $request = $event->getRequest();
    if (str_contains($request['url'] ?? '', '/health')) {
        return null; // Don't send
    }
    return $event;
}
```

### Custom Filtering

Extend filtering in your application:

```php
\Sentry\init([
    'before_send' => function ($event, $hint) {
        // Filter specific exceptions
        if ($hint->exception instanceof NotFoundException) {
            return null;
        }
        return $event;
    },
]);
```

## Self-Hosted Sentry

For self-hosted Sentry installations:

1. Deploy Sentry using their [self-hosted guide](https://develop.sentry.dev/self-hosted/)
2. Create a project and get the DSN
3. Use your internal Sentry URL in `SENTRY_DSN`

Example:
```bash
SENTRY_DSN=https://abc123@sentry.internal.example.com/1
```

## Troubleshooting

### Sentry Not Capturing Events

1. Verify `SENTRY_ENABLED=true`
2. Check `SENTRY_DSN` is correct
3. Ensure Sentry SDK is installed: `composer show sentry/sentry`
4. Check container logs: `docker compose logs app`

### Container Startup Messages

When Sentry is configured, you'll see:

```
Configuring Sentry...
  - Sentry enabled with auto_prepend_file
  - Environment: production
  - Trace sample rate: 0.1
```

### Testing Integration

Trigger a test error:

```php
throw new \Exception('Test Sentry integration');
```

Or use Sentry's test function:

```php
\Sentry\captureMessage('Test message from Docker Server PHP');
```
