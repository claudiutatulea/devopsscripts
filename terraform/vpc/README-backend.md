# VPC Terraform Remote Backend

This tutorial module now uses an S3 backend with DynamoDB locking.

## Required AWS resources

You need an S3 bucket and a DynamoDB table in the same AWS region.

Recommended names:
- S3 bucket: `devopsscripts-terraform-state`
- DynamoDB table: `devopsscripts-terraform-lock`

## Backend configuration

The backend is declared in `terraform/vpc/backend.tf`.

### GitHub secrets required

Set these repository secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN` (only if using temporary credentials)
- `TF_STATE_BUCKET` — your S3 bucket name
- `TF_STATE_REGION` — your bucket region, for example `eu-west-1`
- `TF_STATE_TABLE` — DynamoDB lock table name

## Local init

```bash
export TF_STATE_BUCKET=devopsscripts-terraform-state
export TF_STATE_REGION=eu-west-1
export TF_STATE_TABLE=devopsscripts-terraform-lock
terraform -chdir=terraform/vpc init \
  -backend-config="bucket=${TF_STATE_BUCKET}" \
  -backend-config="key=vpc/terraform.tfstate" \
  -backend-config="region=${TF_STATE_REGION}" \
  -backend-config="dynamodb_table=${TF_STATE_TABLE}"
```

## GitHub Actions

The workflow should pass the backend arguments via environment variables when running init.
