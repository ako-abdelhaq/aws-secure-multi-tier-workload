# AWS Config Remediation Configuration
resource "aws_config_remediation_configuration" "remediate_ssh" {
  config_rule_name = aws_config_config_rule.restricted_ssh.name
  target_type      = "SSM_DOCUMENT"
  target_id        = "AWS-DisablePublicAccessForSecurityGroup"
  target_version   = "1"
  
  automatic                  = true
  maximum_automatic_attempts = 3
  retry_attempt_seconds      = 60

  # Dynamically passes the non-compliant resource ID to the SSM Document
  parameter {
    name           = "GroupId"
    resource_value = "RESOURCE_ID"
  }

  # Passes the IAM role ARN to execute the automation
  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.config_remediation_role.arn
  }

  depends_on = [
    aws_config_config_rule.restricted_ssh,
    aws_iam_role_policy.config_remediation_policy
  ]
}
