#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

: "${DOCKER_REGISTRY:?DOCKER_REGISTRY must be set}"
: "${DOCKER_IMAGE:?DOCKER_IMAGE must be set}"
: "${IMAGE_TAG:?IMAGE_TAG must be set}"
: "${ENVIRONMENT:?ENVIRONMENT must be set}"
: "${REGISTRY_USERNAME:?REGISTRY_USERNAME must be set}"
: "${REGISTRY_TOKEN:?REGISTRY_TOKEN must be set}"

SHA_IMAGE="${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${IMAGE_TAG}"
ENV_IMAGE="${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${ENVIRONMENT}"

echo "==> [publish-docker] Logging in to $DOCKER_REGISTRY"
echo "$REGISTRY_TOKEN" | docker login "$DOCKER_REGISTRY" --username "$REGISTRY_USERNAME" --password-stdin

echo "==> [publish-docker] Tagging $SHA_IMAGE as $ENV_IMAGE"
docker tag "$SHA_IMAGE" "$ENV_IMAGE"

echo "==> [publish-docker] Pushing $SHA_IMAGE"
docker push "$SHA_IMAGE"

echo "==> [publish-docker] Pushing $ENV_IMAGE"
docker push "$ENV_IMAGE"

docker logout "$DOCKER_REGISTRY"

echo "==> [publish-docker] Done."
