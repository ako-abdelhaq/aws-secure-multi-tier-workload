variable "project_prefix" {
  description = "A short prefix for naming resources."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where security groups will be created."
  type        = string
}

variable "public_web_subnet_ids" {
  description = "The ID of the public subnet for the Web tier."
  type        = list(string)
}

variable "private_app_subnet_ids" {
  description = "The ID of the private subnet for the App tier."
  type        = list(string)
}

variable "web_sg_id" {
  description = "Security Group ID for the Web instance."
  type        = string
}

variable "app_sg_id" {
  description = "Security Group ID for the App instance."
  type        = string
}

variable "app_alb_dns_name" {
  description = "The dns name of the app ALB"
  type        = string
}

variable "db_secret_arn" {
  description = "The ARN of the managed database secret."
  type        = string
}


variable "db_host" {
  description = "RDS DB instance hostname or endpoint"
  type        = string
}

variable "db_name" {
  description = "RDS DB instance name"
  type        = string
}

/*
variable "db_username" {
  description = "Database master username"
  type        = string
}
*/
