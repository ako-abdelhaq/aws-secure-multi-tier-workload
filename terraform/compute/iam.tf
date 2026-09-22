data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


# -------------------------------------------------------------
# WEB TIER ROLE (Minimal: SSM Only)
# -------------------------------------------------------------
resource "aws_iam_role" "web_role" {
  name               = "web-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# Attach SSM Core to Web
resource "aws_iam_role_policy_attachment" "web_ssm" {
  role       = aws_iam_role.web_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Web Instance Profile
resource "aws_iam_instance_profile" "web_profile" {
  name = "web-instance-profile"
  role = aws_iam_role.web_role.name
}


# -------------------------------------------------------------
# APP TIER ROLE (SSM + S3 Artifacts + Secrets Manager + KMS)
# -------------------------------------------------------------
resource "aws_iam_role" "app_role" {
  name               = "app-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# Attach SSM Core to App
resource "aws_iam_role_policy_attachment" "app_ssm" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

/*
# App-Only: Secrets Manager Read Policy
resource "aws_iam_role_policy" "app_secrets_read" {
  name = "app-secrets-read"
  role = aws_iam_role.app_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = var.db_secret_arn
      }
    ]
  })
}
*/

resource "aws_iam_policy" "app_secrets_policy" {
  name        = "AppTierSecretsAccess"
  description = "Allow Node.js to fetch and decrypt the RDS managed secret"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # 1. Permission to fetch the secret payload
        Effect   = "Allow"
        Action   = "secretsmanager:GetSecretValue"
        # Reference the dynamically created secret from the RDS instance
        Resource = var.db_secret_arn
      },
      {
        # 2. Permission to decrypt the payload using your CMK
        Effect   = "Allow"
        Action   = "kms:Decrypt"
        Resource = aws_kms_key.app_key.arn
      }
    ]
  })
}

# Attach this policy to the App Tier's IAM Role
resource "aws_iam_role_policy_attachment" "app_secrets_attach" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.app_secrets_policy.arn
}

# App Instance Profile
resource "aws_iam_instance_profile" "app_profile" {
  name = "app-instance-profile"
  role = aws_iam_role.app_role.name
}
