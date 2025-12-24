#!/bin/bash
# ============================================================
# Build Target Test Script
# Tests that each Docker build target has expected features
# ============================================================

set -e

TARGET="$1"
IMAGE="$2"

if [ -z "$TARGET" ] || [ -z "$IMAGE" ]; then
    echo "Usage: $0 <target> <image>"
    echo "  target: runtime, development, production"
    echo "  image: docker image name:tag"
    exit 1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0

# Test helper functions
pass() {
    echo -e "  ${GREEN}✓${NC} $1"
    PASSED=$((PASSED + 1))
}

fail() {
    echo -e "  ${RED}✗${NC} $1"
    FAILED=$((FAILED + 1))
}

warn() {
    echo -e "  ${YELLOW}!${NC} $1"
}

# Run command bypassing entrypoint for direct testing (as root for file access)
docker_run() {
    docker run --rm --entrypoint "" --user root "$IMAGE" sh -c "$1"
}

test_command() {
    local desc="$1"
    local cmd="$2"

    if docker_run "$cmd" > /dev/null 2>&1; then
        pass "$desc"
        return 0
    else
        fail "$desc"
        return 1
    fi
}

test_command_output() {
    local desc="$1"
    local cmd="$2"
    local expected="$3"

    local output
    output=$(docker_run "$cmd" 2>&1) || true

    if echo "$output" | grep -q "$expected"; then
        pass "$desc"
        return 0
    else
        fail "$desc (expected: $expected)"
        return 1
    fi
}

test_command_absent() {
    local desc="$1"
    local cmd="$2"

    if docker_run "$cmd" > /dev/null 2>&1; then
        fail "$desc (should not exist)"
        return 1
    else
        pass "$desc"
        return 0
    fi
}

test_file_exists() {
    local desc="$1"
    local path="$2"

    if docker_run "test -f $path" > /dev/null 2>&1; then
        pass "$desc"
        return 0
    else
        fail "$desc"
        return 1
    fi
}

test_file_contains() {
    local desc="$1"
    local path="$2"
    local content="$3"

    if docker_run "grep -q '$content' '$path'" > /dev/null 2>&1; then
        pass "$desc"
        return 0
    else
        fail "$desc"
        return 1
    fi
}

echo ""
echo "Testing image: $IMAGE"
echo "Target: $TARGET"
echo ""

# ============================================================
# Common tests for all targets
# ============================================================
echo "Common checks:"
test_command "PHP is installed" "php -v"
test_command "Nginx is installed" "nginx -v"
test_command "Supervisor is installed" "supervisord --version"
test_command "PHP-FPM is available" "ls /usr/sbin/php-fpm*"
test_command "Curl is installed" "curl --version"
test_file_exists "Entrypoint script exists" "/usr/local/bin/entrypoint.sh"
test_file_exists "Supervisor config exists" "/etc/supervisor/conf.d/supervisord.conf"
test_file_exists "Nginx config exists" "/etc/nginx/nginx.conf"

# Check PHP extensions
echo ""
echo "PHP Extensions:"
test_command_output "OPcache extension" "php -m" "OPcache"
test_command_output "Redis extension" "php -m" "redis"
test_command_output "PDO MySQL extension" "php -m" "pdo_mysql"
test_command_output "GD extension" "php -m" "gd"
test_command_output "Intl extension" "php -m" "intl"
test_command_output "Mbstring extension" "php -m" "mbstring"

# Check Nginx modules
echo ""
echo "Nginx Modules:"
test_command_output "Brotli module loaded" "cat /etc/nginx/nginx.conf" "brotli"

# ============================================================
# Target-specific tests
# ============================================================

case "$TARGET" in
    runtime)
        echo ""
        echo "Runtime-specific checks:"
        test_command_output "APP_ENV is production" "printenv APP_ENV" "production"
        ;;

    development)
        echo ""
        echo "Development-specific checks:"
        test_command_output "APP_ENV is development" "printenv APP_ENV" "development"

        echo ""
        echo "Development Tools:"
        test_command "Xdebug extension loaded" "php -m | grep -i xdebug"
        test_command "Composer is installed" "composer --version"
        test_command "PHPUnit is installed" "phpunit --version"
        test_command "PHPStan is installed" "phpstan --version"
        test_command "PHP_CodeSniffer is installed" "phpcs --version"
        test_command "PHP-CS-Fixer is installed" "php-cs-fixer --version"
        test_command "Git is installed" "git --version"
        test_command "Bash is installed" "bash --version"
        test_command "Make is installed" "make --version"

        echo ""
        echo "Xdebug Configuration:"
        test_command "Xdebug config exists" "ls /etc/php*/conf.d/50_xdebug.ini"
        test_command_output "XDEBUG_MODE is set" "printenv XDEBUG_MODE" "develop"

        echo ""
        echo "Development PHP Config:"
        test_command "Dev PHP config exists" "ls /etc/php*/conf.d/60_development.ini"
        ;;

    production)
        echo ""
        echo "Production-specific checks:"
        test_command_output "APP_ENV is production" "printenv APP_ENV" "production"

        echo ""
        echo "Production Optimizations:"
        test_command "OPcache prod config exists" "ls /etc/php*/conf.d/10_opcache_prod.ini"
        test_command "Production PHP config exists" "ls /etc/php*/conf.d/60_production.ini"
        test_file_exists "Nginx performance config exists" "/etc/nginx/conf.d/performance.conf"

        echo ""
        echo "Security Hardening:"
        # Xdebug should NOT be installed in production
        test_command_absent "Xdebug NOT installed" "php -m | grep -i xdebug"
        # Composer should NOT be in production
        test_command_absent "Composer NOT installed" "composer --version"

        echo ""
        echo "Dangerous Functions Disabled:"
        test_command_output "exec disabled" "cat /etc/php*/conf.d/60_production.ini" "disable_functions"
        test_command_output "shell_exec disabled" "cat /etc/php*/conf.d/60_production.ini" "shell_exec"
        test_command_output "system disabled" "cat /etc/php*/conf.d/60_production.ini" "system"

        echo ""
        echo "Production PHP Settings:"
        test_command_output "display_errors Off" "cat /etc/php*/conf.d/60_production.ini" "display_errors = Off"
        test_command_output "expose_php Off" "cat /etc/php*/conf.d/60_production.ini" "expose_php = Off"

        echo ""
        echo "OPcache JIT Configuration:"
        test_command_output "JIT enabled" "cat /etc/php*/conf.d/10_opcache_prod.ini" "opcache.jit"
        ;;

    *)
        echo "Unknown target: $TARGET"
        exit 1
        ;;
esac

# ============================================================
# Container startup test
# ============================================================
echo ""
echo "Container Startup Test:"

CONTAINER_ID=$(docker run -d --rm "$IMAGE" sleep 30)

# Give it a moment to start
sleep 2

# Check if container is still running
if docker ps -q --filter "id=$CONTAINER_ID" | grep -q .; then
    pass "Container starts successfully"
else
    fail "Container failed to start"
fi

# Cleanup
docker stop "$CONTAINER_ID" > /dev/null 2>&1 || true

# ============================================================
# Summary
# ============================================================
echo ""
echo "============================================================"
echo "Test Summary for $TARGET target:"
echo "============================================================"
echo -e "  ${GREEN}Passed:${NC} $PASSED"
echo -e "  ${RED}Failed:${NC} $FAILED"
echo ""

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi
