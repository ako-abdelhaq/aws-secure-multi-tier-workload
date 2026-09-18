resource "aws_db_instance" "main" {
  identifier = "${var.project_prefix}-db"

  # Engine settings
  engine         = "postgres"
  engine_version = "16.9" 
  instance_class = "db.t4g.micro"

  # Storage settings
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  # Database settings
  db_name  = "main_db"
  username = var.db_username
  
  # Manage passwords with AWS secret manager
  manage_master_user_password = true

  # Network & Security boundaries
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.db_sg_id]

  # Isolation & Cost Control
  multi_az            = false # Cost control
  publicly_accessible = false # No public IP is assigned 
  skip_final_snapshot = true # Used for clean 'terraform destroy'

  tags = {
    Name = "${var.project_prefix}-db"
    Tier = "Database"
  }
}