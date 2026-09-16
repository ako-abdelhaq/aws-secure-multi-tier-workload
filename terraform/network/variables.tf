variable "vpc_cidr" {
  description = "The IPv4 CIDR block for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones to use for subnets."
  type        = list(string)
}

variable "project_prefix" {
  description = "A short prefix for naming resources."
  type        = string
}