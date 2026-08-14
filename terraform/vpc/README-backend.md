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

## What's included (free resources)

This tutorial module now creates only free or very-low-cost AWS objects useful for an initial networking and application test:
- `aws_vpc`, public `aws_subnet`s, `aws_internet_gateway`, and public route table (existing).
- `aws_security_group` for web servers (ingress allowed on port `80`).
- `aws_lb_target_group` for registering targets later (no load balancer is created by default).

These additions let you create security primitives and a target group (which is free) before moving on to EC2 instances and an Application Load Balancer.

## Exporting state for long-term restore

If you want to be able to re-run, inspect, or destroy this exact environment months from now without keeping the S3/DynamoDB backend permanently, export the Terraform state from a CI run or locally and store it in a secure location. Do NOT attempt to persist lock entries long term — locks are transient coordination objects.

Example commands to export state (run after `terraform init` in the module directory):

```bash
# pull the current state as JSON
terraform -chdir=terraform/vpc state pull > vpc.tfstate.json

# (optional) read the DynamoDB lock item if you want a record — not recommended for re-use
aws dynamodb get-item \
  --table-name "$TF_STATE_TABLE" \
  --key '{"LockID":{"S":"vpc/terraform.tfstate"}}' \
  > vpc-lock.json || true
```

Store `vpc.tfstate.json` in an encrypted bucket, a secure artifact store, or Terraform Cloud workspaces. When restoring, `terraform init` to the chosen backend and then:

```bash
# push the exported state into the backend (preferred)
terraform -chdir=terraform/vpc state push vpc.tfstate.json

# then run plan/apply as normal
terraform -chdir=terraform/vpc plan -var-file=../envs/vpc-development.tfvars
```

Security note: Terraform state can contain sensitive values. Encrypt and restrict access to exported state files, and rotate any credentials that may have been stored in state.

## CI artifact example

To retain the state JSON after a CI run, add a step that runs `terraform state pull` and uploads the file as a build artifact or stores it in an encrypted S3 bucket.

Example GitHub Actions snippet (add to the job after apply or plan):

```yaml
- name: Export Terraform state
  run: terraform -chdir=${{ env.TF_DIR }} state pull > vpc.tfstate.json

- name: Upload state artifact
  uses: actions/upload-artifact@v4
  with:
    name: vpc-tfstate
    path: ${{ env.TF_DIR }}/vpc.tfstate.json
```

Keep artifacts private and consider using long-term encrypted storage for multi-year retention.

## Running and retrieving artifacts from GitHub Actions

You can run the full lifecycle (plan, apply, destroy) from GitHub without running Terraform locally by using the `VPC Tutorial` workflow (`.github/workflows/vpc-workflow.yml`) and the `workflow_dispatch` input `operation`.

To trigger the workflow manually:

1. Go to the repository's **Actions** tab, select the `VPC Tutorial` workflow, and choose **Run workflow**.
2. Set `operation` to one of: `plan`, `apply`, or `destroy`.

Artifacts produced by the workflow:
- `vpc-tfplan`: the saved Terraform plan (`tfplan`) produced by the `plan` job.
- `vpc-tfstate`: the exported `vpc.tfstate.json` produced after `apply` or `destroy`.

To download artifacts after a run:

1. Open the workflow run in **Actions**.
2. On the right-hand side, expand **Artifacts**, then download the artifact you need.

Security and retention notes:
- Artifacts are retained according to your repository's retention policy; if you need multi-year retention, move the state JSON to an encrypted S3 bucket or Terraform Cloud.
- Treat the exported state as sensitive and restrict access.

## Recommended CI practice

- Always inspect the `vpc-tfplan` before applying (the workflow separates plan and apply).
- Upload the `vpc-tfstate` artifact for long-term restore, then move it into a secure backend (Terraform Cloud or an encrypted S3 bucket) if you plan to keep the environment around.
- Do not persist DynamoDB lock items long term; locks are ephemeral coordination artifacts.
