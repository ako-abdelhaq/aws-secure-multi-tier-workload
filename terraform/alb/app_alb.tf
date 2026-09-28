# The main app ALB
resource "aws_lb" "app" {
  name               = "${var.project_prefix}-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.app_alb_sg_id]
  subnets            = var.private_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_prefix}-app-alb"
  }
}

# The target group of app ALB
resource "aws_lb_target_group" "app" {
  name        = "${var.project_prefix}-app-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/health"
    port                = var.app_port
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_prefix}-app-tg"
  }
}

# Attach the app EC2 instances to the app Target Group
resource "aws_lb_target_group_attachment" "app" {
  count            = length(var.app_instance_ids)
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = var.app_instance_ids[count.index]
  port             = var.app_port
}

# HTTP listener
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}