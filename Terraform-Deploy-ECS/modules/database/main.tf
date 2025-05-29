# Create a secret for Database
resource "random_password" "secret_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "rds_password_secret" {
  name = var.secrets.password_secret_name
}

resource "aws_secretsmanager_secret_version" "rds_password_secret_version" {
  secret_id     = aws_secretsmanager_secret.rds_password_secret.id
  secret_string = random_password.secret_password.result
}

# Create DB parameter group
resource "aws_db_parameter_group" "rds_parameter_group" {
  name   = var.parameter_group.name
  family = var.parameter_group.family
  
  dynamic "parameter" {
    for_each = var.parameter_group.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
  
  tags = {
    Name = "RDS Parameter Group"
  }
}

# Create RDS instance
resource "aws_db_instance" "rds_instance" {
  identifier              = var.db_identifier
  allocated_storage       = var.db_allocated_storage
  storage_type            = var.db_storage_type
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  db_name                 = var.db_name
  port                    = var.db_port
  username                = var.db_username
  password                = aws_secretsmanager_secret_version.rds_password_secret_version.secret_string
  parameter_group_name    = aws_db_parameter_group.rds_parameter_group.name
  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = var.db_security_group_ids
  publicly_accessible     = var.db_publicly_accessible
  skip_final_snapshot     = var.db_skip_final_snapshot
  backup_retention_period = var.db_backup_retention_period
  backup_window           = var.db_backup_window
  maintenance_window      = var.db_maintenance_window
  multi_az                = var.db_multi_az

  tags = var.db_tags
}


# Create a secret for the connection string
resource "aws_secretsmanager_secret" "rds_connection_string" {
  name = var.secrets.connection_string_secret_name
}

resource "aws_secretsmanager_secret_version" "rds_connection_string_version" {
  secret_id     = aws_secretsmanager_secret.rds_connection_string.id
  secret_string = "jdbc:mysql://${aws_db_instance.rds_instance.endpoint}/${aws_db_instance.rds_instance.db_name}"
}

