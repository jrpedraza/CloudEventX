variable "environment" {
  description = "The Deployment environment"
}

variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list
  description = "The CIDR block for the private subnet"
}

variable "region" {
  description = "The region to launch the bastion host"
}

variable "availability_zones" {
  type        = list
  description = "The az that the resources will be launched"
}

variable "eks_cluster_name" {
  description = "EKS Cluster"
}

variable "ecr_repository_name" {
  description = "Repository Name"
}

variable "private_subnets_id" {
  description = "Private Subnets Ids"
}

variable "vpc_id" {
  description = "The VPC Id"
}

variable "eks_node" {
  description = "EKS Node"
  type = object ({
    ami_type        = string
    instance_types  = list(string)
    capacity_type   = string
    disk_size       = number
})
  default = {
      ami_type        = "AL2_x86_64"
      instance_types  = ["t3.medium"]
      capacity_type   = "ON_DEMAND"
      disk_size       = 20
    }
}

variable node_scaling_config {
  description = "Node scaling config"
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
  default = {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
}