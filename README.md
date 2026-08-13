# Enterprise Infrastructure Repository (`infra-repo`)

This repository represents the "live" infrastructure consumer codebase. It orchestrates versioned, modular infrastructure components (`terraform-aws-vpc`, `terraform-aws-iam-role`, `terraform-aws-ec2`) across distinct deployment environments (`dev` and `prod`).

---

## Architecture Overview

```
                      ┌─────────────────────────────────┐
                      │    Enterprise Modules (Git)    │
                      ├─────────────────────────────────┤
                      │  • terraform-aws-vpc (v1.0.0)   │
                      │  • terraform-aws-iam-role (v1.0)│
                      │  • terraform-aws-ec2 (v1.0.0)   │
                      └────────────────┬────────────────┘
                                       │ consumed by
             ┌─────────────────────────┴─────────────────────────┐
             │                                                   │
             ▼                                                   ▼
┌───────────────────────────┐                       ┌───────────────────────────┐
│   environments/dev        │                       │   environments/prod       │
├───────────────────────────┤                       ├───────────────────────────┤
│ • Small compute (t3.micro)│                       │ • Mid compute (t3.medium) │
│ • S3 Key: dev/tfstate     │                       │ • S3 Key: prod/tfstate    │
└────────────┬──────────────┘                       └────────────┬──────────────┘
             │                                                   │
             └─────────────────────────┬─────────────────────────┘
                                       ▼
                      ┌─────────────────────────────────┐
                      │      S3 + DynamoDB Backend      │
                      │  (Bootstrapped via bootstrap/) │
                      └─────────────────────────────────┘
```

### Module Repos vs. Live Infra Repo
- **Module Repos** (`terraform-aws-*`): Contain unit-tested, un-opinionated building blocks versioned via Git tags (`v1.0.0`). They do NOT define state backends or live infrastructure values.
- **Live Infra Repo** (`infra-repo`): Consumes versioned modules via Git URLs (`source = "git::https://github.com/.../terraform-aws-ec2.git?ref=v1.0.0"`). Defines live environment configurations, parameter values (`terraform.tfvars`), and remote state storage.

### Why Remote State is Split Per Environment
- **Blast Radius Reduction**: Storing `dev` and `prod` state in isolated keys (`dev/terraform.tfstate` vs `prod/terraform.tfstate`) prevents an error in `dev` from locking or corrupting production state.
- **Role Isolation**: Grants production pipelines restricted access to `prod/*` state paths without granting full access across all environments.

---

## How Bootstrap Works (The Chicken-and-Egg Problem)

To store Terraform state remotely in AWS S3 with state locking via DynamoDB, the S3 bucket and DynamoDB table must exist *first*.

Because the S3 backend cannot store state inside a bucket that has not yet been created, the `bootstrap/` configuration **uses local state on purpose**.

1. Run Terraform locally inside `bootstrap/` to provision the remote state bucket and locking table.
2. Once created, copy the output S3 bucket name into `environments/dev/backend.tf` and `environments/prod/backend.tf`.
3. Run `terraform init` inside each environment to initialize remote state storage.

---

## Quick Start Guide

### Step 1: Bootstrap Remote Backend
```bash
cd bootstrap
terraform init
terraform apply
# Take note of the `state_bucket_name` output
```

### Step 2: Configure Backend
Update `environments/dev/backend.tf` and `environments/prod/backend.tf` with your generated bucket name:
```hcl
terraform {
  backend "s3" {
    bucket         = "YOUR-UNIQUE-BOOTSTRAPPED-BUCKET-NAME"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
```

### Step 3: Deploy Environment
```bash
cd ../environments/dev
terraform init
terraform plan
terraform apply
```

---

## CI/CD Pipeline (`.github/workflows/terraform.yml`)

The repository includes a GitHub Actions workflow that executes across a matrix of `[dev, prod]`:
- **On Pull Requests**: Runs `terraform fmt`, `terraform validate`, `terraform plan`, and posts the generated plan as a comment on the PR.
- **On Push to Main**: Runs `terraform apply -auto-approve` for automated deployment.
