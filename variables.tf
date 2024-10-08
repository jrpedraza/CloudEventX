variable "region" {
  description = "us-east-1"
}

variable "environment" {
  description = "The Deployment environment"
}

//Networking
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

variable "eks_cluster_name" {
  description = "EKS Cluster"
}

variable "ecr_repository_name" {
  description = "Repository Name"
}

variable "db_instance_identifier" {
  description = "The identifier for the RDS MySQL database instance."
}

variable "db_instance_username" {
  description = "The username for the RDS MySQL database."
}

variable "db_instance_password" {
  description = "The password for the RDS MySQL database."
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