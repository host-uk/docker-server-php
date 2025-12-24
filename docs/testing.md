# Testing

Docker Server PHP includes built-in testing for build targets and supports comprehensive application testing.

## Build Target Tests

### Running Tests

```bash
# Test all build targets
make test-targets

# Test individual targets
make test-runtime
make test-dev
make test-prod
```

### What's Tested

#### Runtime Target (17 tests)

- PHP installation and version
- Nginx installation
- Supervisor installation
- PHP-FPM availability
- Core PHP extensions (OPcache, Redis, PDO, GD, Intl, Mbstring)
- Brotli module
- Configuration files
- Container startup

#### Development Target (29 tests)

All runtime tests, plus:

- APP_ENV=development
- Xdebug installation and configuration
- Composer availability
- PHPUnit, PHPStan, PHP_CodeSniffer, PHP-CS-Fixer
- Git, Bash, Make tools

#### Production Target (28 tests)

All runtime tests, plus:

- APP_ENV=production
- OPcache + JIT configuration
- Nginx performance config
- Security hardening (Xdebug absent, Composer absent)
- Disabled dangerous functions
- Production PHP settings

### Test Script

The test script is located at `scripts/test-target.sh`:

```bash
# Usage
./scripts/test-target.sh <target> <image>

# Example
./scripts/test-target.sh production ghcr.io/host-uk/docker-server-php:prod-8.4
```

## Application Testing

### PHPUnit

The development image includes PHPUnit 11:

```bash
# Run tests inside container
docker compose exec app phpunit

# Or from host
docker compose exec app phpunit tests/
```

#### phpunit.xml Example

```xml
<?xml version="1.0" encoding="UTF-8"?>
<phpunit bootstrap="vendor/autoload.php"
         colors="true"
         stopOnFailure="false">
    <testsuites>
        <testsuite name="Unit">
            <directory>tests/Unit</directory>
        </testsuite>
        <testsuite name="Feature">
            <directory>tests/Feature</directory>
        </testsuite>
    </testsuites>
    <coverage>
        <include>
            <directory suffix=".php">src</directory>
        </include>
    </coverage>
</phpunit>
```

### Code Coverage

Generate HTML coverage report:

```bash
# Using Xdebug
XDEBUG_MODE=coverage docker compose exec app phpunit --coverage-html coverage/

# Using PCOV (faster)
docker compose exec app php -d pcov.enabled=1 vendor/bin/phpunit --coverage-html coverage/
```

### Static Analysis

#### PHPStan

```bash
# Basic analysis
docker compose exec app phpstan analyse src

# With configuration
docker compose exec app phpstan analyse -c phpstan.neon

# Higher level
docker compose exec app phpstan analyse src --level=8
```

#### phpstan.neon Example

```yaml
parameters:
    level: 6
    paths:
        - src
    excludePaths:
        - vendor
```

### Code Style

#### PHP_CodeSniffer

```bash
# Check style
docker compose exec app phpcs src/

# Fix automatically
docker compose exec app phpcbf src/
```

#### PHP-CS-Fixer

```bash
# Fix code style
docker compose exec app php-cs-fixer fix src/

# Dry run
docker compose exec app php-cs-fixer fix src/ --dry-run --diff
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Build test image
        run: make build-dev

      - name: Run target tests
        run: make test-dev

      - name: Run application tests
        run: |
          docker compose -f docker-compose.dev.yml up -d
          docker compose exec -T app composer install
          docker compose exec -T app phpunit
          docker compose exec -T app phpstan analyse src
```

### GitLab CI

```yaml
test:
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build --target development -t app:test .
    - docker run --rm app:test phpunit
    - docker run --rm app:test phpstan analyse src
```

## Testing Best Practices

### Use Development Target

Always use the development target for testing:

```bash
docker build --target development -t app:test .
```

### Isolated Test Environment

```yaml
# docker-compose.test.yml
services:
  app:
    build:
      target: development
    environment:
      APP_ENV: testing
      DB_DATABASE: test_db
    depends_on:
      - test-db

  test-db:
    image: mariadb:11.4
    environment:
      MYSQL_DATABASE: test_db
      MYSQL_ROOT_PASSWORD: test
    tmpfs:
      - /var/lib/mysql
```

### Parallel Testing

PHPUnit supports parallel execution:

```bash
docker compose exec app phpunit --parallel
```

### Database Testing

Reset database between tests:

```php
// tests/TestCase.php
protected function setUp(): void
{
    parent::setUp();
    $this->refreshDatabase();
}
```

## Debugging Tests

### Xdebug in Tests

```bash
XDEBUG_MODE=debug docker compose exec app phpunit tests/Unit/FailingTest.php
```

### Verbose Output

```bash
docker compose exec app phpunit -v --debug
```

### Stop on Failure

```bash
docker compose exec app phpunit --stop-on-failure
```
