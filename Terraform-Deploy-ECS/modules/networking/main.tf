module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "final-assignment-vpc"
  cidr = var.cidr_block

  azs             = var.availability_zones
  public_subnets  = var.public_subnet_ips
  private_subnets = var.private_subnet_ips

  enable_nat_gateway = true
  enable_vpn_gateway = false
  single_nat_gateway = true
  tags = {
    Name = "Final Assignment VPC"
  }
}

# Tạo subnet group cho RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "final-assignment-rds-subnet-group"
  subnet_ids = module.vpc.private_subnets
  tags = {
    Name = "RDS Subnet Group"
  }
}