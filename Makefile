.PHONY: help up down restart logs build build-all push shell db-shell db-export reset-db clean health test

# ============================================================
# Docker Server PHP - Makefile
# ============================================================

# Default registry (override with: make push REGISTRY=ghcr.io/username/repo)
REGISTRY ?= ghcr.io/host-uk/docker-server-php

# Remote Docker host (optional - set to use a remote build server)
# Example: DOCKER_HOST ?= tcp://10.69.10.26:2375
DOCKER_HOST ?= tcp://10.69.10.26:2375

# Default PHP version for single builds
PHP_VERSION ?= 84
ALPINE_VERSION ?= 3.22
PHP_TAG ?= 8.4

help: ## Show this help message
	@echo "Docker Server PHP - Available Commands"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""

# ============================================================
# Development Commands
# ============================================================

up: ## Start dev environment
	docker-compose -f docker-compose.dev.yml up -d --build

down: ## Stop dev environment
	docker-compose -f docker-compose.dev.yml down

restart: ## Restart dev environment
	$(MAKE) down
	$(MAKE) up

logs: ## View logs (follow mode)
	docker-compose -f docker-compose.dev.yml logs -f

shell: ## Access app container shell
	docker-compose -f docker-compose.dev.yml exec app /bin/sh

clean: ## Remove all containers and volumes
	docker-compose -f docker-compose.dev.yml down -v
	docker system prune -f

# ============================================================
# Database Commands
# ============================================================

db-shell: ## Access MariaDB shell
	docker-compose -f docker-compose.dev.yml exec mariadb mysql -u root -p${MYSQL_ROOT_PASSWORD}

db-export: ## Export database to database/dump.sql
	docker-compose -f docker-compose.dev.yml exec mariadb mysqldump -u root -p${MYSQL_ROOT_PASSWORD} ${DB_NAME} > database/dump.sql

reset-db: ## Reset database (WARNING: destroys all data)
	@echo "WARNING: This will destroy all database data!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose -f docker-compose.dev.yml down -v; \
		docker-compose -f docker-compose.dev.yml up -d; \
	fi

# ============================================================
# Build Commands
# ============================================================

build: ## Build image for current platform
	docker build \
		--build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
		--build-arg PHP_VERSION=$(PHP_VERSION) \
		-t $(REGISTRY):$(PHP_TAG) \
		.

build-all: ## Build all PHP versions (8.2, 8.3, 8.4, 8.5)
	@echo "Building all PHP versions..."
	./scripts/build-all-versions.sh

push: ## Push images to registry
	@echo "Pushing images to $(REGISTRY)..."
	./scripts/build-all-versions.sh --push

# ============================================================
# Testing Commands
# ============================================================

health: ## Check health endpoint
	@echo "Checking health endpoint..."
	@curl -s http://localhost:8080/health | jq . || curl -s http://localhost:8080/health

test: ## Run basic tests
	@echo "Testing PHP version..."
	docker-compose -f docker-compose.dev.yml exec app php -v
	@echo ""
	@echo "Testing PHP modules..."
	docker-compose -f docker-compose.dev.yml exec app php -m
	@echo ""
	@echo "Testing health endpoint..."
	$(MAKE) health

# ============================================================
# Production Build Examples
# ============================================================

build-php85: ## Build PHP 8.5 image
	docker build --build-arg ALPINE_VERSION=3.23 --build-arg PHP_VERSION=85 -t $(REGISTRY):8.5 .

build-php84: ## Build PHP 8.4 image
	docker build --build-arg ALPINE_VERSION=3.22 --build-arg PHP_VERSION=84 -t $(REGISTRY):8.4 .

build-php83: ## Build PHP 8.3 image
	docker build --build-arg ALPINE_VERSION=3.20 --build-arg PHP_VERSION=83 -t $(REGISTRY):8.3 .

build-php82: ## Build PHP 8.2 image
	docker build --build-arg ALPINE_VERSION=3.19 --build-arg PHP_VERSION=82 -t $(REGISTRY):8.2 .