resource "aws_db_instance" "main" {
  identifier = "${var.project_prefix}-db"

  # Engine settings
  engine         = "postgres"
  engine_version = "16.9" 
  instance_class = "db.t3.micro"   # Or use t3.micro

  # Storage settings
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  # Database settings
  db_name  = "main_db"
  username = var.db_username
  
  # Manage passwords with AWS secret manager
  manage_master_user_password = true   # Use RDS managed password
  master_user_secret_kms_key_id = var.key_arn # Use CMK to encrypt credentials instead of AWS managed key

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

resource "aws_secretsmanager_secret_rotation" "db_password_rotation" {
  secret_id = aws_db_instance.main.master_user_secret[0].secret_arn

  rotation_rules {
    automatically_after_days = 30 # Change the duration here (e.g., every 30 days)
  }
}