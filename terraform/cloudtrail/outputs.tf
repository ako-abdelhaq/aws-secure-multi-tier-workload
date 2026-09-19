output "cloudtrail_logs_bucket_name" {
  description = "CloudTrail S3 bucket name"
  value = aws_s3_bucket.cloudtrail_logs.id
}