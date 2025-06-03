terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "networking" {
  source = "../modules/networking"
  availability_zones  = var.availability_zones
  cidr_block          = var.cidr_block
  public_subnet_ips   = var.public_subnet_ips
  private_subnet_ips  = var.private_subnet_ips
}

module "security" {
  source = "../modules/security"
  vpc_id = module.networking.vpc_id
}

module "database" {
  source = "../modules/database"
  vpc_id = module.networking.vpc_id
  db_subnets = module.networking.private_subnet_ids
  db_username = var.db_username
  db_subnet_group_name = module.networking.rds_subnet_group_name
  db_security_group_ids = [ module.security.database_security_group_id ]
  secrets = {
    password_secret_name = var.password_secret_name
    connection_string_secret_name = var.connection_string_secret_name
  }
}

# ACM Certificate Module
module "acm" {
  source = "../modules/certificate"
  domain_name = var.domain_name
  zone_id     = var.route53_zone_id
  tags = var.common_tags
}

# Route53 Records
resource "aws_route53_record" "main" {
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.load-balance.alb_dns
    zone_id               = module.load-balance.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  count   = var.create_www_record ? 1 : 0
  zone_id = var.route53_zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = module.load-balance.alb_dns
    zone_id               = module.load-balance.alb_zone_id
    evaluate_target_health = false
  }
}

module "load-balance" {
  source                 = "../modules/load-balancer"
  vpc_id                 = module.networking.vpc_id
  load_balance_subnet_ids = module.networking.public_subnet_ids
  load_balance_security_group_ids = [
    module.security.public_security_group_id
  ]
  certificate_arn = module.acm.certificate_arn
}

module "ecs-cluster" {
  source = "../modules/ecs-cluster"
  vpc_id = module.networking.vpc_id
  rds_connection_string_secret_arn = module.database.rds_connection_string_secret_arn
  alb_dns = module.load-balance.alb_dns
  ecs_security_group_ids = [module.security.private_security_group_id]
  bucket_name = var.bucket_name
  backend_target_group_arn = module.load-balance.backend_target_group_arn
  frontend_target_group_arn = module.load-balance.frontend_target_group_arn
  rds_password_secret_arn = module.database.rds_password_secret_arn
  rds_username = module.database.rds_username
  password_secret_name = var.password_secret_name
  alb_arn = "http://${module.load-balance.alb_dns}:80"
  ecs_subnet_ids = module.networking.private_subnet_ids
  backend_ecr_image_url = var.backend_ecr_repo_url
  frontend_ecr_image_url = var.frontend_ecr_repo_url
  domain_name = var.domain_name
}

module "autoscaling" {
  source = "../modules/autoscaling"
  cluster_name = module.ecs-cluster.cluster_name
  service_name = module.ecs-cluster.be_service_name
}

module "bastion" {
  source = "../modules/bastion"
  subnet_id = module.networking.private_subnet_ids[0]
  security_groups = [module.security.bastion_security_group_id]
}
