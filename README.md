# DevOpsScripts — Deployment Pipeline

A GitHub Actions deployment pipeline with full CI/CD stages, multi-environment support, Docker image scanning, and Terraform-managed infrastructure.

---

## Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Pipeline Flow](#pipeline-flow)
- [Branch → Environment Mapping](#branch--environment-mapping)
- [GitHub Setup](#github-setup)
  - [Environments](#environments)
  - [Secrets](#secrets)
  - [Workflow Permissions](#workflow-permissions)
- [Workflow Variables](#workflow-variables)
- [Scripts Reference](#scripts-reference)
  - [init.sh](#initsh)
  - [static-analysis.sh](#static-analysissh)
  - [lint.sh](#lintsh)
  - [unit-tests.sh](#unit-testssh)
  - [terraform-validate.sh](#terraform-validatesh)
  - [terraform-test.sh](#terraform-testsh)
  - [build.sh](#buildsh)
  - [build-app.sh](#build-appsh)
  - [build-docker.sh](#build-dockersh)
  - [scan-docker.sh](#scan-dockersh)
  - [publish-docker.sh](#publish-dockersh)
  - [terraform-plan.sh](#terraform-plansh)
  - [terraform-apply.sh](#terraform-applysh)
- [Terraform Reference](#terraform-reference)
  - [Variables](#variables)
  - [Environment Var Files](#environment-var-files)
- [Running Scripts Locally](#running-scripts-locally)
- [Customising for Your Stack](#customising-for-your-stack)

---

## Overview

This repository contains the GitHub Actions workflow definition and all supporting bash scripts for a complete deployment pipeline. Every pipeline stage is backed by a standalone script in `scripts/` that can also be run locally, keeping the workflow YAML thin and the logic testable.

Key characteristics:

- **13 named pipeline jobs** — each maps to one script.
- **3-environment model** — `dev` → development, `qa` → QA, `main` → production.
- **PRs run CI only** — test, lint, build, and scan stages run on every pull request; nothing is ever deployed from a PR.
- **Docker images are immutable** — each push is tagged with the git SHA; a mutable environment tag (`production`, `qa`, `development`) is updated alongside it.
- **Terraform uses saved plans** — `terraform plan` saves a binary plan that `terraform apply` consumes, so what is reviewed is exactly what is applied.
- **Trivy** scans the Docker image for vulnerabilities before it can be published; CRITICAL findings fail the pipeline.

---

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       └── pipeline.yml        # GitHub Actions workflow
├── scripts/
│   ├── init.sh                 #  1 — tool validation & env info
│   ├── static-analysis.sh      #  2 — SAST (Semgrep + ShellCheck)
│   ├── lint.sh                 #  3a — linter
│   ├── unit-tests.sh           #  3b — unit test runner
│   ├── terraform-validate.sh   #  4 — fmt check + validate
│   ├── terraform-test.sh       #  5 — terraform test
│   ├── build.sh                #  6 — dependency install / build setup
│   ├── build-app.sh            #  7 — compile / package application
│   ├── build-docker.sh         #  8 — docker build
│   ├── scan-docker.sh          #  9 — Trivy vulnerability scan
│   ├── publish-docker.sh       # 10 — docker push to registry
│   ├── terraform-plan.sh       # 11 — terraform plan (saves tfplan)
│   └── terraform-apply.sh      # 12 — terraform apply (from saved plan)
└── terraform/
    ├── main.tf                 # Provider + resource definitions
    ├── variables.tf            # Input variable declarations
    ├── outputs.tf              # Output declarations
    ├── envs/
    │   ├── production.tfvars   # Production-specific values
    │   ├── qa.tfvars           # QA-specific values
    │   └── development.tfvars  # Development-specific values
    └── tests/
        └── main.tftest.hcl     # Native Terraform tests
```

---

## Pipeline Flow

```
                         ┌─────────┐
                         │  setup  │  detect environment & is_deploy flag
                         └────┬────┘
                              │
                         ┌────▼────┐
                         │  init   │  validate tools, print env info
                         └────┬────┘
               ┌──────────────┴──────────────┐
               │  app path                   │  terraform path
       ┌───────▼────────┐            ┌───────▼────────────┐
       │ static-analysis│            │ terraform-validate  │
       └───────┬────────┘            └───────┬────────────┘
               │                             │
       ┌───────▼────────┐            ┌───────▼────────────┐
       │ lint-unit-tests│            │   terraform-test    │
       └───────┬────────┘            └───────┬────────────┘
               │                             │
           ┌───▼───┐                         │  (waits for publish-docker)
           │ build │                         │
           └───┬───┘                         │
               │                             │
          ┌────▼─────┐                       │
          │ build-app│                       │
          └────┬─────┘                       │
               │                             │
         ┌─────▼──────┐                      │
         │build-docker│                      │
         └─────┬──────┘                      │
               │                             │
         ┌─────▼──────┐                      │
         │ scan-docker│                      │
         └─────┬──────┘                      │
               │  (push events only)         │
       ┌───────▼────────┐                    │
       │ publish-docker │                    │
       └───────┬────────┘                    │
               └──────────────┬──────────────┘
                               │
                       ┌───────▼────────┐
                       │ terraform-plan │  (push events only)
                       └───────┬────────┘
                               │
                       ┌───────▼────────┐
                       │terraform-apply │  (push events only)
                       └────────────────┘  GitHub environment gate applied here
```

---

## Branch → Environment Mapping

| Branch | Environment   | Deploys automatically? | Notes                                 |
|--------|---------------|------------------------|---------------------------------------|
| `dev`  | `development` | Yes                    | Continuous deployment on every push   |
| `qa`   | `qa`          | Yes                    | Add reviewer in GitHub if needed      |
| `main` | `production`  | After approval         | Configure required reviewer in GitHub |

Pull requests targeting any of these branches **run CI only** — `publish-docker`, `terraform-plan`, and `terraform-apply` are all skipped.

---

## GitHub Setup

### Environments

Create three environments in the repository under **Settings → Environments**:

| Environment name | Recommended protection                        |
|------------------|-----------------------------------------------|
| `development`    | None (auto-deploy)                            |
| `qa`             | None, or optional reviewer                    |
| `production`     | **Required reviewer** + optional wait timer   |

The `terraform-apply` job targets the environment matching the branch, so the protection rules of that environment gate the actual deployment.

### Secrets

No extra secrets are required for the default `ghcr.io` registry — the built-in `GITHUB_TOKEN` is used. If you switch to a private registry (ECR, Docker Hub, etc.), add the following as repository or environment secrets:

| Secret name      | Used by              | Description                                                                 |
|------------------|----------------------|-----------------------------------------------------------------------------|
| `REGISTRY_TOKEN` | `publish-docker` job | Registry password / PAT. Defaults to `GITHUB_TOKEN` for `ghcr.io`          |

For cloud-provider credentials used by Terraform add those as **environment-level** secrets so each environment uses its own credentials:

| Secret name (example)   | Recommended scope | Description               |
|-------------------------|-------------------|---------------------------|
| `AWS_ACCESS_KEY_ID`     | Per environment   | AWS access key            |
| `AWS_SECRET_ACCESS_KEY` | Per environment   | AWS secret key            |
| `TF_BACKEND_CONFIG`     | Per environment   | Optional backend override |

### Workflow Permissions

The `publish-docker` job explicitly declares:

```yaml
permissions:
  packages: write   # required to push to ghcr.io
  contents: read
```

At the organisation level ensure **Settings → Actions → General → Workflow permissions** is set to at least *"Read repository contents and packages permissions"*, and that the repository is allowed to write packages.

---

## Workflow Variables

These are set at the top of `pipeline.yml` under `env:` and can be overridden per-job.

| Variable          | Default                     | Description                                            |
|-------------------|-----------------------------|--------------------------------------------------------|
| `DOCKER_REGISTRY` | `ghcr.io`                   | Container registry hostname                             |
| `DOCKER_IMAGE`    | `${{ github.repository }}`  | Image name — automatically `org/repo`                  |
| `TF_DIR`          | `terraform`                 | Path to the Terraform root module, relative to repo root |
| `IMAGE_TAG`       | `${{ github.sha }}`         | Immutable image tag — full 40-char commit SHA          |

The `setup` job derives and exports three additional values used by downstream jobs:

| Output         | Example value                       | Description                                                   |
|----------------|-------------------------------------|---------------------------------------------------------------|
| `environment`  | `production`                        | GitHub environment name; passed to scripts as `$ENVIRONMENT`  |
| `tf_vars_file` | `terraform/envs/production.tfvars`  | Path to the env-specific tfvars file                          |
| `is_deploy`    | `true` / `false`                    | `true` only for push events; gates all deployment jobs        |

---

## Scripts Reference

Every script:
- Uses `#!/usr/bin/env bash` with `set -euo pipefail` (fail-fast on any error, unset variable, or pipe failure).
- Begins with `cd "$(git rev-parse --show-toplevel)"` to always execute from the repository root regardless of where the script is invoked.
- Is executable (`chmod +x`).

---

### `init.sh`

**Stage:** 1 — Init

Validates that the minimum required tools are present on the runner and prints environment metadata.

**What it does:**
1. Checks that `git` and `docker` are available; exits with an error if either is missing.
2. Prints the branch name, commit SHA, and runner OS.

**Environment variables:**

| Variable          | Required | Default                     | Description                          |
|-------------------|----------|-----------------------------|--------------------------------------|
| `ENVIRONMENT`     | No       | _(none, informational only)_ | Passed in by the workflow for display |
| `GITHUB_REF_NAME` | No       | Falls back to `git rev-parse` | Set automatically by GitHub Actions  |
| `GITHUB_SHA`      | No       | Falls back to `git rev-parse` | Set automatically by GitHub Actions  |
| `RUNNER_OS`       | No       | `local`                     | Set automatically by GitHub Actions  |

---

### `static-analysis.sh`

**Stage:** 2 — Static Analysis

Runs SAST tooling against the source tree. Tools are skipped gracefully if not installed, so the script is safe to run locally without the full toolchain.

**What it does:**
1. Runs **Semgrep** (`--config auto`) across the whole repository if `semgrep` is on the PATH. Exits non-zero on findings.
2. Runs **ShellCheck** on every `.sh` file under `scripts/` if `shellcheck` is on the PATH.

**Environment variables:** None required.

---

### `lint.sh`

**Stage:** 3a — Lint

Placeholder for your project's linter. Uncomment the block that matches your stack.

**Supported stacks (commented out):**

| Stack              | Tool       | Command                                       |
|--------------------|------------|-----------------------------------------------|
| Node.js/TypeScript | ESLint     | `npx eslint . --ext .js,.ts --max-warnings 0` |
| Python             | flake8     | `python -m flake8 .`                          |
| Go                 | golangci-lint | `golangci-lint run ./...`                  |
| Java               | Checkstyle | `mvn checkstyle:check`                        |

**Environment variables:** None required.

---

### `unit-tests.sh`

**Stage:** 3b — Unit Tests

Placeholder for your project's test runner. Uncomment the block that matches your stack.

**Supported stacks (commented out):**

| Stack   | Tool   | Command                                      |
|---------|--------|----------------------------------------------|
| Node.js | Jest   | `npm test -- --ci --coverage`                |
| Python  | pytest | `python -m pytest tests/unit/ -v --tb=short` |
| Go      | go test | `go test ./... -v -count=1`                 |
| Java    | Maven  | `mvn test`                                   |

**Environment variables:** None required.

---

### `terraform-validate.sh`

**Stage:** 4 — Terraform Validate

Checks formatting and validates the Terraform configuration without contacting the backend. Safe to run without cloud credentials.

**What it does:**
1. `terraform fmt -check -recursive` — fails if any file is not formatted.
2. `terraform init -backend=false` — downloads providers without configuring remote state.
3. `terraform validate` — validates syntax and internal consistency.

**Environment variables:**

| Variable | Required | Default     | Description                                      |
|----------|----------|-------------|--------------------------------------------------|
| `TF_DIR` | No       | `terraform` | Path to the Terraform root module from repo root |

---

### `terraform-test.sh`

**Stage:** 5 — Terraform Test

Runs the native Terraform test suite (requires Terraform ≥ 1.6). Tests live in `terraform/tests/`.

**What it does:**
1. `terraform init` — initialises the module with backend configured.
2. `terraform test -verbose` — executes all `.tftest.hcl` files.

**Environment variables:**

| Variable | Required | Default     | Description                                      |
|----------|----------|-------------|--------------------------------------------------|
| `TF_DIR` | No       | `terraform` | Path to the Terraform root module from repo root |

---

### `build.sh`

**Stage:** 6 — Build Setup

Installs build-time dependencies and creates the `dist/` output directory. Runs before `build-app.sh` so that the dependency layer can be cached separately.

**Supported stacks (commented out):**

| Stack   | Command                           |
|---------|-----------------------------------|
| Node.js | `npm ci --prefer-offline`         |
| Python  | `pip install -r requirements.txt` |
| Go      | `go mod download`                 |
| Java    | `mvn dependency:resolve`          |

**Environment variables:** None required.

---

### `build-app.sh`

**Stage:** 7 — Build Application

Compiles or packages the application and writes output to `dist/`. The `dist/` directory is uploaded as a GitHub Actions artifact and downloaded by `build-docker.sh`.

**Supported stacks (commented out):**

| Stack   | Command                                                        |
|---------|----------------------------------------------------------------|
| Node.js | `npm run build` + copy output to `dist/`                       |
| Python  | `python -m build --outdir dist/`                               |
| Go      | `CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o dist/app`  |
| Java    | `mvn package -DskipTests` + copy JAR to `dist/`                |

**Environment variables:**

| Variable      | Required | Default  | Description                                           |
|---------------|----------|----------|-------------------------------------------------------|
| `ENVIRONMENT` | No       | _(none)_ | Can be used to toggle build flags per environment     |

---

### `build-docker.sh`

**Stage:** 8 — Build Docker Image

Builds the Docker image from the `Dockerfile` in the repository root. Expects build artefacts to already be present in `dist/`.

**What it does:**
1. Builds the image tagged as `<DOCKER_REGISTRY>/<DOCKER_IMAGE>:<IMAGE_TAG>`.
2. Applies OCI standard labels (`revision`, `created`) and a `deploy.environment` label.
3. Uses `--cache-from` with the current environment's mutable tag to speed up layer reuse.

**Environment variables:**

| Variable          | Required | Default | Description                                      |
|-------------------|----------|---------|--------------------------------------------------|
| `DOCKER_REGISTRY` | **Yes**  | —       | Registry hostname, e.g. `ghcr.io`                |
| `DOCKER_IMAGE`    | **Yes**  | —       | Image name, e.g. `org/repo`                      |
| `IMAGE_TAG`       | **Yes**  | —       | Immutable tag — git SHA                          |
| `ENVIRONMENT`     | **Yes**  | —       | Used for `--cache-from` tag and OCI label        |

---

### `scan-docker.sh`

**Stage:** 9 — Scan Docker Image

Scans the built image for known CVEs using [Trivy](https://github.com/aquasecurity/trivy). Trivy is auto-installed if not already present on the runner.

**What it does:**
1. Scans for **CRITICAL** vulnerabilities — exits non-zero (fails the pipeline) if any are found.
2. Scans for **HIGH** vulnerabilities — reports them but does not fail the pipeline.

**Environment variables:**

| Variable          | Required | Default | Description                    |
|-------------------|----------|---------|--------------------------------|
| `DOCKER_REGISTRY` | **Yes**  | —       | Registry hostname               |
| `DOCKER_IMAGE`    | **Yes**  | —       | Image name                     |
| `IMAGE_TAG`       | **Yes**  | —       | Tag of the image to scan       |

> **Tip:** To also fail the pipeline on HIGH findings, change the first scan block to `--severity CRITICAL,HIGH --exit-code 1`.

---

### `publish-docker.sh`

**Stage:** 10 — Publish Docker Image

Authenticates to the container registry and pushes two tags for the image.

**What it does:**
1. Logs in to `DOCKER_REGISTRY` using `REGISTRY_USERNAME` / `REGISTRY_TOKEN`.
2. Tags the SHA image with the environment name (`production`, `qa`, or `development`).
3. Pushes the **SHA tag** — immutable, permanent record of this exact build.
4. Pushes the **environment tag** — mutable pointer; always reflects the latest deploy to that environment.
5. Logs out after pushing.

**Environment variables:**

| Variable            | Required | Default in CI         | Description                                               |
|---------------------|----------|-----------------------|-----------------------------------------------------------|
| `DOCKER_REGISTRY`   | **Yes**  | `ghcr.io`             | Registry hostname                                         |
| `DOCKER_IMAGE`      | **Yes**  | `org/repo`            | Image name                                                |
| `IMAGE_TAG`         | **Yes**  | git SHA               | Used as the immutable tag                                 |
| `ENVIRONMENT`       | **Yes**  | branch-derived        | Used as the mutable tag (`production`, `qa`, `development`) |
| `REGISTRY_USERNAME` | **Yes**  | `github.actor`        | Registry login username                                   |
| `REGISTRY_TOKEN`    | **Yes**  | `secrets.GITHUB_TOKEN`| Registry password / token. Needs `packages: write` scope  |

---

### `terraform-plan.sh`

**Stage:** 11 — Terraform Plan

Initialises Terraform and produces a saved binary plan for the target environment.

**What it does:**
1. Resolves the vars file: `terraform/envs/<ENVIRONMENT>.tfvars` (overridable via `TF_VARS_FILE`).
2. Fails early if the vars file does not exist.
3. `terraform init` — initialises with full backend.
4. `terraform plan -out=tfplan` — passes `image_tag` and `environment` as `-var` flags plus the env-specific file as `-var-file`.
5. Saves the plan to `<TF_DIR>/tfplan` — uploaded as an artifact for `terraform-apply.sh`.

**Environment variables:**

| Variable       | Required | Default                               | Description                                          |
|----------------|----------|---------------------------------------|------------------------------------------------------|
| `TF_DIR`       | No       | `terraform`                           | Path to the Terraform root module                    |
| `IMAGE_TAG`    | **Yes**  | —                                     | Docker image tag to deploy; passed as `var.image_tag` |
| `ENVIRONMENT`  | **Yes**  | —                                     | Target environment; passed as `var.environment`      |
| `TF_VARS_FILE` | No       | `terraform/envs/<ENVIRONMENT>.tfvars` | Override the var file path                           |

---

### `terraform-apply.sh`

**Stage:** 12 — Terraform Apply

Applies the pre-computed plan produced by `terraform-plan.sh`. Never re-plans.

**What it does:**
1. Checks that `tfplan` exists in `TF_DIR`; exits with a helpful error if not.
2. `terraform init` — re-initialises the backend (required even with a saved plan).
3. `terraform apply -auto-approve tfplan` — applies exactly what was planned.

**Environment variables:**

| Variable      | Required | Default     | Description                                              |
|---------------|----------|-------------|----------------------------------------------------------|
| `TF_DIR`      | No       | `terraform` | Path to the Terraform root module                        |
| `ENVIRONMENT` | No       | _(none)_    | Informational; the plan already encodes the target state |

> **Important:** Do not modify any Terraform files or provider versions between `plan` and `apply`. The saved `tfplan` binary is tied to the exact state at plan time — any modification causes `apply` to fail with a plan-mismatch error.

---

## Terraform Reference

### Variables

Declared in `terraform/variables.tf`:

| Variable      | Type   | Required | Default        | Description                                |
|---------------|--------|----------|----------------|--------------------------------------------|
| `image_tag`   | string | **Yes**  | —              | Docker image tag (git SHA) to deploy       |
| `app_name`    | string | No       | `"app"`        | Application name used to name resources    |
| `environment` | string | No       | `"production"` | Deployment environment label               |

### Environment Var Files

Each file in `terraform/envs/` overrides variables for a specific environment. They are loaded automatically by `terraform-plan.sh` via `-var-file`.

| File                                | Branch | Purpose                                   |
|-------------------------------------|--------|-------------------------------------------|
| `terraform/envs/production.tfvars`  | `main` | Production infrastructure sizing & config |
| `terraform/envs/qa.tfvars`          | `qa`   | QA infrastructure sizing & config         |
| `terraform/envs/development.tfvars` | `dev`  | Development infrastructure sizing & config|

Add your infrastructure-specific variables to these files. Example:

```hcl
# terraform/envs/production.tfvars
environment        = "production"
app_name           = "myapp"
instance_count     = 3
instance_type      = "t3.medium"
enable_autoscaling = true
log_retention_days = 90
```

---

## Running Scripts Locally

All scripts resolve the repository root automatically via `git rev-parse --show-toplevel`, so they can be invoked from any directory inside the repository.

```bash
# Validate required tools
bash scripts/init.sh

# Terraform validation (no cloud credentials needed)
TF_DIR=terraform bash scripts/terraform-validate.sh

# Build and scan a Docker image
DOCKER_REGISTRY=ghcr.io \
DOCKER_IMAGE=myorg/myapp \
IMAGE_TAG=$(git rev-parse HEAD) \
ENVIRONMENT=development \
bash scripts/build-docker.sh

DOCKER_REGISTRY=ghcr.io \
DOCKER_IMAGE=myorg/myapp \
IMAGE_TAG=$(git rev-parse HEAD) \
bash scripts/scan-docker.sh

# Terraform plan locally against the development environment
TF_DIR=terraform \
IMAGE_TAG=$(git rev-parse HEAD) \
ENVIRONMENT=development \
bash scripts/terraform-plan.sh
```

---

## Customising for Your Stack

| Step | File to edit | What to do |
|------|--------------|------------|
| Linter | `scripts/lint.sh` | Uncomment your stack's block or add your own command |
| Tests | `scripts/unit-tests.sh` | Uncomment your stack's block |
| Dependency install | `scripts/build.sh` | Uncomment `npm ci` / `pip install` / `go mod download` etc. |
| Compile / package | `scripts/build-app.sh` | Uncomment your build command; output must go to `dist/` |
| Dockerfile | `Dockerfile` (create at repo root) | `build-docker.sh` runs `docker build .` from the repo root |
| Infrastructure | `terraform/main.tf` | Add your provider and resources |
| Env-specific sizing | `terraform/envs/*.tfvars` | Set instance counts, types, flags per environment |
| Remote backend | `terraform/main.tf` | Uncomment and fill in the `backend` block |
| Private registry | `pipeline.yml` | Update `DOCKER_REGISTRY`; store credentials as secrets and update `REGISTRY_TOKEN` in the `publish-docker` job |
