#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TF_DIR="terraform/vpc"
TF_VARS_FILE="../envs/vpc-development.tfvars"

if [[ ! -f "$TF_DIR/$TF_VARS_FILE" && ! -f "${TF_DIR}/${TF_VARS_FILE#../}" ]]; then
  echo "ERROR: vars file not found: $TF_DIR/$TF_VARS_FILE"
  exit 1
fi

echo "==> Initialising Terraform in $TF_DIR"
terraform -chdir="$TF_DIR" init -input=false

echo "==> Destroying resources (this will remove the VPC and public subnets)"
terraform -chdir="$TF_DIR" destroy -var-file="$TF_VARS_FILE" 

echo "==> Destroy complete."