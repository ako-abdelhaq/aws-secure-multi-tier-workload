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
# APP TIER ROLE (SSM + S3 Artifacts + Secrets Manager)
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

# App Instance Profile
resource "aws_iam_instance_profile" "app_profile" {
  name = "app-instance-profile"
  role = aws_iam_role.app_role.name
}

