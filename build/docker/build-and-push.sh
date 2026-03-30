#!/bin/bash

# Build and push FairCom Edge Docker image
# Usage: ./build-and-push.sh <dockerhub-username/repo-name> [tag] [--local|--readme-only|--scout]
#
# Credentials for README push (only used when not --local):
#   DOCKERHUB_USERNAME  - Docker Hub username
#   DOCKERHUB_TOKEN     - Docker Hub access token or password

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <dockerhub-username/repo-name> [tag] [--local|--readme-only|--scout]"
    echo "Example: $0 myusername/faircom-edge latest"
    echo ""
    echo "Options:"
    echo "  --local        Build locally without pushing to Docker Hub"
    echo "  --readme-only  Only push README to Docker Hub (skip image build)"
    echo "  --scout        Run Docker Scout vulnerability scan after push"
    exit 1
fi

REPO=$1
TAG=${2:-latest}
FULL_IMAGE="${REPO}:${TAG}"
LOCAL_ONLY=false
README_ONLY=false
SCOUT=false

# Check for flags
for arg in "$@"; do
    case "$arg" in
        --local) LOCAL_ONLY=true ;;
        --readme-only) README_ONLY=true ;;
        --scout) SCOUT=true ;;
    esac
done

# Change to build directory
cd "$(dirname "$0")/.."

push_readme() {
    local readme_path
    readme_path="$(pwd)/../README.md"
    if [ ! -f "$readme_path" ]; then
        echo "⚠️  README push skipped: README.md not found"
        return
    fi

    echo ""
    echo "Pushing README to Docker Hub..."

    # Retrieve credentials from Docker credential store if not set
    if [ -z "$DOCKERHUB_USERNAME" ] || [ -z "$DOCKERHUB_TOKEN" ]; then
        local creds
        creds=$(echo "https://index.docker.io/v1/" | docker-credential-osxkeychain get 2>/dev/null || true)
        DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME:-$(echo "$creds" | python3 -c 'import json,sys; print(json.load(sys.stdin)["Username"])' 2>/dev/null || true)}"
        DOCKERHUB_TOKEN="${DOCKERHUB_TOKEN:-$(echo "$creds" | python3 -c 'import json,sys; print(json.load(sys.stdin)["Secret"])' 2>/dev/null || true)}"
    fi

    if [ -z "$DOCKERHUB_TOKEN" ]; then
        echo "⚠️  README push skipped: no credentials found (set DOCKERHUB_TOKEN env var)"
        return
    fi

    TOKEN=$(curl -s -X POST "https://hub.docker.com/v2/users/login" \
        -H "Content-Type: application/json" \
        -d "{\"username\": \"${DOCKERHUB_USERNAME}\", \"password\": \"${DOCKERHUB_TOKEN}\"}" \
        | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

    if [ -z "$TOKEN" ]; then
        echo "⚠️  README push skipped: Docker Hub authentication failed"
        return
    fi

    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X PATCH \
        "https://hub.docker.com/v2/repositories/${REPO}/" \
        -H "Authorization: Bearer ${TOKEN}" \
        -H "Content-Type: application/json" \
        --data-binary "{
            \"description\": \"Multi-architecture Docker image for FairCom Edge IoT hub (~350MB) · linux/amd64 and linux/arm64\",
            \"full_description\": $(cat "$readme_path" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')
        }")

    if [ "$HTTP_STATUS" = "200" ]; then
        echo "✅ Successfully updated README for ${REPO}"
    else
        echo "⚠️  README push failed (HTTP ${HTTP_STATUS})"
    fi
}

run_scout() {
    if ! docker scout version &>/dev/null 2>&1; then
        echo "⚠️  Docker Scout skipped: 'docker scout' not available"
        return
    fi

    echo ""
    echo "Running Docker Scout analysis for ${FULL_IMAGE}..."

    echo ""
    echo "--- Vulnerability Summary ---"
    docker scout quickview "${FULL_IMAGE}" 2>/dev/null || true

    echo ""
    echo "--- Critical & High CVEs ---"
    docker scout cves "${FULL_IMAGE}" --only-severity critical,high 2>/dev/null || true

    echo ""
    echo "--- Base Image Recommendations ---"
    docker scout recommendations "${FULL_IMAGE}" 2>/dev/null || true
}

if [ "$README_ONLY" = true ]; then
    push_readme
    echo ""
    exit 0
fi

if [ "$LOCAL_ONLY" = true ]; then
    echo "Building ${FULL_IMAGE} locally (not pushing to Docker Hub)..."
else
    echo "Building and pushing ${FULL_IMAGE} for linux/amd64 and linux/arm64..."
fi

# Resolve build metadata for OCI labels
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
VCS_REF=$(git -C "$(pwd)" rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Build multi-architecture image
if [ "$LOCAL_ONLY" = true ]; then
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        -t "${FULL_IMAGE}" \
        --build-arg VERSION="${TAG}" \
        --build-arg BUILD_DATE="${BUILD_DATE}" \
        --build-arg VCS_REF="${VCS_REF}" \
        --load \
        -f docker/Dockerfile \
        .
else
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        -t "${FULL_IMAGE}" \
        --build-arg VERSION="${TAG}" \
        --build-arg BUILD_DATE="${BUILD_DATE}" \
        --build-arg VCS_REF="${VCS_REF}" \
        --sbom=true \
        --provenance=mode=max \
        --push \
        -f docker/Dockerfile \
        .
fi

echo ""
if [ "$LOCAL_ONLY" = true ]; then
    echo "✅ Successfully built ${FULL_IMAGE} locally"
else
    echo "✅ Successfully built and pushed ${FULL_IMAGE}"
    push_readme
    if [ "$SCOUT" = true ]; then
        run_scout
    fi
fi
echo ""
echo ""
