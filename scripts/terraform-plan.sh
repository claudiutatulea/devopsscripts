#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TF_DIR="${TF_DIR:-terraform}"
: "${IMAGE_TAG:?IMAGE_TAG must be set}"
: "${ENVIRONMENT:?ENVIRONMENT must be set}"
TF_VARS_FILE="${TF_VARS_FILE:-${TF_DIR}/envs/${ENVIRONMENT}.tfvars}"

echo "==> [terraform-plan] Environment : $ENVIRONMENT"
echo "==> [terraform-plan] Vars file   : $TF_VARS_FILE"
echo "==> [terraform-plan] Directory   : $TF_DIR"

if [[ ! -f "$TF_VARS_FILE" ]]; then
  echo "ERROR: vars file not found: $TF_VARS_FILE"
  exit 1
fi

cd "$TF_DIR"

echo "  --> terraform init"
terraform init -input=false

echo "  --> terraform plan"
terraform plan \
  -input=false \
  -out=tfplan \
  -var="image_tag=${IMAGE_TAG}" \
  -var="environment=${ENVIRONMENT}" \
  -var-file="../${TF_VARS_FILE}"

echo "==> [terraform-plan] Plan saved to $TF_DIR/tfplan"
