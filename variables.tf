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

# variable "vpc_id" {
#   description = "The VPC ID"
# }

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

// cloudfront 
variable "aws_s3_bucket_cloudfront_name" {
  description = "The bucket for delivery content from cloudfront"
}

// SES
variable "aws_ses_email_identity_email" {
  description = "ses email identity email"
}

variable "aws_iam_user_name" {
  description = "iam user for sending emails"
}

// SMS Secrets Manager Secret
variable "aws_secretsmanager_db_username" {
  type        = string
  description = "Database username"
}

variable "aws_secretsmanager_db_password" {
  type        = string
  description = "Database password"
  sensitive   = true
}

# variable "aws_secretsmanager_arn"{
#   description = "The AWS Secrets Manager secret that contains the database credentials."
# }

# variable "aws_kms_key_arn" {
#   description = "The AWS KMS key used to encrypt the database credentials."
# }