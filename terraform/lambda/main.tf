# -------------------------------------------------------------------------
# 2. Package and Deploy the Lambda Function
# -------------------------------------------------------------------------
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../lambda/incident-response/iam_killswitch.py"
  output_path = "../evidence/incident-response/iam_killswitch.zip"
}

resource "aws_lambda_function" "iam_killswitch" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "Security-Auto-Containment-IAM"
  role             = aws_iam_role.lambda_incident_response_role.arn
  handler          = "iam_killswitch.lambda_handler"
  
  # Performance & Runtime constraints
  runtime          = "python3.12" 
  memory_size      = 128
  timeout          = 15
  
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }

  # Ensure the IAM role has permissions to log BEFORE the function runs
  depends_on = [
    aws_iam_role_policy.lambda_logging_policy,
    aws_cloudwatch_log_group.lambda_log_group
  ]
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/Security-Auto-Containment-IAM"
  retention_in_days = 14
}


# -------------------------------------------------------------------------
# EventBridge Rule (The Tripwire)
resource "aws_cloudwatch_event_rule" "guardduty_iam_compromise" {
  name        = "GuardDuty-IAM-Credential-Compromise"
  description = "Triggers on IAM credential exfiltration findings from GuardDuty."

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail = {
      # Highly targeted to strictly control the blast radius
      type = [
        "UnauthorizedAccess:IAMUser/InstanceCredentialExfiltration.OutsideAWS",
        "UnauthorizedAccess:IAMUser/MaliciousIPCaller.Custom"
      ]
      
      # Implicit AND: Ensures we only fire on High/Critical severities
      severity = [{ numeric = [">=", 7.0] }] 
    }
  })
}

# -------------------------------------------------------------------------
# 6. EventBridge Target (The Router)
# -------------------------------------------------------------------------
resource "aws_cloudwatch_event_target" "invoke_killswitch_lambda" {
  rule      = aws_cloudwatch_event_rule.guardduty_iam_compromise.name
  target_id = "Trigger-IAM-KillSwitch-Lambda"
  arn       = aws_lambda_function.iam_killswitch.arn
}

# -------------------------------------------------------------------------
# 7. Lambda Resource Permission (The Authorization)
# -------------------------------------------------------------------------
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.iam_killswitch.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.guardduty_iam_compromise.arn
}