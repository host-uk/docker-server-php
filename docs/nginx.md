# Nginx Configuration

Docker Server PHP includes a production-ready Nginx configuration with security hardening and performance optimizations.

## Features

- Brotli compression (~20% smaller than gzip)
- Security headers (CSP, X-Frame-Options, etc.)
- Rate limiting ready
- Static file caching
- PHP-FPM integration
- Custom logging format

## Default Configuration

### Worker Processes

```nginx
worker_processes auto;
worker_rlimit_nofile 65535;

events {
    worker_connections 4096;
    multi_accept on;
    use epoll;
}
```

### Compression

Both gzip and Brotli compression are enabled:

```nginx
# Gzip
gzip on;
gzip_vary on;
gzip_proxied any;
gzip_types text/plain text/css application/json application/javascript ...;

# Brotli (production target)
brotli on;
brotli_comp_level 6;
brotli_min_length 256;
brotli_types text/plain text/css application/json ...;
```

### Security Headers

```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
```

## Server Block

The default server configuration (`config/conf.d/default.conf`):

```nginx
server {
    listen 80;
    server_name _;
    root /var/www/html/public;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

## File Access Restrictions

Sensitive files are blocked by default:

```nginx
# Block dotfiles
location ~ /\. {
    deny all;
}

# Block composer files
location ~ composer\.(json|lock)$ {
    deny all;
}

# Block environment files
location ~ \.env$ {
    deny all;
}
```

## Health Check Endpoint

The `/health` endpoint is restricted to local access:

```nginx
location = /health {
    allow 127.0.0.1;
    allow 10.0.0.0/8;
    allow 172.16.0.0/12;
    allow 192.168.0.0/16;
    deny all;

    fastcgi_pass 127.0.0.1:9000;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME /var/www/html/health.php;
}
```

## Static File Caching

Production target includes aggressive caching:

```nginx
map $sent_http_content_type $expires {
    default                    off;
    text/html                  epoch;
    text/css                   1y;
    application/javascript     1y;
    ~image/                    1y;
    ~font/                     1y;
}
```

## Performance Tuning

The production target includes optimizations:

```nginx
# Sendfile
sendfile on;
tcp_nopush on;
tcp_nodelay on;

# Open file cache
open_file_cache max=10000 inactive=60s;
open_file_cache_valid 120s;
open_file_cache_min_uses 2;
open_file_cache_errors on;

# FastCGI buffers
fastcgi_buffer_size 128k;
fastcgi_buffers 256 16k;
fastcgi_busy_buffers_size 256k;

# Timeouts
keepalive_timeout 65;
keepalive_requests 1000;
```

## Custom Configuration

### Override Default Config

Mount a custom configuration:

```yaml
services:
  app:
    volumes:
      - ./nginx/custom.conf:/etc/nginx/conf.d/custom.conf
```

### Add Virtual Hosts

Create additional server blocks:

```nginx
# custom.conf
server {
    listen 80;
    server_name api.example.com;

    location / {
        # API-specific configuration
    }
}
```

## Logging

### Log Format

Custom format includes response times:

```nginx
log_format main_timed '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for" '
                      '$request_time $upstream_response_time $pipe $upstream_cache_status';
```

### Log Output

Logs are sent to Docker:

```nginx
access_log /dev/stdout main_timed;
error_log /dev/stderr notice;
```

View logs:
```bash
docker compose logs -f app
```

## Rate Limiting

Add rate limiting for specific endpoints:

```nginx
# Define rate limit zone
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

server {
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        # ...
    }
}
```

## SSL/TLS

For production with SSL, use a reverse proxy (Traefik, Caddy) or add certificates:

```nginx
server {
    listen 443 ssl http2;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;

    # ...
}
```
