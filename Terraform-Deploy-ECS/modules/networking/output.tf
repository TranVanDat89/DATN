output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "rds_subnet_group_name" {
  value = aws_db_subnet_group.rds_subnet_group.name
}