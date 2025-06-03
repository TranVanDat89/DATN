output "rds_password_secret_arn" {
  value = module.database.rds_password_secret_arn
}

output "rds_endpoint" {
  value = module.database.rds_endpoint
}

output "rds_connection_string_secret_arn" {
  value = module.database.rds_connection_string_secret_arn
}

output "instance_ip_addr_public" {
  value = module.bastion.instance_ip_addr_public
}