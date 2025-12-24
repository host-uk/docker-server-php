# Security

Docker Server PHP implements multiple layers of security hardening for production deployments.

## Production Hardening

The production build target includes:

### Disabled PHP Functions

Dangerous functions are disabled:

```ini
disable_functions = exec,passthru,shell_exec,system,proc_open,popen,parse_ini_file,show_source,pcntl_exec
```

### PHP Security Settings

```ini
# Hide PHP version
expose_php = Off

# Disable error display
display_errors = Off
display_startup_errors = Off

# Disable URL file operations
allow_url_fopen = Off
allow_url_include = Off
```

### Session Security

```ini
session.use_strict_mode = 1
session.use_only_cookies = 1
session.cookie_httponly = 1
session.cookie_secure = 1
session.cookie_samesite = Lax
session.use_trans_sid = 0
```

## Container Hardening

### Non-Root User

The container runs as `nobody`:

```dockerfile
USER nobody
```

### Minimal Users

Production target removes unnecessary users:

```bash
# Only root and nobody remain
sed -i -r '/^(nobody|root)/!d' /etc/passwd
```

### No Shell Access

Interactive shells are disabled:

```bash
sed -i -r 's#^(.*):[^:]*$#\1:/sbin/nologin#' /etc/passwd
```

### Package Manager Removed

APK is removed in production:

```bash
apk del apk-tools
```

## Nginx Security

### Hidden Server Version

```nginx
server_tokens off;
```

### Security Headers

```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
```

### Blocked File Access

```nginx
# Dotfiles (.env, .git, etc.)
location ~ /\. {
    deny all;
}

# Composer files
location ~ composer\.(json|lock)$ {
    deny all;
}

# Backup files
location ~ ~$ {
    deny all;
}
```

## Secret Management

### Environment Variables

Never commit secrets to version control. Use:

- Docker secrets
- Environment files (`.env`)
- Secret management services (Vault, AWS Secrets Manager)

```yaml
# docker-compose.yml
services:
  app:
    environment:
      DB_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

### Sensitive Environment Variables

Required secrets:

- `DB_PASSWORD` - Database password
- `MYSQL_ROOT_PASSWORD` - Database root password
- `SENTRY_DSN` - Contains auth token

## Network Security

### Internal Networks

Use Docker networks to isolate services:

```yaml
services:
  app:
    networks:
      - frontend
      - backend

  database:
    networks:
      - backend  # Not accessible from frontend

networks:
  frontend:
  backend:
    internal: true  # No external access
```

### Health Check Restrictions

The `/health` endpoint is restricted:

```nginx
location = /health {
    allow 127.0.0.1;
    allow 10.0.0.0/8;
    allow 172.16.0.0/12;
    allow 192.168.0.0/16;
    deny all;
}
```

## Dependency Security

### Composer Audit

Check for vulnerabilities:

```bash
composer audit
```

### Container Scanning

Scan images with Trivy:

```bash
trivy image ghcr.io/host-uk/docker-server-php:8.5
```

## Security Checklist

### Pre-Deployment

- [ ] Use production build target
- [ ] Set strong database passwords
- [ ] Configure HTTPS (via reverse proxy)
- [ ] Enable Sentry for error monitoring
- [ ] Review environment variables

### Post-Deployment

- [ ] Verify security headers
- [ ] Test file access restrictions
- [ ] Monitor for vulnerabilities
- [ ] Regular dependency updates
- [ ] Review container logs

## Reporting Vulnerabilities

Report security issues to:

- GitHub Security Advisories
- Email: security@host.uk.com

Please do not disclose security issues publicly until patched.
