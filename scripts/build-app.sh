#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "==> [build-app] Building application..."

# Add your build command below.
# Examples for common stacks — uncomment the relevant ones:

# --- Node.js ---
# npm run build
# cp -r build/ dist/

# --- Python ---
# python -m build --outdir dist/

# --- Go ---
# CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o dist/app ./cmd/...

# --- Java ---
# mvn package -DskipTests
# cp target/*.jar dist/

mkdir dist
echo test > dist/test.txt


echo "  [build-app] No build command configured — add your build command above."

echo "==> [build-app] Artifacts written to dist/"
ls -lh dist/ 2>/dev/null || true
