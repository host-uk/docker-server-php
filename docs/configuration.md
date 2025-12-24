# Configuration

All configuration is managed via environment variables following the [12-Factor App](https://12factor.net/) methodology.

## PHP Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `PHP_TIMEZONE` | `UTC` | PHP timezone ([list](https://www.php.net/manual/en/timezones.php)) |
| `PHP_MEMORY_LIMIT` | `256M` | Maximum memory per script |
| `PHP_UPLOAD_MAX_FILESIZE` | `64M` | Maximum upload file size |
| `PHP_POST_MAX_SIZE` | `64M` | Maximum POST data size |
| `PHP_MAX_EXECUTION_TIME` | `300` | Maximum execution time (seconds) |
| `PHP_MAX_INPUT_TIME` | `300` | Maximum input parsing time (seconds) |
| `PHP_MAX_INPUT_VARS` | `1000` | Maximum input variables |

### Example

```bash
PHP_TIMEZONE=Europe/London
PHP_MEMORY_LIMIT=512M
PHP_UPLOAD_MAX_FILESIZE=100M
PHP_POST_MAX_SIZE=100M
PHP_MAX_EXECUTION_TIME=60
```

## OPcache Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `PHP_OPCACHE_ENABLE` | `1` | Enable OPcache (0 or 1) |
| `PHP_OPCACHE_MEMORY` | `128` | Memory consumption (MB) |
| `PHP_OPCACHE_STRINGS` | `8` | Interned strings buffer (MB) |
| `PHP_OPCACHE_FILES` | `4000` | Max accelerated files (prime number) |
| `PHP_OPCACHE_REVALIDATE` | `2` | Revalidation frequency (seconds) |
| `PHP_OPCACHE_VALIDATE_TIMESTAMPS` | `1` | Check file changes (0 or 1) |
| `PHP_OPCACHE_JIT_BUFFER` | `128M` | JIT buffer size (production) |

### Production Recommendations

```bash
# Disable timestamp validation for maximum performance
PHP_OPCACHE_VALIDATE_TIMESTAMPS=0
PHP_OPCACHE_MEMORY=256
PHP_OPCACHE_JIT_BUFFER=128M
```

## PHP-FPM Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `PHP_FPM_PM` | `ondemand` | Process manager (static, dynamic, ondemand) |
| `PHP_FPM_MAX_CHILDREN` | `100` | Maximum child processes |
| `PHP_FPM_START_SERVERS` | `5` | Start servers (dynamic only) |
| `PHP_FPM_MIN_SPARE_SERVERS` | `5` | Minimum spare (dynamic only) |
| `PHP_FPM_MAX_SPARE_SERVERS` | `10` | Maximum spare (dynamic only) |
| `PHP_FPM_PROCESS_IDLE_TIMEOUT` | `10s` | Idle timeout (ondemand only) |
| `PHP_FPM_MAX_REQUESTS` | `1000` | Max requests per child |

### Process Manager Types

- **static**: Fixed number of child processes
- **dynamic**: Scales between min/max based on load
- **ondemand**: Creates processes on demand, kills when idle

```bash
# High-traffic production
PHP_FPM_PM=dynamic
PHP_FPM_MAX_CHILDREN=50
PHP_FPM_START_SERVERS=10
PHP_FPM_MIN_SPARE_SERVERS=5
PHP_FPM_MAX_SPARE_SERVERS=20
```

## Database Configuration

| Variable | Alternative | Description |
|----------|-------------|-------------|
| `DB_HOST` | `MYSQL_HOST` | Database host |
| `DB_USER` | `MYSQL_USER` | Database user |
| `DB_PASSWORD` | `MYSQL_PASSWORD` | Database password |
| `DB_NAME` | `MYSQL_DATABASE` | Database name |
| `MYSQL_ROOT_PASSWORD` | - | Root password (initial setup) |

Both naming conventions are supported for compatibility.

```bash
# Standard format
DB_HOST=mariadb
DB_USER=app
DB_PASSWORD=secret
DB_NAME=myapp

# MySQL format (alternative)
MYSQL_HOST=mariadb
MYSQL_USER=app
MYSQL_PASSWORD=secret
MYSQL_DATABASE=myapp
```

## Redis Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_HOST` | `redis` | Redis server host |
| `REDIS_PORT` | `6379` | Redis server port |

## Sentry Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `SENTRY_ENABLED` | `false` | Enable Sentry integration |
| `SENTRY_DSN` | - | Sentry DSN (required if enabled) |
| `SENTRY_ENVIRONMENT` | `production` | Environment name |
| `SENTRY_TRACE_SAMPLE_RATE` | `0.1` | Trace sample rate (0.0-1.0) |
| `APP_VERSION` | `1.0.0` | Application version for releases |
| `APP_HOSTNAME` | - | Server hostname (optional) |

See [Sentry Integration](sentry.md) for setup instructions.

## Xdebug Configuration (Development)

| Variable | Default | Description |
|----------|---------|-------------|
| `XDEBUG_MODE` | `develop,debug,coverage` | Xdebug modes |
| `XDEBUG_CLIENT_HOST` | `host.docker.internal` | IDE host address |
| `XDEBUG_CLIENT_PORT` | `9003` | IDE debug port |
| `XDEBUG_START_WITH_REQUEST` | `trigger` | When to start debugging |
| `XDEBUG_IDEKEY` | `PHPSTORM` | IDE key |

See [Development Tools](development.md) for Xdebug setup.

## Environment File Example

```bash
# .env file
APP_ENV=production

# PHP
PHP_TIMEZONE=UTC
PHP_MEMORY_LIMIT=256M

# Database
DB_HOST=mariadb
DB_USER=app
DB_PASSWORD=your-secure-password
DB_NAME=myapp

# Redis
REDIS_HOST=redis

# Sentry (optional)
SENTRY_ENABLED=true
SENTRY_DSN=https://key@sentry.example.com/1
```
