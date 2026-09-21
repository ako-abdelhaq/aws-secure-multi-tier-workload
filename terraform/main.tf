module "network" {
  source = "./network"

  project_prefix     = var.project_prefix
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}

module "security" {
  source = "./security"

  project_prefix = var.project_prefix
  vpc_id         = module.network.vpc_id
}

module "alb" {
  source = "./alb"

  project_prefix    = var.project_prefix
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
}

module "vpc-endpoints" {
  source = "./vpc-endpoints"

  project_prefix         = var.project_prefix
  vpc_id                 = module.network.vpc_id
  private_app_subnet_id  = module.network.private_app_subnet_id
  vpc_endpoints_sg_id    = module.security.vpc_endpoints_sg_id
  private_route_table_id = module.network.private_route_table_id # Passed for S3 Gateway
}

module "database" {
  source = "./database"

  project_prefix       = var.project_prefix
  db_subnet_group_name = module.network.db_subnet_group_name
  db_sg_id             = module.security.db_sg_id
  
  db_username          = var.db_username
  key_arn              = module.compute.key_arn
}

module "compute" {
  source = "./compute"

  project_prefix        = var.project_prefix
  vpc_id                = module.network.vpc_id
  public_web_subnet_id  = module.network.public_web_subnet_a_id
  private_app_subnet_id = module.network.private_app_subnet_id
  web_sg_id             = module.security.web_sg_id
  app_sg_id             = module.security.app_sg_id
  db_secret_arn         = module.database.db_secret_arn
  target_group_arn      = module.alb.target_group_arn
  alb_dns_name          = module.alb.alb_dns_name

  db_host               = split(":", module.database.db_endpoint)[0]
  db_username           = var.db_username
  db_name               = module.database.db_name
  

  depends_on = [
    module.vpc-endpoints
  ]

}

module "log-bucket" {
  source = "./log-bucket"

  project_prefix = var.project_prefix
}

module "cloudtrail" {
  source = "./cloudtrail"

  project_prefix        = var.project_prefix
  logging_bucket_name   = module.log-bucket.logging_bucket_name
  logging_bucket_policy = module.log-bucket.logging_bucket_policy
}

module "guardduty" {
  source = "./guardduty"

  project_prefix        = var.project_prefix
}

module "securityhub" {
  source = "./security-hub"

  project_prefix = var.project_prefix
}

module "config" {
  source = "./config"
  project_prefix = var.project_prefix
  logging_bucket_name = module.log-bucket.logging_bucket_name
}