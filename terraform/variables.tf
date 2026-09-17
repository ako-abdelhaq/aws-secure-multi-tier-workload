variable "aws_region" {
  description = "The AWS region to deploy the infrastructure into."
  type        = string
  default     = "eu-west-3"
}

variable "project_prefix" {
  description = "A short prefix for naming resources."
  type        = string
  default     = "sec-app"
}

variable "environment" {
  description = "The deployment environment."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "The IPv4 CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to use for subnets."
  type        = list(string)
  default     = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
}

variable "db_username" {
  description = "The master username for the database."
  type        = string
  default     = "ako_admin" # Security by obscurity
}

variable "db_password" {
  description = "The master password for the database."
  type        = string
  sensitive = true
  default = "ako-ossu"
}
