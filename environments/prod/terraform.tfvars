aws_region           = "us-east-1"
environment          = "prod"
vpc_cidr             = "10.100.0.0/16"
public_subnet_cidrs  = ["10.100.1.0/24", "10.100.2.0/24"]
private_subnet_cidrs = ["10.100.10.0/24", "10.100.20.0/24"]
azs                  = ["us-east-1a", "us-east-1b"]
instance_type        = "t3.small"
