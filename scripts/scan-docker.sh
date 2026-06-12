#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

: "${DOCKER_REGISTRY:?DOCKER_REGISTRY must be set}"
: "${DOCKER_IMAGE:?DOCKER_IMAGE must be set}"
: "${IMAGE_TAG:?IMAGE_TAG must be set}"

FULL_IMAGE="${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${IMAGE_TAG}"

echo "==> [scan-docker] Scanning image: $FULL_IMAGE"

if ! command -v trivy &>/dev/null; then
  echo "  --> Installing Trivy..."
  curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
fi

echo "  --> trivy image scan (CRITICAL + HIGH, exit on CRITICAL)"
trivy image \
  --exit-code 1 \
  --severity CRITICAL \
  --no-progress \
  "$FULL_IMAGE"

echo "  --> trivy image scan (HIGH, report only)"
trivy image \
  --exit-code 0 \
  --severity HIGH \
  --no-progress \
  "$FULL_IMAGE"

echo "==> [scan-docker] Done."
