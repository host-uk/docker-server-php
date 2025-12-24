# Security Policy

## Supported Versions

We provide security updates for the following versions:

| Version | PHP | Supported |
|---------|-----|-----------|
| latest  | 8.5 | ✅ Yes |
| 8.4     | 8.4 | ✅ Yes |
| 8.3     | 8.3 | ✅ Yes |
| 8.2     | 8.2 | ✅ Yes |
| < 8.2   | -   | ❌ No |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

### How to Report

1. **Email**: Send details to security@host.uk.com
2. **GitHub Security Advisories**: Use the [Security tab](https://github.com/host-uk/docker-server-php/security/advisories/new)

### What to Include

- Type of vulnerability
- Steps to reproduce
- Affected versions
- Potential impact
- Suggested fix (if any)

### Response Timeline

- **Acknowledgment**: Within 48 hours
- **Initial assessment**: Within 1 week
- **Fix timeline**: Depends on severity
  - Critical: 24-48 hours
  - High: 1 week
  - Medium: 2 weeks
  - Low: Next release

## Security Best Practices

When using Docker Server PHP in production:

### Image Security

```bash
# Always use specific version tags
FROM ghcr.io/host-uk/docker-server-php:8.5

# Never use :latest in production
# FROM ghcr.io/host-uk/docker-server-php:latest  # Don't do this
```

### Container Security

1. **Use production target**: Includes security hardening
   ```bash
   docker build --target production -t myapp .
   ```

2. **Run as non-root**: Container runs as `nobody` by default

3. **Read-only filesystem** (where possible):
   ```yaml
   services:
     app:
       read_only: true
       tmpfs:
         - /tmp
         - /run
   ```

### Environment Variables

1. **Never commit secrets** to version control
2. **Use Docker secrets** or secret management:
   ```yaml
   secrets:
     db_password:
       external: true
   ```

3. **Restrict environment files**:
   ```bash
   chmod 600 .env
   ```

### Network Security

1. **Use internal networks** for database/cache:
   ```yaml
   networks:
     backend:
       internal: true
   ```

2. **Limit exposed ports**: Only expose what's necessary

3. **Use TLS**: Always use HTTPS in production

### PHP Security

The production image includes:

- Disabled dangerous functions (`exec`, `shell_exec`, `system`, etc.)
- `expose_php = Off`
- `display_errors = Off`
- Secure session configuration

### Regular Updates

1. **Update base images regularly**:
   ```bash
   docker pull ghcr.io/host-uk/docker-server-php:8.5
   ```

2. **Monitor for vulnerabilities**:
   ```bash
   # Scan with Trivy
   trivy image ghcr.io/host-uk/docker-server-php:8.5
   ```

3. **Keep dependencies updated**:
   ```bash
   composer audit
   ```

## Known Security Considerations

### Health Check Endpoint

The `/health` endpoint is restricted to internal networks by default. If you need external access, ensure proper authentication.

### Sentry DSN

If using Sentry, the DSN contains authentication. Keep it secure:
- Use environment variables
- Never commit to version control
- Restrict access to production configs

### Redis/Database

Default configurations use simple passwords. In production:
- Use strong, unique passwords
- Enable authentication
- Use TLS where available
- Restrict network access

## Security Updates

Security updates are announced via:

- GitHub Security Advisories
- Release notes
- GitHub Discussions (for non-critical issues)

## Acknowledgments

We appreciate responsible disclosure. Contributors who report valid security issues will be acknowledged (unless they prefer anonymity).
