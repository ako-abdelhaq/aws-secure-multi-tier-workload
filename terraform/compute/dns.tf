resource "aws_route53_zone" "internal" {
  name = "sec-app.internal"

  vpc {
    vpc_id = var.vpc_id
  }

  tags = { Name = "${var.project_prefix}-private-zone" }
}

resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.internal.zone_id
  name    = "api.sec-app.internal"
  type    = "A"
  ttl     = 60
  records = [aws_instance.app.private_ip]
}