# -------------------------------------------------------------------------
# AWS Config: Configuration Recorder (Cost-Optimized Scope)
# -------------------------------------------------------------------------
resource "aws_config_configuration_recorder" "main" {
  name     = "main-config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    # Strictly scope to high-value assets to prevent CI ingestion costs
    all_supported                 = false
    include_global_resource_types = false
    resource_types = [
      "AWS::EC2::SecurityGroup",
      "AWS::EC2::Instance",
      "AWS::EC2::Volume",
      "AWS::RDS::DBInstance",
      "AWS::S3::Bucket"
    ]
  }
}

# -------------------------------------------------------------------------
# AWS Config: Delivery Channel & S3 Integration
# -------------------------------------------------------------------------
# Note: Update `var.logging_bucket.id` with your actual logging bucket reference
resource "aws_config_delivery_channel" "main" {
  name           = "main-delivery-channel"
  s3_bucket_name = var.logging_bucket_name
  #s3_key_prefix  = "Config" 
  /*
  "I deliberately chose not to use custom S3 prefixes (/Config).
   I routed all services to the native AWSLogs root directory because that ensures seamless 
   compatibility with enterprise SIEM parsers and AWS Athena partitions.
   To satisfy the Principle of Least Privilege, I enforced strict isolation at the IAM level, 
   trapping each service in its respective sub-directory so Config cannot overwrite CloudTrail."
  */
  
  depends_on = [aws_config_configuration_recorder.main]
}

# -------------------------------------------------------------------------
# AWS Config: Recorder Status (Enablement)
# -------------------------------------------------------------------------
resource "aws_config_configuration_recorder_status" "main_status" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true
  
  # Ensure the delivery channel exists before starting the recorder
  depends_on = [aws_config_delivery_channel.main]
}

