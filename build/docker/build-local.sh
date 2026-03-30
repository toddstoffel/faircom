#!/bin/bash

# Build FairCom Edge Docker image locally (no push to Docker Hub)
# Usage: ./build-local.sh <dockerhub-username/repo-name> [tag] [platform] [--scout]

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <dockerhub-username/repo-name> [tag] [platform]"
    echo "Example: $0 myusername/faircom-edge latest"
    echo "Example: $0 myusername/faircom-edge latest linux/amd64"
    echo ""
    echo "Default platform: linux/amd64"
    echo "Note: --load only supports single platform builds"
    exit 1
fi

REPO=$1
TAG=${2:-latest}
PLATFORM=${3:-linux/amd64}
FULL_IMAGE="${REPO}:${TAG}"
SCOUT=false

for arg in "$@"; do
    case "$arg" in
        --scout) SCOUT=true ;;
    esac
done

echo "Building ${FULL_IMAGE} locally for ${PLATFORM} (not pushing to Docker Hub)..."

# Change to build directory
cd "$(dirname "$0")/.."

# Resolve build metadata for OCI labels
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
VCS_REF=$(git -C "$(pwd)" rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Build for single platform and load into local Docker
docker buildx build \
    --platform "${PLATFORM}" \
    -t "${FULL_IMAGE}" \
    --build-arg VERSION="${TAG}" \
    --build-arg BUILD_DATE="${BUILD_DATE}" \
    --build-arg VCS_REF="${VCS_REF}" \
    --load \
    -f docker/Dockerfile \
    .

echo ""
echo "✅ Successfully built ${FULL_IMAGE} locally for ${PLATFORM}"
echo "   Image loaded into local Docker daemon"
echo ""
echo "To test: docker run -d -p 8080:8080 ${FULL_IMAGE}"
echo ""

if [ "$SCOUT" = true ]; then
    if docker scout version &>/dev/null 2>&1; then
        echo "--- Vulnerability Summary ---"
        docker scout quickview "${FULL_IMAGE}" 2>/dev/null || true
        echo ""
        echo "--- Base Image Recommendations ---"
        docker scout recommendations "${FULL_IMAGE}" 2>/dev/null || true
        echo ""
    else
        echo "⚠️  Docker Scout skipped: 'docker scout' not available"
    fi
fi
