output "logging_bucket_name" {
  description = "S3 bucket storing CloudTrail and Config logs"
  value       = aws_s3_bucket.logging.id
}

output "logging_bucket_policy" {
  description = "The logging bucket policy"
  value = aws_s3_bucket_policy.logging_bucket_policy
}