#!/bin/sh
set -e

echo "============================================================"
echo "Docker Server PHP - Starting..."
echo "============================================================"

# Determine PHP_INI_DIR based on PHP_VERSION
PHP_INI_DIR="/etc/php${PHP_VERSION:-84}"
APP_ENV="${APP_ENV:-production}"

echo "Environment: ${APP_ENV}"
echo "PHP Version: ${PHP_VERSION:-84}"

# Generate configuration from templates
echo "Generating configuration from templates..."

if [ -f "${PHP_INI_DIR}/conf.d/custom.ini.template" ]; then
    envsubst < "${PHP_INI_DIR}/conf.d/custom.ini.template" > "${PHP_INI_DIR}/conf.d/custom.ini"
    echo "  - Generated ${PHP_INI_DIR}/conf.d/custom.ini"
fi

if [ -f "${PHP_INI_DIR}/php-fpm.d/www.conf.template" ]; then
    envsubst < "${PHP_INI_DIR}/php-fpm.d/www.conf.template" > "${PHP_INI_DIR}/php-fpm.d/www.conf"
    echo "  - Generated ${PHP_INI_DIR}/php-fpm.d/www.conf"
fi

# Development mode specific configurations
if [ "$APP_ENV" = "development" ]; then
    echo "Development mode enabled:"

    # Xdebug configuration
    if [ -f "${PHP_INI_DIR}/conf.d/50_xdebug.ini" ]; then
        echo "  - Xdebug: ${XDEBUG_MODE:-develop,debug,coverage}"
        echo "  - Xdebug client: ${XDEBUG_CLIENT_HOST:-host.docker.internal}:${XDEBUG_CLIENT_PORT:-9003}"
    fi

    # Create opcache file cache directory
    mkdir -p /tmp/opcache 2>/dev/null || true
fi

# Production mode specific configurations
if [ "$APP_ENV" = "production" ]; then
    echo "Production mode enabled:"

    # Create opcache file cache directory
    mkdir -p /tmp/opcache 2>/dev/null || true

    # Validate critical settings
    if [ "${PHP_OPCACHE_VALIDATE_TIMESTAMPS:-0}" = "1" ]; then
        echo "  - Warning: opcache.validate_timestamps is enabled (reduces performance)"
    fi

    echo "  - OPcache: enabled with JIT"
    echo "  - Brotli compression: enabled"
fi

# Optional: Sentry initialization
if [ "$SENTRY_ENABLED" = "true" ] && [ -n "$SENTRY_DSN" ]; then
    echo "Configuring Sentry..."
    if [ -f "/var/www/html/sentry-init.php" ]; then
        cat > "${PHP_INI_DIR}/conf.d/99_sentry.ini" <<EOF
; Sentry Configuration
; Auto-prepend Sentry initialization to all PHP requests
auto_prepend_file = /var/www/html/sentry-init.php
EOF
        echo "  - Sentry enabled with auto_prepend_file"
        echo "  - Environment: ${SENTRY_ENVIRONMENT:-production}"
        echo "  - Trace sample rate: ${SENTRY_TRACE_SAMPLE_RATE:-0.1}"
    else
        echo "  - Warning: Sentry enabled but /var/www/html/sentry-init.php not found"
    fi
fi

echo "============================================================"
echo "Configuration complete. Starting services..."
echo "PHP: $(php -v | head -n 1)"
echo "============================================================"

exec "$@"