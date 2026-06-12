#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TF_DIR="${TF_DIR:-terraform}"

echo "==> [terraform-test] Running Terraform tests in: $TF_DIR"

cd "$TF_DIR"

echo "  --> terraform init"
terraform init -input=false

echo "  --> terraform test"
terraform test -verbose

echo "==> [terraform-test] Done."
