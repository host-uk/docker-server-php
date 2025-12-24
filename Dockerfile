# ============================================================
# Multi-stage Dockerfile for Alpine + Nginx + PHP-FPM
# Supports dynamic PHP versions based on Alpine version
# ============================================================

# Build arguments for version control
ARG ALPINE_VERSION=3.22
ARG PHP_VERSION=84

# ============================================================
# Stage 1: Builder - Install dependencies and build assets
# ============================================================
FROM alpine:${ALPINE_VERSION} AS builder

ARG PHP_VERSION
ENV PHP_VERSION=${PHP_VERSION}

# Install build dependencies
RUN apk add --no-cache \
    git \
    curl \
    php${PHP_VERSION} \
    php${PHP_VERSION}-phar \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-openssl \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-iconv \
    php${PHP_VERSION}-tokenizer

# Create php symlink
RUN ln -s /usr/bin/php${PHP_VERSION} /usr/bin/php

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/bin --filename=composer

WORKDIR /build

# Copy application code
COPY product/ ./

# Install dependencies (only if composer.json exists)
RUN if [ -f composer.json ]; then \
        composer install \
            --no-dev \
            --optimize-autoloader \
            --no-interaction \
            --no-progress \
            --prefer-dist; \
    fi
COPY patch/ ./

# Run any additional build steps here
# RUN npm install && npm run build

# ============================================================
# Stage 2: Runtime - Minimal production image
# ============================================================
FROM alpine:${ALPINE_VERSION} AS runtime

ARG PHP_VERSION
ENV PHP_VERSION=${PHP_VERSION}
ENV PHP_INI_DIR=/etc/php${PHP_VERSION}

LABEL maintainer="Snider <snider@host.uk.com>"
LABEL org.opencontainers.image.source="https://github.com/host-uk/docker-server-php"
LABEL org.opencontainers.image.description="Production-ready Alpine+Nginx+PHP-FPM base image"
LABEL org.opencontainers.image.licenses="EUPL-1.2"
LABEL org.opencontainers.image.vendor="Host UK"
LABEL org.opencontainers.image.title="Docker Server PHP"
LABEL org.opencontainers.image.documentation="https://github.com/host-uk/docker-server-php"

# Install only runtime dependencies
RUN apk add --no-cache \
    nginx \
    php${PHP_VERSION} \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-ctype \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-dom \
    php${PHP_VERSION}-exif \
    php${PHP_VERSION}-fileinfo \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-iconv \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-mysqli \
    php${PHP_VERSION}-opcache \
    php${PHP_VERSION}-openssl \
    php${PHP_VERSION}-pdo \
    php${PHP_VERSION}-pdo_mysql \
    php${PHP_VERSION}-phar \
    php${PHP_VERSION}-posix \
    php${PHP_VERSION}-redis \
    php${PHP_VERSION}-session \
    php${PHP_VERSION}-simplexml \
    php${PHP_VERSION}-sodium \
    php${PHP_VERSION}-tokenizer \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-xmlreader \
    php${PHP_VERSION}-xmlwriter \
    php${PHP_VERSION}-zip \
    supervisor \
    curl \
    ca-certificates \
    gettext

# Create php symlink
RUN ln -s /usr/bin/php${PHP_VERSION} /usr/bin/php

WORKDIR /var/www/html

# Copy built application from builder
COPY --chmod=755 --chown=nobody:nobody --from=builder /build /var/www/html

# Copy configuration templates
COPY --chmod=644 --chown=nobody:nobody config/nginx.conf /etc/nginx/nginx.conf
COPY --chmod=755 --chown=nobody:nobody config/conf.d /etc/nginx/conf.d/
COPY --chmod=644 --chown=nobody:nobody config/fpm-pool.conf.template ${PHP_INI_DIR}/php-fpm.d/www.conf.template
COPY --chmod=644 --chown=nobody:nobody config/php.ini.template ${PHP_INI_DIR}/conf.d/custom.ini.template
COPY --chmod=644 --chown=nobody:nobody config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy and set up entrypoint
COPY --chmod=755 --chown=nobody:nobody scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

# Set permissions for system directories
RUN chown -R nobody:nobody /run /var/lib/nginx /var/log/nginx ${PHP_INI_DIR}

USER nobody

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl --silent --fail http://127.0.0.1/health || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
