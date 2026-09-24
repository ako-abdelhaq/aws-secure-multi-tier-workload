# Provision the Amazon GuardDuty Detector
resource "aws_guardduty_detector" "main_detector" {
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"

  tags = {
    Name = "${var.project_prefix}-detector"
  }
}

# Enable RDS Login Events
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

# Explicitly disable Lambda Network Logs (VPC Flow Logs is sufficient for our architecture)
resource "aws_guardduty_detector_feature" "lambda_protection" {
  detector_id = aws_guardduty_detector.main_detector.id
  name        = "LAMBDA_NETWORK_LOGS"
  status      = "DISABLED"
}
