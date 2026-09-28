output "artifact_bucket_name" {
  description = "S3 bucket for application release bundles"
  value = aws_s3_bucket.artifacts.id
}

output "web_instance_ids" {
  description = "List of IDs of the created EC2 instances"
  value       = aws_instance.web[*].id
}

output "app_instance_ids" {
  description = "List of IDs of the created EC2 instances"
  value       = aws_instance.app[*].id
}

output "key_arn" {
  description = "CMK for RDS Master User Secret Encryption"
  value = aws_kms_key.app_key.arn
}