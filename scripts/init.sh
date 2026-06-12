#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "==> [init] Validating required tools..."

REQUIRED_TOOLS=(git docker)
for tool in "${REQUIRED_TOOLS[@]}"; do
  if ! command -v "$tool" &>/dev/null; then
    echo "ERROR: required tool not found: $tool"
    exit 1
  fi
  echo "  ✓ $tool $(${tool} --version 2>&1 | head -1)"
done

echo "==> [init] Environment info"
echo "  Branch : ${GITHUB_REF_NAME:-$(git rev-parse --abbrev-ref HEAD)}"
echo "  Commit : ${GITHUB_SHA:-$(git rev-parse HEAD)}"
echo "  Runner : ${RUNNER_OS:-local}"

echo "==> [init] Done."
