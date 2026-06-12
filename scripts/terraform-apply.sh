#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TF_DIR="${TF_DIR:-terraform}"

echo "==> [terraform-apply] Applying Terraform plan in: $TF_DIR"

cd "$TF_DIR"

if [[ ! -f tfplan ]]; then
  echo "ERROR: tfplan not found in $TF_DIR — run terraform-plan.sh first"
  exit 1
fi

echo "  --> terraform init"
terraform init -input=false

echo "  --> terraform apply"
terraform apply -input=false -auto-approve tfplan

echo "==> [terraform-apply] Done."
