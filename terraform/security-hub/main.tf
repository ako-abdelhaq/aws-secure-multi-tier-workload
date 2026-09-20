data "aws_region" "current" {}

# 1. Enable the Security Hub Service in the account
resource "aws_securityhub_account" "main" {
  enable_default_standards = false
  # In a multi-account organization, you would configure an admin/member 
  # delegation here. For this standalone dev/test architecture, we enable 
  # it at the local account level.
}

# 2. Subscribe to the AWS Foundational Security Best Practices (FSBP) standard
resource "aws_securityhub_standards_subscription" "fsbp" {
  depends_on    = [aws_securityhub_account.main]
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0"
}

# -------------------------------------------------------------------------
# SECURITY LEAD ARCHITECTURE NOTE (Production vs. Dev/Test Strategy)
# -------------------------------------------------------------------------
# We are deliberately omitting CIS AWS Foundations Benchmark and PCI-DSS standards.
#
# DEV/TEST REASONING: 
# Security Hub charges per compliance check. Restricting to FSBP ensures we stay 
# within the 30-day free trial tier while keeping the findings highly actionable 
# and preventing extreme alert fatigue during portfolio demonstration.
#
# PRODUCTION REASONING: 
# In a true enterprise environment, enabling multiple overlapping frameworks 
# (e.g., FSBP + CIS + PCI-DSS) simultaneously creates duplicate findings for the same 
# underlying misconfiguration (e.g., "S3 Bucket not encrypted"). A mature SOC 
# establishes a baseline with FSBP first, remediates the glaring issues, and only 
# layers on compliance-specific frameworks (like CIS or PCI) when formally required 
# by auditors, suppressing the duplicate checks natively in the Hub.
# -------------------------------------------------------------------------