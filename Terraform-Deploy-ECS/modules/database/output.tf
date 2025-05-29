# Output the RDS endpoint
output "rds_endpoint" {
  value = aws_db_instance.rds_instance.endpoint
  description = "The connection endpoint for the RDS instance"
}

output "rds_connection_string_secret_arn" {
  value = aws_secretsmanager_secret.rds_connection_string.arn
  description = "The ARN of the secret storing the database connection string"
}

output "rds_password_secret_arn" {
  value = aws_secretsmanager_secret.rds_password_secret.arn
  description = "The ARN of the secret storing the database password"
}

output "rds_port" {
  value = aws_db_instance.rds_instance.port
  description = "The port on which the database accepts connections"
}

output "rds_name" {
  value = aws_db_instance.rds_instance.db_name
  description = "The database name"
}

output "rds_username" {
  value = aws_db_instance.rds_instance.username
  description = "The master username for the database"
}

output "password_secret_name" {
   value = aws_secretsmanager_secret.rds_password_secret.name
}