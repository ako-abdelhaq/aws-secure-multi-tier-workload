# Account Context
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Least-Privilege IAM Role for Lambda
resource "aws_iam_role" "lambda_incident_response_role" {
  name = "LambdaIncidentResponseRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Logging Policy: Strictly scoped to this specific Log Group
resource "aws_iam_role_policy" "lambda_logging_policy" {
  name = "LambdaLoggingScopedPolicy"
  role = aws_iam_role.lambda_incident_response_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "logs:CreateLogGroup"
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
            aws_cloudwatch_log_group.lambda_log_group.arn,
          "${aws_cloudwatch_log_group.lambda_log_group.arn}:*"
        ]
      }
    ]
  })
}

# Containment Policy: Scoped strictly to target users in this account
resource "aws_iam_role_policy" "lambda_containment_policy" {
  name = "IAMKeyKillSwitchPolicy"
  role = aws_iam_role.lambda_incident_response_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:UpdateAccessKey",
          "iam:GetUser",
          "iam:PutUserPolicy",
          "iam:AttachUserPolicy"
        ]
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/*"
      }
    ]
  })
}