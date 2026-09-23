output "alb_dns_name" {
  description = "The public DNS name of the ALB entrypoint."
  value       = aws_lb.web.dns_name
}

output "target_group_arn" {
  description = "The ARN of the Web Target Group."
  value       = aws_lb_target_group.web.arn
}

output "alb_arn" {
  description = "The ARN of the ALB"
  value = aws_lb.web.arn
}