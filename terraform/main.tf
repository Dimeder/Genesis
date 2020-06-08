provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "dimeder"
    key    = "terraform/sentry.tfstate"
    region = "us-east-1"
  }
}

module "VPC" {
  source = "./modules/VPC"
}

module "RDS" {
  source             = "./modules/RDS"
  private-a          = module.VPC.private-a
  private-b          = module.VPC.private-b
  redis-sg           = module.VPC.redis
  db-sg              = module.VPC.db
  SENTRY_DB_NAME     = var.SENTRY_DB_NAME
  SENTRY_DB_USER     = var.SENTRY_DB_USER
  SENTRY_DB_PASSWORD = var.SENTRY_DB_PASSWORD
}

module "LoadBalancers" {
  source    = "./modules/LoadBalancers"
  public-a  = module.VPC.public-a
  public-b  = module.VPC.public-b
  sentry-sg = module.VPC.alb-sg
  vps_id    = module.VPC.vps_id
}

// module "IAM" {
//   source = "./modules/IAM"

// }
module "ECS" {
  source = "./modules/ECS"
  // aws_iam_role = module.IAM.ecs_role
  private-a = module.VPC.private-a
  private-b = module.VPC.private-b
  ecs-sg        = module.VPC.ecs
  sentry-tg = module.LoadBalancers.sentry-tg
  SENTRY_REDIS_HOST = module.RDS.redis-node
  SENTRY_POSTGRES_HOST = module.RDS.postgres-db

}



