output "vpc_id" {
  description = "The ID of the Dev VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "web_server_instance_id" {
  description = "The EC2 instance ID of the Dev Web Server"
  value       = module.web_server.instance_id
}

output "web_server_public_ip" {
  description = "The public IP of the Dev Web Server"
  value       = module.web_server.public_ip
}

output "web_server_role_arn" {
  description = "The IAM Role ARN attached to the Dev Web Server"
  value       = module.ec2_role.role_arn
}
