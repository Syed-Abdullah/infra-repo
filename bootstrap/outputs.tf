output "state_bucket_name" {
  description = "Name of the created S3 bucket for remote state. Update backend.tf files with this value."
  value       = aws_s3_bucket.state.id
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table used for state locking"
  value       = aws_dynamodb_table.locks.name
}

output "aws_region" {
  description = "AWS Region where bootstrap resources were provisioned"
  value       = "us-east-1"
}
