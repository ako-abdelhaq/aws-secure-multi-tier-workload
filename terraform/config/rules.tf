# AWS Config Rules: Core Baseline & Threat Model Alignment

# Block Unrestricted SSH (0.0.0.0/0)
resource "aws_config_config_rule" "restricted_ssh" {
  name = "${var.project_prefix}-restricted-ssh"

  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }

  scope {
    compliance_resource_types = ["AWS::EC2::SecurityGroup"]
  }

  depends_on = [aws_config_configuration_recorder_status.main_status]
}

# Require EBS Volume Encryption
resource "aws_config_config_rule" "ebs_encryption" {
  name = "${var.project_prefix}-ebs-encrypted-volumes"

  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }

  scope {
    compliance_resource_types = ["AWS::EC2::Volume"]
  }

  depends_on = [aws_config_configuration_recorder_status.main_status]
}

# Block Public S3 Read
resource "aws_config_config_rule" "s3_public_read_prohibited" {
  name = "${var.project_prefix}-s3-public-read-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }

  scope {
    compliance_resource_types = ["AWS::S3::Bucket"]
  }

  depends_on = [aws_config_configuration_recorder_status.main_status]
}

# Require IMDSv2 on EC2 Instances (Mitigate SSRF / Credential Exfiltration)
resource "aws_config_config_rule" "ec2_imdsv2_check" {
  name = "${var.project_prefix}-ec2-imdsv2-check"

  source {
    owner             = "AWS"
    source_identifier = "EC2_IMDSV2_CHECK"
  }

  scope {
    compliance_resource_types = ["AWS::EC2::Instance"]
  }

  depends_on = [aws_config_configuration_recorder_status.main_status]
}

# Require RDS Storage Encryption (Defense-in-Depth for DB tier)
resource "aws_config_config_rule" "rds_storage_encrypted" {
  name = "${var.project_prefix}-rds-storage-encrypted"

  source {
    owner             = "AWS"
    source_identifier = "RDS_STORAGE_ENCRYPTED"
  }

  scope {
    compliance_resource_types = ["AWS::RDS::DBInstance"]
  }

  depends_on = [aws_config_configuration_recorder_status.main_status]
}


# Detect Root Access Keys (Global Account Level Check)
resource "aws_config_config_rule" "iam_root_access_key_check" {
  name = "${var.project_prefix}-iam-root-access-key-check"

  source {
    owner             = "AWS"
    source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
  }

  # No scope block required; AWS evaluates this for the AWS account.
  depends_on = [aws_config_configuration_recorder_status.main_status]
}

/*
I deliberately excluded CloudTrail and GuardDuty Config rules to prevent alert fatigue and double-billing. 
Since I already enabled AWS Security Hub's FSBP standard, those checks are inherently handled. Furthermore, 
foundational security services should be protected by preventative Service Control Policies (SCPs) at the Organization level, 
reserving AWS Config for tracking drift on highly dynamic resources like EC2, S3, and RDS.
*/
