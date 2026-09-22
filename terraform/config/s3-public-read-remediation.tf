# -------------------------------------------------------------------------
# S3 Remediation Configuration
# -------------------------------------------------------------------------
resource "aws_config_remediation_configuration" "remediate_s3_public_read" {
  config_rule_name = aws_config_config_rule.s3_public_read_prohibited.name
  target_type      = "SSM_DOCUMENT"
  target_id        = "AWSConfigRemediation-ConfigureS3BucketPublicAccessBlock"
  
  automatic                  = true
  maximum_automatic_attempts = 3
  retry_attempt_seconds      = 60

  parameter {
    name           = "BucketName"
    resource_value = "RESOURCE_ID"
  }
  
  # Tell the automation to block absolutely everything
  parameter {
    name         = "BlockPublicAcls"
    static_value = "true"
  }
  parameter {
    name         = "IgnorePublicAcls"
    static_value = "true"
  }
  parameter {
    name         = "BlockPublicPolicy"
    static_value = "true"
  }
  parameter {
    name         = "RestrictPublicBuckets"
    static_value = "true"
  }

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.config_remediation_role.arn
  }
}