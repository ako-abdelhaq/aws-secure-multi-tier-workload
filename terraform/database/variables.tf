variable "project_prefix" {
  description = "A short prefix for naming resources."
  type        = string
}

variable "db_subnet_group_name" {
  description = "The name of the DB subnet group created in the network module."
  type        = string
}

variable "db_sg_id" {
  description = "The Security Group ID for the database."
  type        = string
}

variable "db_username" {
  description = "The master username for the PostgreSQL database."
  type        = string
}

variable "key_arn" {
  description = "The app custom encryption key ARN"
  type = string
}