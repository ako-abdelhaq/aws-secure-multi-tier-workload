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

output "alb_arn" {
  description = "The ARN of the ALB."
  value = module.alb.alb_arn
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

output "logging_bucket_name" {
  description = "S3 bucket for CloudTrail and Config logs"
  value       = module.log-bucket.logging_bucket_name
}

output "waf_arn" {
  description = "The ARN of the WAF"
  value = module.waf.waf_arn
}

output "waf_id" {
  description = "WAF ID"
  value = module.waf.waf_id
}

output "waf_name" {
  description = "The name of the WAF"
  value = module.waf.waf_name
}