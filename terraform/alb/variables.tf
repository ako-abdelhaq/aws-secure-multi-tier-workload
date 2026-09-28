variable "project_prefix" {
  description = "A short prefix for naming resources."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the main VPC."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the web ALB."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the app ALB."
  type        = list(string)
}

variable "app_instance_ids" {
  description = "List of app EC2 instances."
  type = list(string)
}

variable "web_instance_ids" {
  description = "List of web EC2 instances."
  type = list(string)
}

variable "web_alb_sg_id" {
  description = "The Security Group ID for the web ALB."
  type        = string
}

variable "app_alb_sg_id" {
  description = "The Security Group ID for the app ALB."
  type        = string
}

variable "app_port" {
  description = "The port used by app."
  type = number
}