variable "project_prefix" {
  description = "A short prefix for naming resources."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the main VPC."
  type        = string
}

variable "private_app_subnet_id" {
  description = "The subnet ID where endpoints will be placed."
  type        = string
}

variable "vpc_endpoints_sg_id" {
  description = "The Security Group ID for the endpoints."
  type        = string
}