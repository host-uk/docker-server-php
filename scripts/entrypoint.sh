#!/bin/sh
set -e

echo "Generating configuration from templates..."

# Determine PHP_INI_DIR based on PHP_VERSION
PHP_INI_DIR="/etc/php${PHP_VERSION:-84}"

# Substitute environment variables in templates
if [ -f "${PHP_INI_DIR}/conf.d/custom.ini.template" ]; then
    envsubst < "${PHP_INI_DIR}/conf.d/custom.ini.template" > "${PHP_INI_DIR}/conf.d/custom.ini"
    echo "Generated ${PHP_INI_DIR}/conf.d/custom.ini"
fi

if [ -f "${PHP_INI_DIR}/php-fpm.d/www.conf.template" ]; then
    envsubst < "${PHP_INI_DIR}/php-fpm.d/www.conf.template" > "${PHP_INI_DIR}/php-fpm.d/www.conf"
    echo "Generated ${PHP_INI_DIR}/php-fpm.d/www.conf"
fi

# Optional: Sentry initialization
if [ "$SENTRY_ENABLED" = "true" ] && [ -n "$SENTRY_DSN" ]; then
    echo "Configuring Sentry..."
    cat > "${PHP_INI_DIR}/conf.d/sentry.ini" <<EOF
; Sentry Configuration
; Note: Install sentry/sentry package via Composer first
; auto_prepend_file = /var/www/html/config/sentry-init.php
EOF
    echo "Sentry configuration prepared (requires sentry/sentry package)"
fi

echo "Configuration complete. Starting services..."
echo "PHP Version: $(php -v | head -n 1)"
echo "PHP INI Dir: ${PHP_INI_DIR}"

exec "$@"