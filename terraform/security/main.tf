# =========================================================
# 1. BASE SECURITY GROUPS
# =========================================================

resource "aws_security_group" "alb" {
  name        = "${var.project_prefix}-alb-sg"
  description = "Public ALB security group"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.project_prefix}-alb-sg", Tier = "ALB" }
}

resource "aws_security_group" "web" {
  name        = "${var.project_prefix}-web-sg"
  description = "Security group for Web tier EC2"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.project_prefix}-web-sg", Tier = "Web" }
}

resource "aws_security_group" "app" {
  name        = "${var.project_prefix}-app-sg"
  description = "Security group for App tier EC2"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.project_prefix}-app-sg", Tier = "App" }
}

resource "aws_security_group" "db" {
  name        = "${var.project_prefix}-db-sg"
  description = "Security group for RDS Database"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.project_prefix}-db-sg", Tier = "Database" }
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.project_prefix}-endpoints-sg"
  description = "Security group for private AWS VPC interface endpoints"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.project_prefix}-endpoints-sg", Tier = "Security" }
}

# =========================================================
# 2. ALB RULES (Internet Ingress -> Forward to Web)
# =========================================================

resource "aws_vpc_security_group_ingress_rule" "alb_http_in" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow public inbound HTTP"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# We'll not use HTTPs for the dev environment (we'll keep it for production)
resource "aws_vpc_security_group_ingress_rule" "alb_https_in" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow public inbound HTTPs"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_web" {
  security_group_id            = aws_security_group.alb.id
  description                  = "Forward traffic to Web EC2 on port 80"
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

# =========================================================
# 3. WEB TIER RULES (ALB Ingress Only)
# =========================================================

resource "aws_vpc_security_group_ingress_rule" "web_from_alb" {
  security_group_id            = aws_security_group.web.id
  description                  = "Allow inbound HTTP exclusively from ALB"
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "web_to_app" {
  security_group_id            = aws_security_group.web.id
  description                  = "Allow outbound to App tier on port 3000"
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 3000
  to_port                      = 3000
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "web_https_out" {
  security_group_id = aws_security_group.web.id
  description       = "Allow outbound HTTPS for AWS Systems Manager and package updates"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}



# =========================================================
# 4. APP TIER RULES
# =========================================================

resource "aws_vpc_security_group_ingress_rule" "app_from_web" {
  security_group_id            = aws_security_group.app.id
  description                  = "Allow inbound on port 3000 exclusively from Web SG"
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 3000
  to_port                      = 3000
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_to_db" {
  security_group_id            = aws_security_group.app.id
  description                  = "Allow outbound PostgreSQL to DB SG"
  referenced_security_group_id = aws_security_group.db.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_to_endpoints" {
  security_group_id            = aws_security_group.app.id
  description                  = "Allow outbound HTTPS to VPC Endpoints (Secrets Manager/KMS/SSM)"
  referenced_security_group_id = aws_security_group.vpc_endpoints.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_outbound_https" {
  security_group_id = aws_security_group.app.id
  description       = "Allow outbound HTTPS for S3 Gateway and AWS APIs"
  cidr_ipv4         = "0.0.0.0/0" 
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}


# =========================================================
# 5. DATABASE TIER RULES
# =========================================================

resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  description                  = "Allow inbound PostgreSQL exclusively from App tier"
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

# =========================================================
# 6. VPC ENDPOINT RULES
# =========================================================

resource "aws_vpc_security_group_ingress_rule" "endpoints_from_app" {
  security_group_id            = aws_security_group.vpc_endpoints.id
  description                  = "Allow HTTPS from App instances to AWS internal endpoints"
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "endpoints_from_web" {
  security_group_id            = aws_security_group.vpc_endpoints.id
  description                  = "Allow HTTPS from Web instances to AWS internal endpoints"
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
