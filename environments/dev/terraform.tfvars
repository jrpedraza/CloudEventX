//AWS 
region      = "us-east-1"
environment = "production"

/* module networking */
vpc_cidr             = "10.0.0.0/16"
public_subnets_cidr  = ["10.0.1.0/24"] //List of Public subnet cidr range
private_subnets_cidr = ["10.0.10.0/24", "10.0.20.0/24"] //List of private subnet cidr range

/* module ekscluster */
eks_cluster_name = "my_eks_cluster"
ecr_repository_name = "my_ecr_repository"

/* module database*/
db_instance_password = "Jrpl1234567890$" # put your password here
db_instance_username = "admin"
db_instance_identifier = "my-db-instance"

eks_node = {
      ami_type        = "AL2_x86_64"
      instance_types  = ["t2.small"]
      capacity_type   = "ON_DEMAND"
      disk_size       = 20
    }

/* module cloudfront */
aws_s3_bucket_cloudfront_name = "cloudeventx-production-v1"

/* simple email service */ 
aws_ses_email_identity_email  = "jrpedraza@hotmail.com"
aws_iam_user_name             = "usr-smtp-send-email"

/* secrets manager secret */
aws_secretsmanager_db_username = "usr-cloudeventx-api"
aws_secretsmanager_db_password = "My$uper$3cur3P4$$w0rd"