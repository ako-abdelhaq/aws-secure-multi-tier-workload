# -------------------------------------------------------------------------
# AWS Config: IAM Role & Permissions
# -------------------------------------------------------------------------
data "aws_iam_policy_document" "config_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "config_role" {
  name               = "aws-config-service-role"
  assume_role_policy = data.aws_iam_policy_document.config_assume_role.json
}

resource "aws_iam_role_policy_attachment" "config_managed_policy" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}


# -------------------------------------------------------------------------
# IAM Role: ConfigRemediationRole
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

# -------------------------------------------------------------------------
# IAM Policy: SSH + S3 + IMDSv2 Remediation Powers
# -------------------------------------------------------------------------
resource "aws_iam_role_policy" "config_remediation_policy" {
  name = "ConfigRemediationPolicy"
  role = aws_iam_role.config_remediation_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # SSH Remediation
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DescribeSecurityGroups",
          
          # S3 Remediation
          "s3:PutBucketPublicAccessBlock",
          "s3:GetBucketPublicAccessBlock",
          "s3:GetAccountPublicAccessBlock",
          "s3:PutAccountPublicAccessBlock",
          
          # IMDSv2 Remediation
          "ec2:ModifyInstanceMetadataOptions",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      }
    ]
  })
}