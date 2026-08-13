aws_region           = "us-east-1"
environment          = "dev"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
azs                  = ["us-east-1a", "us-east-1b"]
instance_type        = "t3.micro"

#test for ci/cd
