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

variable "private_route_table_id" {
  description = "The ID of the private route table to associate with the S3 Gateway Endpoint."
  type        = string
}