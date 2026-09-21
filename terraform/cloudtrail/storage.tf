# 1. Fetch current account ID dynamically for bucket naming and policy
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# 2. Create the CloudTrail S3 Bucket
resource "aws_s3_bucket" "logging" {
  bucket        = "sec-app-logging-${data.aws_caller_identity.current.account_id}"
  
  # force_destroy = true allows Terraform to delete the bucket even if it contains logs.
  # Remove this line for actual production environments to prevent accidental audit loss.
  force_destroy = true 
  tags = { Name = "${var.project_prefix}-logging" }
}

# 3. Block All Public Access (Security Best Practice)
resource "aws_s3_bucket_public_access_block" "logging" {
  bucket                  = aws_s3_bucket.logging.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# 4. Enforce Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "logging" {
  bucket = aws_s3_bucket.logging.id

  rule {
    apply_server_side_encryption_by_default {
      # Using AES256 (SSE-S3) keeps the lab simpler and avoids circular KMS policy dependencies.
      sse_algorithm = "AES256" 
    }
  }
}

# 5. Lifecycle Rule: Expire logs after 30 days to save lab costs
resource "aws_s3_bucket_lifecycle_configuration" "logging" {
  bucket = aws_s3_bucket.logging.id

  rule {
    id     = "expire-audit-log-after-30-days"
    status = "Enabled"

    filter {
      # Leaving this empty acts as a "match everything" rule
    }

    expiration {
      days = 30
    }
  }
}

# 6. Mandatory Bucket Policy to allow CloudTrail to write logs
resource "aws_s3_bucket_policy" "cloudtrail_logging_policy" {
  bucket = aws_s3_bucket.logging.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # 1. Service ACL Check: Allow CloudTrail to verify bucket ownership
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.logging.arn
        Condition = {
          StringEquals = {
            "aws:SourceArn" = "arn:aws:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/workload-audit-trail"
          }
        }
      },
      
      # 2. Log Delivery: Allow CloudTrail to write logs specifically for this account/trail
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.logging.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl"  = "bucket-owner-full-control",
            "aws:SourceArn" = "arn:aws:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/workload-audit-trail"
          }
        }
      },
      
      # 3. Enforce TLS / HTTPS Only: Deny all unencrypted S3 requests
      {
        Sid    = "EnforceTLS"
        Effect = "Deny"
        Principal = "*"
        Action   = "s3:*"
        Resource = [
          aws_s3_bucket.logging.arn,
          "${aws_s3_bucket.logging.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
      
    ]
  })
}