# PHP Extensions

Docker Server PHP includes a comprehensive set of PHP extensions for most application needs.

## Included Extensions

### Core Extensions

| Extension | Description |
|-----------|-------------|
| `bcmath` | Arbitrary precision mathematics |
| `ctype` | Character type checking |
| `curl` | Client URL library |
| `dom` | DOM XML manipulation |
| `exif` | Image metadata |
| `fileinfo` | File type detection |
| `gd` | Image processing |
| `iconv` | Character set conversion |
| `intl` | Internationalization |
| `mbstring` | Multibyte string handling |
| `openssl` | OpenSSL encryption |
| `phar` | PHP Archive support |
| `posix` | POSIX functions |
| `session` | Session handling |
| `simplexml` | SimpleXML |
| `sodium` | Sodium cryptography |
| `tokenizer` | PHP tokenizer |
| `xml` | XML support |
| `xmlreader` | XMLReader |
| `xmlwriter` | XMLWriter |
| `zip` | ZIP archive support |

### Database Extensions

| Extension | Description |
|-----------|-------------|
| `pdo` | PHP Data Objects |
| `pdo_mysql` | MySQL PDO driver |
| `mysqli` | MySQL Improved |

### Cache Extensions

| Extension | Description |
|-----------|-------------|
| `opcache` | Opcode caching |
| `redis` | Redis client |

### Development Extensions (dev target only)

| Extension | Description |
|-----------|-------------|
| `xdebug` | Debugging and profiling |
| `phpdbg` | PHP debugger |
| `pcov` | Code coverage |

## Checking Installed Extensions

```bash
# List all extensions
php -m

# Check specific extension
php -m | grep redis

# Get extension info
php --ri redis
```

## OPcache Configuration

### Development

```ini
opcache.enable = 1
opcache.validate_timestamps = 1
opcache.revalidate_freq = 0
```

### Production

```ini
opcache.enable = 1
opcache.validate_timestamps = 0
opcache.memory_consumption = 256
opcache.jit = tracing
opcache.jit_buffer_size = 128M
```

## Adding Extensions

### Build-Time Installation

Create a custom Dockerfile:

```dockerfile
FROM ghcr.io/host-uk/docker-server-php:8.5

USER root

# Add ImageMagick
RUN apk add --no-cache php84-pecl-imagick

# Add MongoDB
RUN apk add --no-cache php84-pecl-mongodb

USER nobody
```

### Available Alpine Packages

Common extensions available via APK:

```bash
# Search for PHP extensions
apk search php84-*
```

Popular additions:

| Package | Extension |
|---------|-----------|
| `php84-pecl-imagick` | ImageMagick |
| `php84-pecl-mongodb` | MongoDB |
| `php84-pecl-memcached` | Memcached |
| `php84-pecl-amqp` | RabbitMQ/AMQP |
| `php84-soap` | SOAP |
| `php84-ldap` | LDAP |
| `php84-pgsql` | PostgreSQL |
| `php84-pdo_pgsql` | PostgreSQL PDO |
| `php84-pdo_sqlite` | SQLite PDO |
| `php84-gmp` | GMP math |

### PECL Installation

For extensions not in Alpine packages:

```dockerfile
FROM ghcr.io/host-uk/docker-server-php:8.5

USER root

RUN apk add --no-cache --virtual .build-deps \
    autoconf \
    gcc \
    g++ \
    make \
    && pecl install some-extension \
    && apk del .build-deps

USER nobody
```

## Extension Configuration

### php.ini Settings

Mount custom configuration:

```yaml
services:
  app:
    volumes:
      - ./php-custom.ini:/etc/php84/conf.d/99_custom.ini
```

### Example: Redis Configuration

```ini
; php-custom.ini
redis.session.locking_enabled = 1
redis.session.lock_expire = 30
redis.session.lock_wait_time = 50000
```

### Example: OPcache Preloading

```ini
; Enable preloading (PHP 7.4+)
opcache.preload = /var/www/html/preload.php
opcache.preload_user = nobody
```

## Performance Tips

### OPcache

- Increase `opcache.memory_consumption` for large applications
- Enable JIT for CPU-intensive workloads
- Use preloading for frameworks

### Redis Sessions

```ini
session.save_handler = redis
session.save_path = "tcp://redis:6379"
```

### Realpath Cache

```ini
; Increase for production
realpath_cache_size = 4096K
realpath_cache_ttl = 600
```

## Troubleshooting

### Extension Not Loading

Check the error log:

```bash
docker compose logs app | grep -i extension
```

### Missing Dependencies

Some extensions require system libraries:

```dockerfile
# Example: GD with WebP support
RUN apk add --no-cache libwebp-dev
```

### Version Compatibility

Check extension compatibility with your PHP version:

```bash
php -v
php --ri extension_name
```
