.PHONY: up down logs reset-db

up:
	docker-compose -f docker-compose.dev.yml up -d --build

down:
	docker-compose -f docker-compose.dev.yml down

logs:
	docker-compose -f docker-compose.dev.yml logs -f

build:
	docker-compose -f docker-compose.dev.yml build

shell:
	docker-compose -f docker-compose.dev.yml exec app /bin/sh

db-shell:
	docker-compose -f docker-compose.dev.yml exec mariadb /bin/sh -c "mysql -u root -p${MYSQL_ROOT_PASSWORD}"

db-export:
	docker-compose -f docker-compose.dev.yml exec mariadb /usr/bin/mysqldump -u root -p${MYSQL_ROOT_PASSWORD} ${DB_NAME} > database/dump.sql

reset-db:
	docker-compose -f docker-compose.dev.yml down -v
	docker-compose -f docker-compose.dev.yml up -d --build
