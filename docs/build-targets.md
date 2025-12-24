# Build Targets

The Dockerfile provides multiple build targets optimized for different use cases.

## Available Targets

| Target | Purpose | Size | Features |
|--------|---------|------|----------|
| `runtime` | Base image | ~130MB | PHP, Nginx, Supervisor |
| `development` | Local dev | ~200MB | + Xdebug, PHPUnit, Composer |
| `production` | Deployment | ~125MB | + Hardening, JIT, Brotli |

## Runtime Target

The base image containing all core components.

```bash
docker build --target runtime -t myapp:runtime .
```

**Includes:**

- Alpine Linux
- Nginx with Brotli compression
- PHP-FPM with common extensions
- Supervisor process manager
- Health check endpoint

## Development Target

Extended runtime with debugging and testing tools.

```bash
docker build --target development -t myapp:dev .

# Or use docker-compose
docker compose -f docker-compose.dev.yml up
```

**Additional Features:**

- Xdebug 3 (debugging, profiling, coverage)
- Composer package manager
- PHPUnit 11
- PHPStan 2
- PHP_CodeSniffer 3
- PHP-CS-Fixer 3
- Git, Make, Bash, Vim, Nano

**Environment:**

- `APP_ENV=development`
- `XDEBUG_MODE=develop,debug,coverage`
- Error display enabled
- OPcache timestamp validation enabled

## Production Target

Hardened, optimized image for production deployment.

```bash
docker build --target production -t myapp:prod .

# Or use docker-compose
docker compose up
```

**Security Hardening:**

- Dangerous PHP functions disabled (`exec`, `shell_exec`, `system`, etc.)
- Unnecessary users removed
- Interactive shells disabled
- Package manager removed
- Error display disabled
- `expose_php` disabled

**Performance Optimizations:**

- OPcache with JIT compilation
- File cache enabled
- Brotli compression (~20% smaller than gzip)
- Nginx performance tuning
- Open file caching

## Building with PHP Version

Specify PHP version using build arguments:

```bash
# PHP 8.5 (latest)
docker build \
  --build-arg ALPINE_VERSION=3.23 \
  --build-arg PHP_VERSION=85 \
  --target production \
  -t myapp:8.5 .

# PHP 8.4
docker build \
  --build-arg ALPINE_VERSION=3.22 \
  --build-arg PHP_VERSION=84 \
  --target production \
  -t myapp:8.4 .

# PHP 8.3
docker build \
  --build-arg ALPINE_VERSION=3.20 \
  --build-arg PHP_VERSION=83 \
  --target production \
  -t myapp:8.3 .
```

## Makefile Commands

```bash
# Build targets
make build-runtime    # Build runtime image
make build-dev        # Build development image
make build-prod       # Build production image

# Test targets
make test-runtime     # Test runtime target
make test-dev         # Test development target
make test-prod        # Test production target
make test-targets     # Test all targets
```

## Multi-Architecture Builds

Build for multiple architectures using Docker Buildx:

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --target production \
  -t myapp:latest \
  --push .
```

## Customizing Targets

Extend a target in your own Dockerfile:

```dockerfile
# Use production as base
FROM ghcr.io/host-uk/docker-server-php:8.5 AS base

# Add custom extensions
FROM base AS custom
USER root
RUN apk add --no-cache php84-imagick
USER nobody

# Copy application
COPY --chown=nobody:nobody . /var/www/html
```
