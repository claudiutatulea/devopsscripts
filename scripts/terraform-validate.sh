#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TF_DIR="${TF_DIR:-terraform}"

echo "==> [terraform-validate] Validating Terraform in: $TF_DIR"

cd "$TF_DIR"

echo "  --> terraform fmt check"
terraform fmt -check -recursive

echo "  --> terraform init"
terraform init -backend=false -input=false

echo "  --> terraform validate"
terraform validate

echo "==> [terraform-validate] Done."
