#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "==> [build] Setting up build environment..."

# Install build dependencies / configure build toolchain.
# Examples for common stacks — uncomment the relevant ones:

# --- Node.js ---
# npm ci --prefer-offline

# --- Python ---
# pip install --quiet -r requirements.txt

# --- Go ---
# go mod download

# --- Java ---
# mvn dependency:resolve --quiet

mkdir -p dist/

echo "  [build] No build setup configured — add your dependency install above."

echo "==> [build] Done."
