# The regional WAF
resource "aws_wafv2_web_acl" "alb_waf" {
  name        = "${var.project_prefix}-alb-regional-waf"
  description = "AWS WAF for ALB with OWASP Top 10 and SQLi protection"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "alb-waf-main-metrics"
    sampled_requests_enabled   = true
  }

  # Common rules (XSS, Path Traversal, SSRF,... )
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "aws-common-rules-metric"
      sampled_requests_enabled   = true
    }
  }
  
  # SQL injection rule
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "aws-sqli-rules-metric"
      sampled_requests_enabled   = true
    }
  }

  # UNIX path rule 
  rule {
    name     = "AWSManagedRulesUnixRuleSet"
    priority = 30

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesUnixRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "aws-unix-rules-metric"
      sampled_requests_enabled   = true
    }
  }
  # You can add other rules: Rate limitting, IP reputation,... 
  
}

# Attach WAF to the ALB
resource "aws_wafv2_web_acl_association" "alb_waf_binding" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.alb_waf.arn
}

# Create the Log Group
resource "aws_cloudwatch_log_group" "waf_logs" {
  name              = "aws-waf-logs-alb"
  retention_in_days = 30
}

# Bind the Log Group to the Web ACL
resource "aws_wafv2_web_acl_logging_configuration" "alb_waf_logging" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_logs.arn]
  resource_arn            = aws_wafv2_web_acl.alb_waf.arn
  
  # Optional but recommended: Don't log sensitive headers/cookies
  redacted_fields {
    single_header {
      name = "authorization"
    }
  }
}