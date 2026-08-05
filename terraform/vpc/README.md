This tiny module creates a minimal VPC for tutorial purposes.

Files:
- `main.tf` — VPC, IGW, public subnets, public route table
- `variables.tf` — inputs
- `outputs.tf` — useful outputs

Usage (from repo root):

```bash
# initialise providers (no remote backend)
terraform -chdir=terraform/vpc init -input=false

# see what will be created (uses env file)
terraform -chdir=terraform/vpc plan -var-file=../envs/vpc-development.tfvars -input=false

# apply (will create resources in your AWS account)
terraform -chdir=terraform/vpc apply -var-file=../envs/vpc-development.tfvars -input=false

# destroy when done
bash scripts/vpc-destroy.sh
```
