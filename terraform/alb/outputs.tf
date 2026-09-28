output "web_alb_dns_name" {
  description = "The public DNS name of the web ALB entrypoint."
  value       = aws_lb.web.dns_name
}

output "app_alb_dns_name" {
  description = "The DNS name of the internal app ALB entrypoint."
  value       = aws_lb.app.dns_name
}

output "web_alb_arn" {
  description = "The ARN of the web ALB"
  value = aws_lb.web.arn
}

/*
output "target_group_arn" {
  description = "The ARN of the Web Target Group."
  value       = aws_lb_target_group.web.arn
}


*/