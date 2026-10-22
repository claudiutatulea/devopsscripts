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

### destroy command
gh workflow run .github/workflows/vpc-workflow.yml --ref main --field operation=destroy --field create_https_listener=false

### check the run afterwards
gh run list --workflow=vpc-workflow.yml --limit 1

gh run view <run-id> --json status,conclusion,jobs,url

gh run view <run-id> --log


//////
gh run view 39415095863 --json status,conclusion,jobs,url

gh run view <run-id> --log



### For example, to install htop on all three VMs:
```bash
cd ~/ansible/ansible-project
ansible-playbook playbooks/install_program.yml -e "package_name=htop" --ask-become-pass
  ```

