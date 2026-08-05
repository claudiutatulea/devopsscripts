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
export TF_VAR_state_bucket=devopsscripts-terraform-state
export TF_VAR_state_region=eu-west-1
export TF_VAR_state_table=devopsscripts-terraform-lock
terraform -chdir=terraform/vpc init
```

## GitHub Actions

The workflow should pass the backend arguments via environment variables when running init.
