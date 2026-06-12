#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "==> [unit-tests] Running unit tests..."

# Add your test runner below.
# Examples for common stacks — uncomment the relevant ones:

# --- Node.js / Jest ---
# npm ci
# npm test -- --ci --coverage

# --- Python / pytest ---
# python -m pytest tests/unit/ -v --tb=short

# --- Go ---
# go test ./... -v -count=1

# --- Java / Maven ---
# mvn test

echo "  [unit-tests] No test runner configured — add your test command above."

echo "==> [unit-tests] Done."
