resource "random_id" "random_id_prefix" {
  byte_length = 2
}
/*====
Variables used across all modules
======*/
locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
}

module "networking" {
  source = "./modules/networking"

  region               = "${var.region}"
  environment          = "${var.environment}"
  vpc_cidr             = "${var.vpc_cidr}"
  public_subnets_cidr  = "${var.public_subnets_cidr}"
  private_subnets_cidr = "${var.private_subnets_cidr}"
  availability_zones   = "${local.production_availability_zones}"
}

# module "ekscluster" {
#   source = "./modules/ekscluster"

#   region               = "${var.region}"
#   environment          = "${var.environment}"
#   vpc_cidr             = "${var.vpc_cidr}"
#   public_subnets_cidr  = "${var.public_subnets_cidr}"
#   private_subnets_cidr = "${var.private_subnets_cidr}"
#   availability_zones   = "${local.production_availability_zones}"
#   eks_cluster_name     = "${var.eks_cluster_name}"
#   ecr_repository_name  = "${var.ecr_repository_name}"
#   private_subnets_id   = "${module.networking.private_subnets_id}"
#   vpc_id               = "${module.networking.vpc_id}"
# }

module "database" {
  source = "./modules/database"

  region               = "${var.region}"
  environment          = "${var.environment}"
  vpc_cidr             = "${var.vpc_cidr}"
  public_subnets_cidr  = "${var.public_subnets_cidr}"
  private_subnets_cidr = "${var.private_subnets_cidr}"
  availability_zones   = "${local.production_availability_zones}"
  eks_cluster_name     = "${var.eks_cluster_name}"
  ecr_repository_name  = "${var.ecr_repository_name}"
  private_subnets_id   = "${module.networking.private_subnets_id}"
  db_instance_password = "${var.db_instance_password}"
  db_instance_username = "${var.db_instance_username}"
  db_instance_identifier = "${var.db_instance_identifier}"
  aws_secretsmanager_arn  = "${module.secretsmanagersecret.secretsmanager_arn}"    
  aws_kms_key_arn   = "${module.secretsmanagersecret.aws_kms_key_arn}" 
  vpc_id            = "${module.networking.vpc_id}"

  depends_on = [ module.secretsmanagersecret ]
}

# module "cloudfront" {
#   source = "./modules/cloudfront"
#   aws_s3_bucket_cloudfront_name = "${var.aws_s3_bucket_cloudfront_name}"
# }

# module "simpleemailservice" {
#   source = "./modules/ses"
#   aws_ses_email_identity_email  = var.aws_ses_email_identity_email
#   aws_iam_user_name             = var.aws_iam_user_name
# }

module "secretsmanagersecret" {
  source = "./modules/sm" 
  aws_secretsmanager_db_username = var.aws_secretsmanager_db_username
  aws_secretsmanager_db_password = var.aws_secretsmanager_db_password
  
}