#!/bin/bash
# Build script for multiple PHP versions
# Usage: ./scripts/build-all-versions.sh [--push]

set -e

REGISTRY="${REGISTRY:-ghcr.io/host-uk/docker-server-php}"
PUSH=false

# Check for --push flag
if [ "$1" = "--push" ]; then
    PUSH=true
    echo "Push mode enabled"
fi

# Define PHP version matrix
# Format: "ALPINE_VERSION:PHP_VERSION:PHP_TAG"
VERSIONS=(
    "3.23:85:8.5"
    "3.22:84:8.4"
    "3.21:84:8.4"
    "3.20:83:8.3"
    "3.19:82:8.2"
)

echo "Building docker-server-php for multiple PHP versions..."
echo "Registry: ${REGISTRY}"
echo ""

for VERSION in "${VERSIONS[@]}"; do
    IFS=':' read -r ALPINE_VERSION PHP_VERSION PHP_TAG <<< "$VERSION"

    echo "================================================"
    echo "Building PHP ${PHP_TAG} (Alpine ${ALPINE_VERSION})"
    echo "================================================"

    # Build for current platform (faster for testing)
    docker build \
        --build-arg ALPINE_VERSION="${ALPINE_VERSION}" \
        --build-arg PHP_VERSION="${PHP_VERSION}" \
        -t "${REGISTRY}:${PHP_TAG}" \
        -t "${REGISTRY}:${PHP_TAG}-alpine${ALPINE_VERSION}" \
        .

    # Tag as latest if PHP 8.5
    if [ "${PHP_TAG}" = "8.5" ]; then
        docker tag "${REGISTRY}:${PHP_TAG}" "${REGISTRY}:latest"
        echo "Tagged as latest"
    fi

    # Test the image
    echo "Testing image..."
    docker run --rm "${REGISTRY}:${PHP_TAG}" php -v

    # Push if requested
    if [ "${PUSH}" = true ]; then
        echo "Pushing ${REGISTRY}:${PHP_TAG}..."
        docker push "${REGISTRY}:${PHP_TAG}"
        docker push "${REGISTRY}:${PHP_TAG}-alpine${ALPINE_VERSION}"

        if [ "${PHP_TAG}" = "8.5" ]; then
            docker push "${REGISTRY}:latest"
        fi
    fi

    echo ""
done

echo "================================================"
echo "Build complete!"
echo "================================================"
echo ""
echo "Available tags:"
for VERSION in "${VERSIONS[@]}"; do
    IFS=':' read -r ALPINE_VERSION PHP_VERSION PHP_TAG <<< "$VERSION"
    echo "  - ${REGISTRY}:${PHP_TAG}"
    echo "  - ${REGISTRY}:${PHP_TAG}-alpine${ALPINE_VERSION}"
done
echo "  - ${REGISTRY}:latest (PHP 8.5)"