# Fetch the latest Amazon Linux 2023 ARM64 AMI
data "aws_ami" "al2023_arm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-arm64"]
  }
}

# Web EC2 (Public Subnet)
resource "aws_instance" "web" {
  ami                         = data.aws_ami.al2023_arm.id
  instance_type               = "t4g.micro"
  subnet_id                   = var.public_web_subnet_id
  vpc_security_group_ids      = [var.web_sg_id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true

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
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = false

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
