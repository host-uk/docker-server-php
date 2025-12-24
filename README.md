# Docker Server PHP

Production-ready Docker base image for PHP applications using Alpine Linux, Nginx, and PHP-FPM.

[![Build and Publish](https://github.com/host-uk/docker-server-php/actions/workflows/build-and-publish.yml/badge.svg)](https://github.com/host-uk/docker-server-php/actions/workflows/build-and-publish.yml)
[![Documentation](https://github.com/host-uk/docker-server-php/actions/workflows/docs.yml/badge.svg)](https://host-uk.github.io/docker-server-php)

**[Documentation](https://host-uk.github.io/docker-server-php)** | [Getting Started](https://host-uk.github.io/docker-server-php/getting-started/) | [Configuration](https://host-uk.github.io/docker-server-php/configuration/)

## Features

### Core Stack
- **OS**: Alpine Linux (3.19-3.23)
- **Web Server**: Nginx with security hardening
- **PHP**: Multiple versions supported (8.2, 8.3, 8.4, 8.5)
- **Process Manager**: Supervisor
- **Architecture**: Multi-architecture support (amd64, arm64)

### Production-Ready
- ✅ **Multi-stage builds** - Optimized image size (~30-40% smaller)
- ✅ **Security hardening** - CSP, X-Frame-Options, disabled dangerous functions
- ✅ **12-Factor app** - Environment-based configuration
- ✅ **Health checks** - Database, Redis, filesystem monitoring
- ✅ **Non-root user** - Runs as `nobody` for security
- ✅ **Structured logging** - JSON logs with performance metrics
- ✅ **OPcache with JIT** - Production-optimized PHP acceleration
- ✅ **Brotli compression** - ~20% smaller than gzip
- ✅ **Sentry integration** - Optional error monitoring

### Developer Experience
- 🔧 **Xdebug** - Step debugging, profiling, coverage
- 🔧 **PHPUnit, PHPStan, PHP_CodeSniffer** - Pre-installed in dev image
- 🔧 Flexible `product/` and `patch/` directory structure
- 🔧 Hot-reload friendly for local development
- 🔧 Comprehensive Makefile for common tasks
- 🔧 Docker Compose support with MariaDB and Redis

## Quick Start

### Using Pre-built Images

```bash
# Pull the latest image (PHP 8.5)
docker pull ghcr.io/host-uk/docker-server-php:latest

# Or specify a version
docker pull ghcr.io/host-uk/docker-server-php:8.5
docker pull ghcr.io/host-uk/docker-server-php:8.4
docker pull ghcr.io/host-uk/docker-server-php:8.3
docker pull ghcr.io/host-uk/docker-server-php:8.2
```

### Using as Base Image

```dockerfile
FROM ghcr.io/host-uk/docker-server-php:8.5

# Copy your application
COPY --chown=nobody:nobody . /var/www/html

# Environment variables will be injected at runtime
ENV PHP_MEMORY_LIMIT=512M
ENV PHP_UPLOAD_MAX_FILESIZE=100M
```

### Local Development

1. **Clone the template**:
   ```bash
   git clone https://github.com/host-uk/docker-server-php.git
   cd docker-server-php
   ```

2. **Add your code**:
   - Place your PHP application in `product/`
   - Optional overrides in `patch/`

3. **Configure environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your settings
   ```

4. **Start development environment**:
   ```bash
   make up
   ```

   Your app will be available at `http://localhost:8080`

## Directory Structure

```
.
├── product/              # Your PHP application code
├── patch/                # Optional file overrides
├── config/               # Nginx, PHP, and Supervisor configs
│   ├── nginx.conf
│   ├── conf.d/
│   ├── php.ini.template
│   └── fpm-pool.conf.template
├── scripts/              # Utility scripts
│   ├── entrypoint.sh
│   └── build-all-versions.sh
├── database/             # SQL initialization scripts
│   ├── schema.sql
│   └── user.sql
└── .github/workflows/    # CI/CD workflows
```

## Build Targets

The Dockerfile provides multiple build targets for different use cases:

| Target | Use Case | Features |
|--------|----------|----------|
| `runtime` | Base image | PHP, Nginx, Supervisor |
| `development` | Local development | Xdebug, PHPUnit, PHPStan, Composer |
| `production` | Production deployment | Hardened, OPcache+JIT, Brotli, security |

### Building for Development

```bash
# Using docker-compose (recommended)
docker compose -f docker-compose.dev.yml up

# Or manually
docker build --target development -t myapp:dev .
```

### Building for Production

```bash
# Using docker-compose
docker compose up

# Or manually
docker build --target production -t myapp:prod .
```

## Available PHP Versions

| PHP Version | Alpine Version | Tag |
|-------------|----------------|-----|
| 8.5 | 3.23 | `latest`, `8.5`, `8.5-alpine3.23` |
| 8.4 | 3.22 | `8.4`, `8.4-alpine3.22` |
| 8.4 | 3.21 | `8.4-alpine3.21` |
| 8.3 | 3.20 | `8.3`, `8.3-alpine3.20` |
| 8.2 | 3.19 | `8.2`, `8.2-alpine3.19` |

## Configuration

All configuration is managed via environment variables following the [12-Factor App](https://12factor.net/) methodology.

### PHP Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `PHP_TIMEZONE` | `UTC` | PHP timezone |
| `PHP_MEMORY_LIMIT` | `256M` | Memory limit |
| `PHP_UPLOAD_MAX_FILESIZE` | `64M` | Max upload size |
| `PHP_POST_MAX_SIZE` | `64M` | Max POST size |
| `PHP_MAX_EXECUTION_TIME` | `300` | Max execution time (seconds) |
| `PHP_MAX_INPUT_VARS` | `1000` | Max input variables |
| `PHP_OPCACHE_ENABLE` | `1` | Enable OPcache |
| `PHP_OPCACHE_MEMORY` | `128` | OPcache memory (MB) |

### PHP-FPM Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `PHP_FPM_PM` | `ondemand` | Process manager type |
| `PHP_FPM_MAX_CHILDREN` | `100` | Max child processes |
| `PHP_FPM_START_SERVERS` | `5` | Start servers (dynamic only) |
| `PHP_FPM_MIN_SPARE_SERVERS` | `5` | Min spare (dynamic only) |
| `PHP_FPM_MAX_SPARE_SERVERS` | `10` | Max spare (dynamic only) |
| `PHP_FPM_PROCESS_IDLE_TIMEOUT` | `10s` | Idle timeout (ondemand) |
| `PHP_FPM_MAX_REQUESTS` | `1000` | Max requests per child |

### Database Configuration (Optional)

| Variable | Description |
|----------|-------------|
| `DB_HOST` or `MYSQL_HOST` | Database host |
| `DB_USER` or `MYSQL_USER` | Database user |
| `DB_PASSWORD` or `MYSQL_PASSWORD` | Database password |
| `DB_NAME` or `MYSQL_DATABASE` | Database name |

### Redis Configuration (Optional)

| Variable | Description |
|----------|-------------|
| `REDIS_HOST` | Redis host |
| `REDIS_PORT` | Redis port (default: 6379) |

### Sentry Configuration (Optional)

| Variable | Description |
|----------|-------------|
| `SENTRY_ENABLED` | Set to `true` to enable |
| `SENTRY_DSN` | Sentry DSN |
| `SENTRY_ENVIRONMENT` | Environment (e.g., production) |
| `SENTRY_TRACE_SAMPLE_RATE` | Trace sample rate (0.0-1.0) |
| `APP_VERSION` | Application version for release tracking |

#### Setting Up Sentry

1. **Install the Sentry SDK** in your application:
   ```bash
   composer require sentry/sentry
   ```

2. **Get your DSN** from your Sentry project settings (self-hosted or sentry.io)

3. **Configure environment variables**:
   ```bash
   SENTRY_ENABLED=true
   SENTRY_DSN=https://your-key@sentry.example.com/project-id
   SENTRY_ENVIRONMENT=production
   SENTRY_TRACE_SAMPLE_RATE=0.1
   APP_VERSION=1.0.0
   ```

4. **Restart the container** - Sentry will be auto-initialized for all PHP requests

The initialization script (`sentry-init.php`) is automatically prepended to all PHP requests when enabled. It handles:
- Error and exception capturing
- Performance tracing (configurable sample rate)
- Environment and release tagging
- Health check endpoint filtering

### Development Tools (dev target only)

The development image includes pre-installed tools:

| Tool | Command | Description |
|------|---------|-------------|
| Xdebug | (auto-loaded) | Step debugging, profiling, coverage |
| PHPUnit | `phpunit` | Testing framework |
| PHPStan | `phpstan` | Static analysis |
| PHP_CodeSniffer | `phpcs`, `phpcbf` | Code style checking/fixing |
| PHP-CS-Fixer | `php-cs-fixer` | Code style fixer |
| Composer | `composer` | Dependency management |

### Xdebug Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `XDEBUG_MODE` | `develop,debug,coverage` | Xdebug modes to enable |
| `XDEBUG_CLIENT_HOST` | `host.docker.internal` | IDE host address |
| `XDEBUG_CLIENT_PORT` | `9003` | IDE debug port |
| `XDEBUG_START_WITH_REQUEST` | `trigger` | When to start debugging |
| `XDEBUG_IDEKEY` | `PHPSTORM` | IDE key for session |

#### IDE Setup (VS Code)

Add to `.vscode/launch.json`:

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

#### Triggering Debug Sessions

With `XDEBUG_START_WITH_REQUEST=trigger`, start debugging by:
- Browser extension: [Xdebug Helper](https://chrome.google.com/webstore/detail/xdebug-helper)
- Query parameter: `?XDEBUG_TRIGGER=1`
- Cookie: `XDEBUG_TRIGGER=1`

### Production Optimizations

The production image includes:

| Feature | Description |
|---------|-------------|
| **OPcache + JIT** | Precompiled PHP with JIT compilation |
| **Brotli compression** | ~20% smaller than gzip for text assets |
| **Disabled functions** | `exec`, `shell_exec`, `system`, etc. |
| **Security headers** | X-Frame-Options, CSP, Referrer-Policy |
| **Minimal users** | Only `root` and `nobody` accounts |
| **No shell access** | Interactive shells removed |

## Makefile Commands

### Development

```bash
make up           # Start dev environment
make down         # Stop dev environment
make restart      # Restart containers
make logs         # View logs
make shell        # Access app shell
make clean        # Remove all containers and volumes
```

### Database

```bash
make db-shell     # Access MariaDB shell
make db-export    # Export database to database/dump.sql
make reset-db     # Reset database (WARNING: destroys data)
```

### Building

```bash
make build          # Build image for current platform
make build-dev      # Build development image
make build-prod     # Build production image
make build-all      # Build all PHP versions
make push           # Push to registry
```

### Testing

```bash
make test           # Basic tests on running container
make test-dev       # Build and test development target
make test-prod      # Build and test production target
make test-targets   # Test all build targets
```

## Health Checks

The image includes a comprehensive health check endpoint at `/health`:

```bash
curl http://localhost/health
```

Response:
```json
{
  "status": "healthy",
  "timestamp": 1703001234,
  "checks": {
    "database": "healthy",
    "redis": "healthy",
    "filesystem": "healthy",
    "opcache": "healthy"
  },
  "info": {
    "php_version": "8.4.0",
    "hostname": "abc123",
    "opcache_memory_usage": "12.45MB"
  }
}
```

## Security Features

- **Security headers**: X-Frame-Options, X-Content-Type-Options, CSP, etc.
- **Rate limiting**: Configurable request rate limits
- **File access restrictions**: Blocks access to `.env`, `.git`, `composer.*` files
- **Non-root execution**: Runs as `nobody` user
- **Hidden PHP version**: Removes `X-Powered-By` header
- **Static file caching**: Optimized cache headers for assets

## Building Multiple PHP Versions

### Using the build script

```bash
./scripts/build-all-versions.sh           # Build locally
./scripts/build-all-versions.sh --push    # Build and push to registry
```

### Manual build

```bash
# Build PHP 8.5 (latest)
docker build --build-arg ALPINE_VERSION=3.23 --build-arg PHP_VERSION=85 -t myapp:8.5 .

# Build PHP 8.4
docker build --build-arg ALPINE_VERSION=3.22 --build-arg PHP_VERSION=84 -t myapp:8.4 .

# Build PHP 8.3
docker build --build-arg ALPINE_VERSION=3.20 --build-arg PHP_VERSION=83 -t myapp:8.3 .
```

## GitHub Actions

The repository includes a GitHub Actions workflow that automatically:

1. Builds images for all supported PHP versions
2. Runs tests on each version
3. Pushes to GitHub Container Registry
4. Supports multi-architecture builds (amd64, arm64)

Triggered on:
- Push to `main` branch
- Git tags starting with `v*`
- Pull requests

## Production Deployment

### Docker Compose Example

```yaml
services:
  app:
    image: ghcr.io/host-uk/docker-server-php:8.5
    ports:
      - "80:80"
    environment:
      PHP_MEMORY_LIMIT: 512M
      DB_HOST: mariadb
      DB_USER: myapp
      DB_PASSWORD: secret
      DB_NAME: myapp
      REDIS_HOST: redis
    volumes:
      - ./app:/var/www/html
    restart: unless-stopped

  mariadb:
    image: mariadb:11.4
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: myapp
      MYSQL_USER: myapp
      MYSQL_PASSWORD: secret
    volumes:
      - mariadb_data:/var/lib/mysql

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  mariadb_data:
  redis_data:
```

### Coolify Deployment

1. Create new service in Coolify
2. Set Docker image to `ghcr.io/host-uk/docker-server-php:8.5` (or `8.4`, `8.3`, `8.2`)
3. Configure environment variables
4. Set up Traefik routing
5. Deploy

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

EUPL-1.2

## Support

- **Issues**: https://github.com/host-uk/docker-server-php/issues
- **Documentation**: https://github.com/host-uk/docker-server-php/wiki