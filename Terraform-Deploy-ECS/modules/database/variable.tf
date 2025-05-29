variable "vpc_id" {
  type = string
  description = "The VPC ID"
  nullable = false
  
}

variable "db_subnets" {
  type = list(string)
  description = "The Subnet Group that deploy RDS"
  nullable = false
}

variable "db_identifier" {
  description = "Identifier for the RDS instance"
  type        = string
  default     = "final-assignment-rds-mysql"
}

variable "db_allocated_storage" {
  description = "Allocated storage (in GB)"
  type        = number
  default     = 20
}

variable "db_storage_type" {
  description = "Storage type (e.g., gp2, io1)"
  type        = string
  default     = "gp2"
}

variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Engine version"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "Instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "ecommerce_app"
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 3306
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
}

variable "db_publicly_accessible" {
  description = "Whether the DB is publicly accessible"
  type        = bool
  default     = true
}

variable "db_skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = true
}

variable "db_backup_retention_period" {
  description = "Backup retention period (in days)"
  type        = number
  default     = 7
}

variable "db_backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "03:00-06:00"
}

variable "db_maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "Mon:00:00-Mon:03:00"
}

variable "db_multi_az" {
  description = "Enable Multi-AZ deployments"
  type        = bool
  default     = false
}

variable "db_subnet_group_name" {
  description = "Subnet group name for the RDS instance"
  type        = string
}

variable "db_security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "db_tags" {
  description = "Tags to assign to the RDS instance"
  type        = map(string)
  default     = {
    Name = "RDS Database"
  }
}

variable "parameter_group" {
  description = "RDS parameter group configuration"
  type = object({
    name    = string
    family  = string
    parameters = list(object({
      name  = string
      value = string
    }))
  })
  
  default = {
    name    = "rds-parameter-group"
    family  = "mysql8.0"
    parameters = [
      {
        name  = "character_set_server"
        value = "utf8"
      },
      {
        name  = "character_set_client"
        value = "utf8"
      }
    ]
  }
}

variable "secrets" {
  description = "AWS Secrets Manager configuration"
  type = object({
    password_secret_name = string
    connection_string_secret_name = string
  })
}