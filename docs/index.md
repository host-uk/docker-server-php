# Docker Server PHP

Production-ready Docker base image for PHP applications using Alpine Linux, Nginx, and PHP-FPM.

## Overview

Docker Server PHP provides a complete, production-ready environment for running PHP applications. It features:

- **Multi-version PHP support** (8.2, 8.3, 8.4, 8.5)
- **Alpine Linux** for minimal image size
- **Nginx** with security hardening and Brotli compression
- **Multiple build targets** for development and production
- **12-Factor App** compliant configuration

## Quick Start

### Using Pre-built Images

```bash
# Pull the latest image (PHP 8.5)
docker pull ghcr.io/host-uk/docker-server-php:latest

# Or specify a version
docker pull ghcr.io/host-uk/docker-server-php:8.4
```

### Using as Base Image

```dockerfile
FROM ghcr.io/host-uk/docker-server-php:8.5

# Copy your application
COPY --chown=nobody:nobody . /var/www/html

# Environment variables will be injected at runtime
ENV PHP_MEMORY_LIMIT=512M
```

### Local Development

```bash
# Clone the repository
git clone https://github.com/host-uk/docker-server-php.git
cd docker-server-php

# Copy environment file
cp .env.example .env

# Start development environment
make up
```

Your application will be available at `http://localhost:8080`.

## Build Targets

| Target | Use Case | Features |
|--------|----------|----------|
| `runtime` | Base image | PHP, Nginx, Supervisor |
| `development` | Local development | Xdebug, PHPUnit, PHPStan, Composer |
| `production` | Production deployment | Hardened, OPcache+JIT, Brotli |

## Features

### Production Ready

- Multi-stage builds for optimized image size
- Security hardening with CSP, X-Frame-Options
- Non-root user execution
- Health checks for monitoring
- Structured logging with performance metrics

### Developer Experience

- Xdebug for step debugging and profiling
- Pre-installed testing tools (PHPUnit, PHPStan)
- Hot-reload friendly configuration
- Docker Compose with MariaDB and Redis

## License

EUPL-1.2
