# Getting Started

This guide will help you get up and running with Docker Server PHP.

## Prerequisites

- Docker 20.10 or later
- Docker Compose v2 (optional, for local development)
- Git (for cloning the repository)

## Installation Options

### Option 1: Use Pre-built Images

The easiest way to get started is using our pre-built images from GitHub Container Registry:

```bash
docker pull ghcr.io/host-uk/docker-server-php:latest
```

Available tags:

| Tag | PHP Version | Alpine Version |
|-----|-------------|----------------|
| `latest`, `8.5` | 8.5 | 3.23 |
| `8.4` | 8.4 | 3.22 |
| `8.3` | 8.3 | 3.20 |
| `8.2` | 8.2 | 3.19 |

### Option 2: Build from Source

Clone the repository and build locally:

```bash
git clone https://github.com/host-uk/docker-server-php.git
cd docker-server-php

# Build production image
make build-prod

# Or build development image
make build-dev
```

### Option 3: Use as Base Image

Create a `Dockerfile` in your project:

```dockerfile
FROM ghcr.io/host-uk/docker-server-php:8.5

# Copy your application code
COPY --chown=nobody:nobody . /var/www/html

# Install dependencies (if using Composer)
RUN if [ -f composer.json ]; then \
    composer install --no-dev --optimize-autoloader; \
fi
```

## Directory Structure

When using this image, your application should follow this structure:

```
your-project/
├── public/           # Web root (index.php, assets)
├── src/              # Application source code
├── config/           # Configuration files
├── vendor/           # Composer dependencies
├── composer.json     # Composer configuration
└── composer.lock     # Composer lock file
```

## Configuration

All configuration is done via environment variables. Copy the example file:

```bash
cp .env.example .env
```

Edit `.env` with your settings. See [Configuration](configuration.md) for all available options.

## Running the Container

### Development Mode

```bash
# Using Docker Compose
docker compose -f docker-compose.dev.yml up

# Or manually
docker run -d \
  -p 8080:80 \
  -v $(pwd)/product:/var/www/html \
  -e APP_ENV=development \
  ghcr.io/host-uk/docker-server-php:dev-8.4
```

### Production Mode

```bash
# Using Docker Compose
docker compose up -d

# Or manually
docker run -d \
  -p 80:80 \
  -e APP_ENV=production \
  -e DB_HOST=your-db-host \
  -e DB_USER=your-user \
  -e DB_PASSWORD=your-password \
  ghcr.io/host-uk/docker-server-php:8.5
```

## Health Checks

The container includes a health check endpoint at `/health`:

```bash
curl http://localhost:8080/health
```

Response:
```json
{
  "status": "healthy",
  "checks": {
    "database": "healthy",
    "redis": "healthy",
    "filesystem": "healthy",
    "opcache": "healthy"
  }
}
```

## Next Steps

- [Configuration Reference](configuration.md)
- [Build Targets](build-targets.md)
- [Development Tools](development.md)
- [Production Deployment](deployment.md)
