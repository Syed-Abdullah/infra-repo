# BOOTSTRAP CONFIGURATION — LOCAL STATE ONLY
#
# INTERVIEW NOTE — The Chicken-and-Egg Problem:
# To use an S3 remote backend with DynamoDB locking, the S3 bucket and DynamoDB table must exist first.
# Terraform cannot use a remote backend to store the state of the backend itself.
# Therefore, `bootstrap/` uses LOCAL state on purpose to create the underlying storage infrastructure.
# Once bootstrapped, all other environment configurations (`dev`, `prod`) use the remote backend created here.

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# S3 Bucket for storing Terraform state files securely
resource "aws_s3_bucket" "state" {
  bucket        = "infra-tfstate-backend-${random_string.suffix.result}"
  force_destroy = true

  tags = {
    Name        = "Terraform Remote State Bucket"
    ManagedBy   = "terraform"
    Environment = "bootstrap"
  }
}

# Enable bucket versioning to allow state rollback if state corruption occurs
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable default server-side encryption (AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access to state bucket (State files contain secrets in plain text!)
resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB Table for distributed state locking (prevents concurrent state modifications)
resource "aws_dynamodb_table" "locks" {
  name         = "terraform-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    ManagedBy   = "terraform"
    Environment = "bootstrap"
  }
}
