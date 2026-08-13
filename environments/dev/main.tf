# Dev Web Server Security Group
resource "aws_security_group" "web" {
  name        = "${var.environment}-web-server-sg"
  description = "Allow inbound HTTP/HTTPS traffic and standard outbound access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-web-sg"
  }
}

# 1. VPC Module Consumption
module "vpc" {
  source = "git::https://github.com/Syed-Abdullah/terraform-aws-vpc.git?ref=v1.0.0"

  name                 = "${var.environment}-vpc"
  cidr_block           = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
  enable_nat_gateway   = true

  tags = {
    Environment = var.environment
  }
}

# 2. IAM Role Module Consumption
module "ec2_role" {
  source = "git::https://github.com/Syed-Abdullah/terraform-aws-iam-role.git?ref=v1.0.0"

  role_name        = "${var.environment}-web-server-role"
  trusted_services = ["ec2.amazonaws.com"]

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  tags = {
    Environment = var.environment
  }
}

# 3. EC2 Module Consumption
module "web_server" {
  source = "git::https://github.com/Syed-Abdullah/terraform-aws-ec2.git?ref=v1.0.1"

  name                        = "${var.environment}-web-server"
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.web.id]
  role_arn                    = module.ec2_role.role_arn
  create_iam_instance_profile = true
  root_volume_size            = 20

  tags = {
    Environment = var.environment
  }
}
