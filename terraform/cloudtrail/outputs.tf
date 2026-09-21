output "logging_bucket_name" {
  description = "Centralized logging S3 bucket name"
  value = aws_s3_bucket.logging.id
}