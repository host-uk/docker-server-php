# Docker Server PHP Template

This is a simple, easy-to-use Docker template for PHP applications. It provides a lightweight environment using Alpine Linux, Nginx, PHP 8.4, and Supervisor.

It is designed to be flexible: you can drop your application code into the `product` directory, and if you need to override any files (e.g., for a third-party application you are maintaining), you can place the modified files in the `patch` directory.

## Features

*   **OS**: Alpine Linux
*   **Web Server**: Nginx
*   **PHP**: PHP 8.4 (with common extensions like gd, intl, mbstring, mysqli, redis, etc.)
*   **Process Manager**: Supervisor
*   **Database**: MariaDB (in dev mode)
*   **Cache**: Redis (in dev mode)
*   **Non-root**: Runs as `nobody` user for security

## Directory Structure

*   `product/`: Place your main PHP application code here.
*   `patch/`: Place any files you want to override here. Files in this directory are copied *after* the `product` directory, overwriting any matching files.
*   `config/`: Nginx, PHP, and Supervisor configuration files.
*   `database/`: SQL scripts for database initialization (`schema.sql`, `user.sql`).

## Getting Started

### Prerequisites

*   Docker
*   Docker Compose
*   Make (optional, but recommended for using the provided Makefile)

### Usage

1.  **Add your code**: Copy your PHP application into the `product/` folder.
2.  **Apply patches (optional)**: If you need to modify specific files without changing the original source in `product/`, place the modified versions in the `patch/` folder maintaining the same directory structure.
3.  **Configure Environment**:
    *   Copy `.env.dev` to `.env` (or just use `.env.dev` as configured in the compose files).
    *   Adjust database credentials and other settings in the `.env` file.

### Development

A `Makefile` is provided to simplify common development tasks.

*   **Start the environment**:
    ```bash
    make up
    ```
    This builds the images and starts the containers (App, MariaDB, Redis) in the background. The app will be available at `http://localhost:8080`.

*   **Stop the environment**:
    ```bash
    make down
    ```

*   **View logs**:
    ```bash
    make logs
    ```

*   **Access the container shell**:
    ```bash
    make shell
    ```

#### Database Management

*   **Access the Database shell**:
    ```bash
    make db-shell
    ```

*   **Export Database**:
    ```bash
    make db-export
    ```
    Exports the database to `database/dump.sql`.

*   **Import/Reset Database**:
    To examine a database backup or reset the database to a clean state:
    1.  Paste your SQL dump (or schema definitions) into `database/schema.sql`.
    2.  Run the reset command:
        ```bash
        make reset-db
        ```
    **Warning**: This will destroy the existing database volume and all data within it, then re-initialize it using the contents of `database/schema.sql`.

## Production

The `Dockerfile` is designed to be self-contained. When building the image, it copies the configuration, `product` code, and `patch` files into the image.

The `docker-compose.yaml` file is a minimal example for running the built image, exposing port 80.

## Customization

*   **PHP/Nginx Config**: You can modify the configuration files in the `config/` directory.
*   **Extensions**: Add or remove PHP extensions in the `Dockerfile`.
