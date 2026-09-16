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

output "public_web_subnet_id" {
  description = "The ID of the public web subnet."
  value       = module.network.public_web_subnet_id
}

output "alb_dns_name" {
  description = "The public DNS name of the ALB entrypoint."
  value       = module.alb.alb_dns_name
}