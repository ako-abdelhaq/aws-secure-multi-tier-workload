# -------------------------------------------------------------------------
# Custom SSM Automation Document for IMDSv2
# -------------------------------------------------------------------------
resource "aws_ssm_document" "enforce_imdsv2" {
  name            = "EnforceEC2InstanceIMDSv2"
  document_type   = "Automation"
  document_format = "YAML"
  
  content = <<DOC
description: "Enforces IMDSv2 on an EC2 instance by requiring HTTP tokens."
schemaVersion: "0.3"
assumeRole: "{{ AutomationAssumeRole }}"
parameters:
  InstanceId:
    type: String
    description: "The ID of the EC2 instance (passed automatically by AWS Config)"
  AutomationAssumeRole:
    type: String
    description: "The ARN of the remediation IAM role"
mainSteps:
  - name: modifyMetadataOptions
    action: aws:executeAwsApi
    inputs:
      Service: ec2
      Api: ModifyInstanceMetadataOptions
      InstanceId: "{{ InstanceId }}"
      HttpTokens: required
      HttpEndpoint: enabled
DOC
}

# -------------------------------------------------------------------------
# IMDSv2 Remediation Configuration
# -------------------------------------------------------------------------
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