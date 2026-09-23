variable "project_prefix" {
  description = "A short prefix for naming resources."
  type        = string
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer"
  type        = string
}