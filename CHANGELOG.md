# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Multi-stage Dockerfile with `runtime`, `development`, and `production` targets
- Development tools: Xdebug, PHPUnit, PHPStan, PHP_CodeSniffer, PHP-CS-Fixer
- Production hardening with disabled dangerous functions and security optimizations
- Brotli compression support for Nginx
- OPcache JIT compilation for production
- Sentry.io integration for error monitoring
- Comprehensive test suite for build targets (`make test-targets`)
- MkDocs documentation site with Material theme
- GitHub Actions workflow for documentation deployment
- `.dockerignore` for optimized build context
- `.editorconfig` for consistent code formatting
- `CONTRIBUTING.md` guidelines
- `SECURITY.md` policy
- GitHub issue and PR templates

### Changed
- Upgraded Nginx configuration with performance optimizations
- Enhanced entrypoint script with environment-specific messaging
- Improved Makefile with build target commands
- Updated README with documentation links and badges

### Fixed
- Supervisor directory permissions in Docker build
- Removed hardcoded DOCKER_HOST from Makefile

### Security
- Disabled dangerous PHP functions in production (`exec`, `shell_exec`, `system`, etc.)
- Removed unnecessary users and shells in production image
- Added security headers to Nginx configuration
- Implemented session security settings

## [1.0.0] - 2024-12-24

### Added
- Initial Docker setup with multi-version PHP support (8.2, 8.3, 8.4, 8.5)
- Alpine Linux base with Nginx and PHP-FPM
- Supervisor process manager
- Health check endpoint at `/health`
- Environment-based configuration with templates
- Docker Compose for development and production
- MariaDB and Redis integration
- GitHub Actions for multi-architecture builds
- Comprehensive README documentation

### PHP Extensions Included
- bcmath, ctype, curl, dom, exif, fileinfo
- fpm, gd, iconv, intl, mbstring
- mysqli, opcache, openssl, pdo, pdo_mysql
- phar, posix, redis, session, simplexml
- sodium, tokenizer, xml, xmlreader, xmlwriter, zip

[Unreleased]: https://github.com/host-uk/docker-server-php/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/host-uk/docker-server-php/releases/tag/v1.0.0
