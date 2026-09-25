# Pass the current regoin to the Node SDK
data "aws_region" "current" {}

# Fetch the latest Amazon Linux 2023 ARM64 AMI
data "aws_ami" "al2023_arm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-arm64"]
  }
}

# Fetch the latest Amazon Linux 2023 x86_64 AMI
data "aws_ami" "amazon_linux_x86" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Web EC2 (Public Subnet)
resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux_x86.id
  instance_type               = "t4g.micro" #You can also use t4g.micro
  subnet_id                   = var.public_web_subnet_id
  vpc_security_group_ids      = [var.web_sg_id]
  iam_instance_profile        = aws_iam_instance_profile.web_profile.name
  associate_public_ip_address = true

  #user_data = file("${path.module}/user_data/web.sh")
  user_data = templatefile("${path.module}/user_data/web.sh", {
    internal_alb_dns = var.alb_dns_name  # Ensure this points to your actual ALB resource
  })

  user_data_replace_on_change = true

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8
  }

  lifecycle {
    ignore_changes = [
      ami # Tells Terraform: "Even if a newer AMI exists, do not destroy my running app to upgrade it!"
    ]
  }

  tags = { Name = "${var.project_prefix}-web-ec2", Tier = "Web" }
}

# App EC2 (Private Subnet)
resource "aws_instance" "app" {
  ami                         = data.aws_ami.amazon_linux_x86.id
  instance_type               = "t4g.micro"
  subnet_id                   = var.private_app_subnet_id
  vpc_security_group_ids      = [var.app_sg_id]
  iam_instance_profile        = aws_iam_instance_profile.app_profile.name
  associate_public_ip_address = false

  user_data = templatefile("${path.module}/user_data/node-app.sh" , {
    aws_region      = data.aws_region.current.name
    db_name         = var.db_name
    db_host         = split(":", var.db_host)[0]
    db_secret_arn   = var.db_secret_arn
    artifact_bucket = aws_s3_bucket.artifacts.id
  })

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8
  }

  lifecycle {
    ignore_changes = [
      ami # Tells Terraform: "Even if a newer AMI exists, do not destroy my running app to upgrade it!"
    ]
  }

  tags = { Name = "${var.project_prefix}-app-ec2", Tier = "App" }
}

# ALB Target Group Attachment
resource "aws_lb_target_group_attachment" "web_attachment" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.web.id
  port             = 80
}
