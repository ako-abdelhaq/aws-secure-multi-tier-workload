output "alb_sg_id" {
  description = "Security Group ID for the ALB"
  value       = aws_security_group.alb.id
}

output "web_sg_id" {
  description = "Security Group ID for the Web Tier"
  value       = aws_security_group.web.id
}

output "app_sg_id" {
  description = "Security Group ID for the App Tier"
  value       = aws_security_group.app.id
}

output "db_sg_id" {
  description = "Security Group ID for the DB Tier"
  value       = aws_security_group.db.id
}

output "vpc_endpoints_sg_id" {
  description = "Security Group ID for the VPC Endpoints"
  value       = aws_security_group.vpc_endpoints.id
}