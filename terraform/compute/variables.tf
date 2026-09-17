variable "project_prefix" {
  description = "A short prefix for naming resources."
  type        = string
}

variable "public_web_subnet_id" {
  description = "The ID of the public subnet for the Web tier."
  type        = string
}

variable "private_app_subnet_id" {
  description = "The ID of the private subnet for the App tier."
  type        = string
}

variable "web_sg_id" {
  description = "Security Group ID for the Web instance."
  type        = string
}

variable "app_sg_id" {
  description = "Security Group ID for the App instance."
  type        = string
}

variable "db_secret_arn" {
  description = "The ARN of the managed database secret."
  type        = string
}

variable "target_group_arn" {
  description = "The ARN of the ALB Target Group to attach the Web instance."
  type        = string
}