#!/bin/bash

# Build FairCom Edge Docker image locally (no push to Docker Hub)
# Usage: ./build-local.sh <dockerhub-username/repo-name> [tag] [platform]

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

echo "Building ${FULL_IMAGE} locally for ${PLATFORM} (not pushing to Docker Hub)..."

# Change to build directory
cd "$(dirname "$0")/.."

# Build for single platform and load into local Docker
docker buildx build \
    --platform "${PLATFORM}" \
    -t "${FULL_IMAGE}" \
    --load \
    -f docker/Dockerfile \
    .

echo ""
echo "✅ Successfully built ${FULL_IMAGE} locally for ${PLATFORM}"
echo "   Image loaded into local Docker daemon"
echo ""
echo "To test: docker run -d -p 8080:8080 ${FULL_IMAGE}"
echo ""
