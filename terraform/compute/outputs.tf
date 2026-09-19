output "artifact_bucket_name" {
  description = "S3 bucket for application release bundles"
  value = aws_s3_bucket.artifacts.id
}

output "key_arn" {
  description = "CMK for RDS Master User Secret Encryption"
  value = aws_kms_key.app_key.arn
}