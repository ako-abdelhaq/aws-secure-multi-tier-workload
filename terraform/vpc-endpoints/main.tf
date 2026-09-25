# Dynamically fetch the current AWS region
data "aws_region" "current" {}

# SSM----------------------------------------------------------------------------

# SSM endpoint
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.private_app_subnet_id]
  security_group_ids  = [var.vpc_endpoints_sg_id]
  private_dns_enabled = true

  tags = { Name = "${var.project_prefix}-vpce-ssm" }
}

# SSM messages 
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.private_app_subnet_id]
  security_group_ids  = [var.vpc_endpoints_sg_id]
  private_dns_enabled = true

  tags = { Name = "${var.project_prefix}-vpce-ssmmessages" }
}

# EC2 messages
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.private_app_subnet_id]
  security_group_ids  = [var.vpc_endpoints_sg_id]
  private_dns_enabled = true

  tags = { Name = "${var.project_prefix}-vpce-ec2messages" }
}

# Credentials and encryption-----------------------------------------------------------------------------

# Secrets manager endpoint
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.private_app_subnet_id]
  security_group_ids  = [var.vpc_endpoints_sg_id]
  private_dns_enabled = true

  tags = { Name = "${var.project_prefix}-vpce-secretsmanager" }
}

# KMS endpoint
resource "aws_vpc_endpoint" "kms" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.kms"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.private_app_subnet_id]
  security_group_ids  = [var.vpc_endpoints_sg_id]
  private_dns_enabled = true

  tags = { Name = "${var.project_prefix}-vpce-kms" }
}

# Storage-----------------------------------------------------------------------------

# S3 endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [var.private_route_table_id]

  tags = {
    Name = "${var.project_prefix}-vpce-s3-gateway"
  }
}
