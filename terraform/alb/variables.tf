variable "project_prefix" {
  description = "A short prefix for naming resources."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the main VPC."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB."
  type        = list(string)
}

variable "alb_sg_id" {
  description = "The Security Group ID for the ALB."
  type        = string
}