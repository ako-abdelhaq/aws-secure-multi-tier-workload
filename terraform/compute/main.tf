# Fetch the latest Amazon Linux 2023 ARM64 AMI
data "aws_ami" "al2023_arm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-arm64"]
  }
}

# Pass the current regoin to the Node SDK
data "aws_region" "current" {}

# Web EC2 (Public Subnet)
resource "aws_instance" "web" {
  ami                         = data.aws_ami.al2023_arm.id
  instance_type               = "t4g.micro"
  subnet_id                   = var.public_web_subnet_id
  vpc_security_group_ids      = [var.web_sg_id]
  iam_instance_profile        = aws_iam_instance_profile.web_profile.name
  associate_public_ip_address = true

  user_data = file("${path.module}/user_data/web.sh")

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8
  }

  tags = { Name = "${var.project_prefix}-web-ec2", Tier = "Web" }
}

# App EC2 (Private Subnet)
resource "aws_instance" "app" {
  ami                         = data.aws_ami.al2023_arm.id
  instance_type               = "t4g.micro"
  subnet_id                   = var.private_app_subnet_id
  vpc_security_group_ids      = [var.app_sg_id]
  iam_instance_profile        = aws_iam_instance_profile.app_profile.name
  associate_public_ip_address = false

  user_data = templatefile("${path.module}/user_data/node-app.sh" , {
    aws_region      = data.aws_region.current.name
    db_name         = var.db_name
    db_host         = split(":", var.db_host)[0]
    db_user         = var.db_username
    db_secret_arn   = var.db_secret_arn
    artifact_bucket = aws_s3_bucket.artifacts.id
  })

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8
  }

  tags = { Name = "${var.project_prefix}-app-ec2", Tier = "App" }
}

# =========================================================
# 3. ALB Target Group Attachment
# =========================================================
resource "aws_lb_target_group_attachment" "web_attachment" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.web.id
  port             = 80
}
