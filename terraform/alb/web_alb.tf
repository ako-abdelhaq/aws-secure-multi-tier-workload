# The main web ALB
resource "aws_lb" "web" {
  name               = "${var.project_prefix}-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.web_alb_sg_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_prefix}-web-alb"
  }
}

# The target group of web ALB
resource "aws_lb_target_group" "web" {
  name        = "${var.project_prefix}-web-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/health"
    port                = "80"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_prefix}-web-tg"
  }
}

# Attach the EC2 instances to the Target Group
resource "aws_lb_target_group_attachment" "web" {
  count            = length(var.web_instance_ids)
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = var.web_instance_ids[count.index]
  port             = 80
}

# HTTP listener
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}