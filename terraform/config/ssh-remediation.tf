# -------------------------------------------------------------------------
# 1. IAM Role: ConfigRemediationRole
# -------------------------------------------------------------------------
resource "aws_iam_role" "config_remediation_role" {
  name = "ConfigRemediationRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Grant SSM permissions to describe and modify Security Groups
resource "aws_iam_role_policy" "config_remediation_policy" {
  name = "ConfigRemediationPolicy"
  role = aws_iam_role.config_remediation_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DescribeSecurityGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

# -------------------------------------------------------------------------
# 2. Config Remediation Configuration
# -------------------------------------------------------------------------
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