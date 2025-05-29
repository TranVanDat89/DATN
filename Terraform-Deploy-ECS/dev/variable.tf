variable "region" {
  type = string
  default = "ap-southeast-2"
}

#parameters for networking module
variable "availability_zones" {
  type = list(string)
  nullable = false
}
variable "cidr_block" {
  type = string
  nullable = false
}
variable "public_subnet_ips" {
  type = list(string)
  nullable = false
  
}
variable "private_subnet_ips" {
  type = list(string)
  nullable = false
}

variable "db_username" {
  type = string
  description = "Admin Username for the database"
  nullable = false
  default = "admin"
}

variable "password_secret_name" {
  type = string
  default = "rds_password_secret"
}

variable "connection_string_secret_name" {
  type = string
  default = "rds_connection_string"
}

variable "frontend_ecr_repo_url" {
  type = string
  description = "The URI of the ECR repository for the Frontend application"
  nullable = false
}
variable "backend_ecr_repo_url" {
  type = string
  description = "The URI of the ECR repository for the Backend application"
  nullable = false
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "my-ecommerce-app"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "webapp"
    ManagedBy   = "terraform"
  }
}

variable "create_www_record" {
  description = "Create www subdomain record"
  type        = bool
  default     = true
}

variable "route53_zone_id" {
  type = string
  nullable = false
}

variable "bucket_name" {
  type = string
  nullable = false
}