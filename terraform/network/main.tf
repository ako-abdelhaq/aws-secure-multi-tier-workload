# Core VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_prefix}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_prefix}-igw"
  }
}

# Web Tier (Public)
resource "aws_subnet" "public_web_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_prefix}-public-web-subnet-a"
    Tier = "Web"
  }
}
# Another subnet for the ALB
resource "aws_subnet" "public_web_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_prefix}-public-web-subnet-b"
    Tier = "Web"
  }
}

# App Tier (Private)
resource "aws_subnet" "private_app" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.project_prefix}-private-app-subnet"
    Tier = "App"
  }
}

# Database Tier (Isolated)
resource "aws_subnet" "private_db_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.project_prefix}-private-db-subnet-a"
    Tier = "Database"
  }
}
# Another subnet (for high availability)
resource "aws_subnet" "private_db_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${var.project_prefix}-private-db-subnet-b"
    Tier = "Database"
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name        = "${var.project_prefix}-db-subnet-group"
  subnet_ids  = [aws_subnet.private_db_a.id, aws_subnet.private_db_b.id]
  description = "Isolated database subnets across multiple AZs"

  tags = {
    Name = "${var.project_prefix}-db-subnet-group"
  }
}