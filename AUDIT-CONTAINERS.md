# Container Security Audit

This document outlines the findings of a security audit of the PHP container setup.

## PHP configuration security

**Finding:** The PHP-FPM status and ping pages are enabled and exposed by Nginx. Access is restricted to localhost, which is a good security measure.

**Risk:** While currently secure, this configuration could become a risk if the Nginx access controls are inadvertently loosened. These pages can leak information about server performance and status.

**Recommendation:** If the FPM status and ping pages are not actively used for monitoring in the production environment, it is recommended to disable them in the `fpm-pool.conf.template` to reduce the potential attack surface.

## Base image vulnerabilities

**Finding:** The `Dockerfile` uses a floating tag (`:3.22`) for the Alpine base image.

**Risk:** This practice can lead to unexpected behavior and security vulnerabilities, as the image referenced by the tag can be updated at any time. Builds are not guaranteed to be reproducible.

**Recommendation:** Pin the base image to a specific digest (e.g., `alpine:3.22@sha256:...`) to ensure that the same version of the base image is used every time the container is built. This can be done by first pulling the desired tag, then finding its digest with `docker images --digests`.

## Permission model

**Finding:** The container correctly drops privileges to the `nobody` user. The `listen.mode` for the PHP-FPM socket is set to `0666`.

**Risk:** The `0666` permission is world-writable, which is slightly more permissive than necessary. While the risk is low since the socket is contained and accessed by Nginx running as the same user, it's a good practice to use the most restrictive permissions possible.

**Recommendation:** Acknowledge the good practice of running as a non-root user. For hardening, consider changing `listen.mode` to `0660`.

## Secret injection

**Finding:** The `entrypoint.sh` script uses `envsubst` to inject environment variables into configuration files.

**Risk:** If secrets are passed as environment variables, this method writes them directly into the configuration files on the container's filesystem. This increases the attack surface, as anyone with access to the container image or running container's filesystem could potentially read these secrets.

**Recommendation:** Avoid using `envsubst` for secrets. Instead, use a more secure mechanism like Docker secrets, which mounts secrets as files in `/run/secrets/`. The application can then be configured to read secrets from these files directly. This is a more secure pattern supported by container orchestrators.

## Network exposure

**Finding:** The production `docker-compose.yaml` uses an ambiguous port mapping: `ports: - "80"`.

**Risk:** This maps the container's port 80 to a random high-numbered port on the host machine. This is unpredictable and could expose the service on an unintended port, potentially bypassing firewall rules.

**Recommendation:** Use an explicit port mapping to define the host and container ports, such as `"80:80"`. If the service should not be exposed publicly, consider binding it to the loopback interface, for example: `"127.0.0.1:80:80"`.
