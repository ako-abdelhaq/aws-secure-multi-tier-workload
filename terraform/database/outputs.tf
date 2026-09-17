output "db_endpoint" {
  description = "The connection endpoint for the PostgreSQL database."
  value       = aws_db_instance.main.endpoint
}

output "db_name" {
  description = "The name of the initial database created."
  value       = aws_db_instance.main.db_name
}

output "db_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing the DB credentials."
  # AWS returns this as a list, so we extract the first [0] element
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}
