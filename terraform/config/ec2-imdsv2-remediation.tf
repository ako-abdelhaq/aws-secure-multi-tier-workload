# Custom SSM Automation Document for IMDSv2
resource "aws_ssm_document" "enforce_imdsv2" {
  name            = "EnforceEC2InstanceIMDSv2"
  document_type   = "Automation"
  document_format = "YAML"

  content = file("${path.root}/../ssm/enforce_imdsv2.yml")  

}

# IMDSv2 Remediation Configuration
resource "aws_config_remediation_configuration" "remediate_imdsv2" {
  config_rule_name = aws_config_config_rule.ec2_imdsv2_check.name
  target_type      = "SSM_DOCUMENT"
  
  # Target our custom document instead of an AWS-managed one!
  target_id        = aws_ssm_document.enforce_imdsv2.name
  target_version   = "1"
  
  automatic                  = true
  maximum_automatic_attempts = 3
  retry_attempt_seconds      = 60

  parameter {
    name           = "InstanceId"
    resource_value = "RESOURCE_ID"
  }

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.config_remediation_role.arn
  }
}
