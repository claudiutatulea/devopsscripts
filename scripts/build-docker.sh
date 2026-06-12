#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

: "${DOCKER_REGISTRY:?DOCKER_REGISTRY must be set}"
: "${DOCKER_IMAGE:?DOCKER_IMAGE must be set}"
: "${IMAGE_TAG:?IMAGE_TAG must be set}"
: "${ENVIRONMENT:?ENVIRONMENT must be set}"

FULL_IMAGE="${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${IMAGE_TAG}"

echo "==> [build-docker] Building image: $FULL_IMAGE  (env: $ENVIRONMENT)"

docker build \
  --tag "$FULL_IMAGE" \
  --label "org.opencontainers.image.revision=${IMAGE_TAG}" \
  --label "org.opencontainers.image.created=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --label "deploy.environment=${ENVIRONMENT}" \
  --cache-from "${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${ENVIRONMENT}" \
  .

echo "==> [build-docker] Done: $FULL_IMAGE"
