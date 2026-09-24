# Defining CMK to encrypt DB secret
resource "aws_kms_key" "app_key" {
  description             = "CMK for RDS Master User Secret Encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Root Account Administration (Prevents permanent lockout)
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      # Allow RDS and Secrets Manager to generate and use the data key
      {
        Sid    = "AllowRDSAndSecretsManager"
        Effect = "Allow"
        Principal = {
          Service = [
            "rds.amazonaws.com",
            "secretsmanager.amazonaws.com"
          ]
        }
        Action = [
          "kms:GenerateDataKey*",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      # Allow App Tier explicit permission to decrypt
      {
        Sid    = "AllowAppServerRoleToDecrypt"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.app_role.arn # Must match your App tier IAM role resource name
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

# Define the Alias for easier referencing
resource "aws_kms_alias" "app_key_alias" {
  name          = "alias/app-key"
  target_key_id = aws_kms_key.app_key.key_id
}
