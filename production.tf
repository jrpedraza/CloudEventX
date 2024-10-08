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

module "ekscluster" {
  source = "./modules/ekscluster"

  region               = "${var.region}"
  environment          = "${var.environment}"
  vpc_cidr             = "${var.vpc_cidr}"
  public_subnets_cidr  = "${var.public_subnets_cidr}"
  private_subnets_cidr = "${var.private_subnets_cidr}"
  availability_zones   = "${local.production_availability_zones}"
  eks_cluster_name     = "${var.eks_cluster_name}"
  ecr_repository_name  = "${var.ecr_repository_name}"
  private_subnets_id   = "${module.networking.private_subnets_id}"
  vpc_id               = "${module.networking.vpc_id}"
}

# module "database" {
#   source = "./modules/database"

#   region               = "${var.region}"
#   environment          = "${var.environment}"
#   vpc_cidr             = "${var.vpc_cidr}"
#   public_subnets_cidr  = "${var.public_subnets_cidr}"
#   private_subnets_cidr = "${var.private_subnets_cidr}"
#   availability_zones   = "${local.production_availability_zones}"
#   eks_cluster_name     = "${var.eks_cluster_name}"
#   ecr_repository_name  = "${var.ecr_repository_name}"
#   private_subnets_id   = "${module.networking.private_subnets_id}"
#   db_instance_password = "${var.db_instance_password}"
#   db_instance_username = "${var.db_instance_username}"
#   db_instance_identifier = "${var.db_instance_identifier}"
# }