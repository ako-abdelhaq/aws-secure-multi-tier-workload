variable "project_prefix" {
  description = "A short prefix for naming resources."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where security groups will be created."
  type        = string
}