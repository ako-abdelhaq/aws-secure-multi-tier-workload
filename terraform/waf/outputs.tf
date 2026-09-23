output "waf_arn" {
  description = "The ARN of WebACLs"
  value = aws_wafv2_web_acl.alb_waf.arn
}

output "waf_name" {
  description = "The name of the WAF"
  value =aws_wafv2_web_acl.alb_waf.name 
}

output "waf_id" {
  description = "WAF ID"
  value = aws_wafv2_web_acl.alb_waf.id
}