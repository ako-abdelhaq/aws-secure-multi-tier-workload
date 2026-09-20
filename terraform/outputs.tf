output "aws_region" {
  description = "The deployment region of the infrastructure."
  value       = var.aws_region
}

output "project_prefix" {
  description = "The prefix used for all resource names."
  value       = var.project_prefix
}

output "vpc_id" {
  description = "The ID of the main VPC."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "The IDs of the public web subnet."
  value       = module.network.public_subnet_ids
}

output "alb_dns_name" {
  description = "The public DNS name of the ALB entrypoint."
  value       = module.alb.alb_dns_name
}

output "db_endpoint" {
  description = "The private connection endpoint for the RDS database."
  value       = module.database.db_endpoint
}

output "db_secret_arn" {
  description = "The ARN of the managed database secret in Secrets Manager."
  value       = module.database.db_secret_arn
}

output "artifact_bucket_name" {
  description = "S3 bucket for application release bundles (Artifactory)"
  value       = module.compute.artifact_bucket_name
}

output "cloudtrail_logs_bucket_name" {
  description = "S3 bucket for CloudTrail logs"
  value       = module.cloudtrail.cloudtrail_logs_bucket_name
}
