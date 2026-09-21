variable "project_prefix" {
  description = "A short prefix for naming resources."
  type        = string
}

variable "logging_bucket_name" {
  description = "S3 bucket storing CloudTrail and Config logs"
  type = string
}

variable "logging_bucket_policy" {
  description = "The logging bucket policy"
  type = any
}