# The main audit trail
resource "aws_cloudtrail" "main_audit_trail" {
  name                          = "workload-audit-trail"
  s3_bucket_name                = var.logging_bucket_name
  
  # Multi-Region Tracking
  # Captures API calls across all AWS regions, preventing attackers from 
  # hiding activity in unused regions (e.g., spinning up resources in ap-northeast-3).
  is_multi_region_trail         = true
  
  # Global Service Events
  # Ensures actions from IAM, Route53, and CloudFront (which are global, not regional) 
  # are recorded in your forensic logs.
  include_global_service_events = true
  
  # Cryptographic Tamper Detection
  # Delivers SHA-256 digest files to S3 every hour. If an attacker deletes or alters 
  # a log file to cover their tracks, the mathematical signature breaks.
  enable_log_file_validation    = true
  
  # Active Logging Status
  enable_logging                = true

  # (Data events are disabled by default in Terraform unless explicitly defined in an event_selector block)

  # CRITICAL: Prevent Race Conditions
  # Terraform must finish applying the S3 Bucket Policy BEFORE it creates the trail, 
  # otherwise AWS CloudTrail will fail its initial bucket write-access check.
  depends_on = [
    var.logging_bucket_policy
  ]
}
