# Deployment

This guide covers deploying Docker Server PHP to various platforms.

## Docker Compose

### Production Deployment

```yaml
# docker-compose.yml
services:
  app:
    image: ghcr.io/host-uk/docker-server-php:8.5
    build:
      context: .
      target: production
    ports:
      - "80:80"
    environment:
      APP_ENV: production
      DB_HOST: mariadb
      DB_USER: app
      DB_PASSWORD: ${DB_PASSWORD}
      DB_NAME: app
      REDIS_HOST: redis
    depends_on:
      - mariadb
      - redis
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  mariadb:
    image: mariadb:11.4
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: app
      MYSQL_USER: app
      MYSQL_PASSWORD: ${DB_PASSWORD}
    volumes:
      - mariadb_data:/var/lib/mysql
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    restart: unless-stopped

volumes:
  mariadb_data:
  redis_data:
```

### Deploy

```bash
# Set environment variables
export DB_PASSWORD=secure-password
export MYSQL_ROOT_PASSWORD=root-password

# Deploy
docker compose up -d
```

## Kubernetes

### Deployment Manifest

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: php-app
  template:
    metadata:
      labels:
        app: php-app
    spec:
      containers:
        - name: app
          image: ghcr.io/host-uk/docker-server-php:8.5
          ports:
            - containerPort: 80
          env:
            - name: APP_ENV
              value: production
            - name: DB_HOST
              value: mariadb-service
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-secrets
                  key: password
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
          livenessProbe:
            httpGet:
              path: /health
              port: 80
            initialDelaySeconds: 10
            periodSeconds: 30
          readinessProbe:
            httpGet:
              path: /health
              port: 80
            initialDelaySeconds: 5
            periodSeconds: 10
```

### Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: php-app-service
spec:
  selector:
    app: php-app
  ports:
    - port: 80
      targetPort: 80
  type: ClusterIP
```

## Coolify

1. Create new service in Coolify
2. Set Docker image: `ghcr.io/host-uk/docker-server-php:8.5`
3. Configure environment variables
4. Set up domain with Traefik
5. Deploy

## Railway

```toml
# railway.toml
[build]
builder = "dockerfile"
dockerfilePath = "Dockerfile"

[deploy]
healthcheckPath = "/health"
healthcheckTimeout = 30
restartPolicyType = "on-failure"
```

## Fly.io

```toml
# fly.toml
app = "your-app-name"
primary_region = "lhr"

[build]
  dockerfile = "Dockerfile"

[http_service]
  internal_port = 80
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true

[[services.http_checks]]
  interval = "30s"
  timeout = "5s"
  path = "/health"
```

Deploy:
```bash
fly deploy
```

## DigitalOcean App Platform

```yaml
# .do/app.yaml
name: php-app
services:
  - name: web
    dockerfile_path: Dockerfile
    source_dir: /
    http_port: 80
    health_check:
      http_path: /health
    envs:
      - key: APP_ENV
        value: production
```

## Reverse Proxy Setup

### Traefik

```yaml
services:
  app:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.app.rule=Host(`example.com`)"
      - "traefik.http.routers.app.tls=true"
      - "traefik.http.routers.app.tls.certresolver=letsencrypt"
```

### Caddy

```
# Caddyfile
example.com {
    reverse_proxy app:80
}
```

### Nginx Proxy

```nginx
upstream php_app {
    server app:80;
}

server {
    listen 443 ssl http2;
    server_name example.com;

    ssl_certificate /etc/ssl/cert.pem;
    ssl_certificate_key /etc/ssl/key.pem;

    location / {
        proxy_pass http://php_app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Scaling

### Horizontal Scaling

```yaml
services:
  app:
    deploy:
      replicas: 3
```

### Load Balancing

Use a load balancer in front of multiple containers:

```yaml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx-lb.conf:/etc/nginx/nginx.conf

  app:
    deploy:
      replicas: 3
```

## Zero-Downtime Deployments

### Rolling Updates

```yaml
services:
  app:
    deploy:
      update_config:
        parallelism: 1
        delay: 10s
        order: start-first
```

### Blue-Green Deployment

1. Deploy new version to separate stack
2. Run health checks
3. Switch traffic to new stack
4. Remove old stack

## Monitoring

### Health Checks

The `/health` endpoint returns:

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

### Sentry Integration

Enable error monitoring:

```bash
SENTRY_ENABLED=true
SENTRY_DSN=https://...
```

### Prometheus Metrics

Add metrics endpoint (custom implementation):

```nginx
location /metrics {
    allow 10.0.0.0/8;
    deny all;
    # metrics handler
}
```
