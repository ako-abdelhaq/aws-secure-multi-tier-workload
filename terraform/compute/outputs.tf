output "artifact_bucket_name" {
  description = "S3 bucket for application release bundles"
  value = aws_s3_bucket.artifacts.id
}