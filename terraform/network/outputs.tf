output "vpc_id" {
  description = "The main VPC's ID."
  value       = aws_vpc.main.id
}

output "public_web_subnet_a_id" {
  description = "The ID of the public web subnet a."
  value       = aws_subnet.public_web_a.id
}

output "public_web_subnet_b_id" {
  description = "The ID of the public web subnet b."
  value       = aws_subnet.public_web_b.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs."
  value       = [aws_subnet.public_web_a.id, aws_subnet.public_web_b.id]
}

output "private_app_subnet_id" {
  description = "The ID of the private application subnet."
  value       = aws_subnet.private_app.id
}

output "db_subnet_group_name" {
  description = "The name of the RDS DB subnet group."
  value       = aws_db_subnet_group.main.name
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.main.id
}
