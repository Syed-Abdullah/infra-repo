variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS Region to deploy infrastructure"
}

variable "environment" {
  type        = string
  default     = "prod"
  description = "Deployment environment name"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.100.0.0/16"
  description = "CIDR block for the Prod VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = ["10.100.1.0/24", "10.100.2.0/24"]
  description = "CIDR blocks for public subnets"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  default     = ["10.100.10.0/24", "10.100.20.0/24"]
  description = "CIDR blocks for private subnets"
}

variable "azs" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  description = "Availability Zones to distribute subnets"
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "EC2 instance type for prod web server"
}
