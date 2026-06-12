#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "==> [lint] Running linters..."

# Add your linter invocations below.
# Examples for common stacks — uncomment the relevant ones:

# --- Node.js / TypeScript ---
# npx eslint . --ext .js,.ts --max-warnings 0

# --- Python ---
# python -m flake8 .
# python -m pylint src/

# --- Go ---
# golangci-lint run ./...

# --- Java ---
# mvn checkstyle:check

echo "  [lint] No linter configured — add your linter command above."

echo "==> [lint] Done."
