# Development Tools

The development build target includes a full suite of tools for PHP development.

## Included Tools

| Tool | Command | Description |
|------|---------|-------------|
| Xdebug 3 | (auto-loaded) | Debugging, profiling, coverage |
| PHPUnit 11 | `phpunit` | Testing framework |
| PHPStan 2 | `phpstan` | Static analysis |
| PHP_CodeSniffer | `phpcs`, `phpcbf` | Code style checking/fixing |
| PHP-CS-Fixer | `php-cs-fixer` | Code style fixer |
| Composer | `composer` | Dependency management |
| Git | `git` | Version control |
| Make | `make` | Build automation |

## Starting Development Environment

```bash
# Using Docker Compose (recommended)
docker compose -f docker-compose.dev.yml up

# Access the container shell
make shell

# Or manually
docker exec -it <container> bash
```

## Xdebug Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `XDEBUG_MODE` | `develop,debug,coverage` | Enabled modes |
| `XDEBUG_CLIENT_HOST` | `host.docker.internal` | IDE host |
| `XDEBUG_CLIENT_PORT` | `9003` | IDE port |
| `XDEBUG_START_WITH_REQUEST` | `trigger` | Activation method |
| `XDEBUG_IDEKEY` | `PHPSTORM` | IDE key |

### Xdebug Modes

- **develop**: Enhanced var_dump, stack traces
- **debug**: Step debugging (IDE integration)
- **coverage**: Code coverage for PHPUnit
- **profile**: Profiling (cachegrind output)
- **trace**: Function trace logging

Combine modes with commas:
```bash
XDEBUG_MODE=develop,debug,coverage
```

### VS Code Setup

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Listen for Xdebug",
      "type": "php",
      "request": "launch",
      "port": 9003,
      "pathMappings": {
        "/var/www/html": "${workspaceFolder}/product"
      }
    }
  ]
}
```

### PhpStorm Setup

1. Go to **Settings > PHP > Debug**
2. Set Xdebug port to `9003`
3. Go to **Settings > PHP > Servers**
4. Add server with path mapping:
   - `/var/www/html` → `product/`

### Triggering Debug Sessions

With `XDEBUG_START_WITH_REQUEST=trigger`:

- **Browser extension**: Install [Xdebug Helper](https://chrome.google.com/webstore/detail/xdebug-helper)
- **Query parameter**: `?XDEBUG_TRIGGER=1`
- **Cookie**: `XDEBUG_TRIGGER=1`
- **Environment**: `XDEBUG_TRIGGER=1`

### Always-On Debugging

```bash
XDEBUG_START_WITH_REQUEST=yes
```

## Running Tests

### PHPUnit

```bash
# Run all tests
phpunit

# Run specific test file
phpunit tests/Unit/ExampleTest.php

# Run with coverage
phpunit --coverage-html coverage/
```

### PHPStan

```bash
# Analyze src directory
phpstan analyse src

# With specific level (0-9)
phpstan analyse src --level=8

# Use configuration file
phpstan analyse -c phpstan.neon
```

### PHP_CodeSniffer

```bash
# Check code style
phpcs src/

# Fix automatically
phpcbf src/

# Use specific standard
phpcs --standard=PSR12 src/
```

### PHP-CS-Fixer

```bash
# Fix code style
php-cs-fixer fix src/

# Dry run (show changes)
php-cs-fixer fix src/ --dry-run --diff
```

## Profiling with Xdebug

Enable profiling:

```bash
XDEBUG_MODE=profile
```

Profiles are saved to `/tmp/cachegrind.out.*`. Analyze with:

- [KCacheGrind](https://kcachegrind.github.io/) (Linux)
- [QCacheGrind](https://formulae.brew.sh/formula/qcachegrind) (macOS)
- [Webgrind](https://github.com/jokkedk/webgrind) (Web-based)

## Code Coverage

Generate HTML coverage report:

```bash
XDEBUG_MODE=coverage phpunit --coverage-html coverage/
```

Or use PCOV for faster coverage:

```bash
php -d pcov.enabled=1 vendor/bin/phpunit --coverage-html coverage/
```

## Composer Usage

```bash
# Install dependencies
composer install

# Add package
composer require package/name

# Update dependencies
composer update

# Dump autoloader
composer dump-autoload -o
```
