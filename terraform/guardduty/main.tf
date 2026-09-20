# Provision the Amazon GuardDuty Detector
resource "aws_guardduty_detector" "main_detector" {
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"

  tags = {
    Name = "${var.project_prefix}-detector"
  }
  
  # Note: In Terraform, optional protection plans (like EKS, Lambda, 
  # or S3 Malware Protection) are disabled by default unless explicitly 
  # defined using the `aws_guardduty_detector_feature` resource.
  # We will leave them disabled here to avoid unnecessary lab costs.
}

resource "aws_guardduty_detector_feature" "rds_protection" {
  detector_id = aws_guardduty_detector.main_detector.id
  name        = "RDS_LOGIN_EVENTS"
  status      = "ENABLED"
}

# Enable S3 Data Events
# This helps us detect if acompromised IAM role starts downloading thousands of sensitive objects
resource "aws_guardduty_detector_feature" "s3_protection" {
  detector_id = aws_guardduty_detector.main_detector.id
  name        = "S3_DATA_EVENTS"
  status      = "ENABLED"
}

# Disabling unnecessary services

# Explicitly disable EKS (Kubernetes) Audit Logs
resource "aws_guardduty_detector_feature" "eks_protection" {
  detector_id = aws_guardduty_detector.main_detector.id
  name        = "EKS_AUDIT_LOGS"
  status      = "DISABLED"
}

# Explicitly disable EBS Malware Protection
resource "aws_guardduty_detector_feature" "ebs_malware" {
  detector_id = aws_guardduty_detector.main_detector.id
  name        = "EBS_MALWARE_PROTECTION"
  status      = "DISABLED"
}

# Explicitly disable Lambda Network Logs
resource "aws_guardduty_detector_feature" "lambda_protection" {
  detector_id = aws_guardduty_detector.main_detector.id
  name        = "LAMBDA_NETWORK_LOGS"
  status      = "DISABLED"
}