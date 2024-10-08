/*====
The EKS
======*/

# Create an EKS cluster
resource "aws_eks_cluster" "my_eks_cluster" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = flatten(var.private_subnets_id)
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
}

# K8s Provider configuration 
provider "kubernetes" {
  host                   = aws_eks_cluster.my_eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.my_eks_cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.my_eks_cluster.name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.my_eks_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.my_eks_cluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
      command     = "aws"
    }
  }
}

# Create an IAM role for EKS cluster
resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policies to the IAM role for EKS cluster
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# Create an Elastic Container Registry (ECR)
resource "aws_ecr_repository" "my_ecr_repository" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "IMMUTABLE"
}

# Create EKS node group
resource "aws_iam_role" "NodeGroupRole" {
  name = "EKSNodeGroupRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

// ATTACH MANAGED IAM POLICIES TO IAM ROLES
data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.NodeGroupRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.NodeGroupRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.NodeGroupRole.name
}

resource "aws_eks_node_group" "my_eks_node_group" {
  cluster_name    = aws_eks_cluster.my_eks_cluster.name
  node_group_name = "my-node-group"
  node_role_arn   = aws_iam_role.NodeGroupRole.arn
  subnet_ids      = flatten(var.private_subnets_id)
  ami_type        = var.eks_node.ami_type
  instance_types  = var.eks_node.instance_types
  capacity_type   = var.eks_node.capacity_type
  disk_size       = var.eks_node.disk_size

  scaling_config {
    desired_size = var.node_scaling_config.desired_size
    max_size     = var.node_scaling_config.max_size
    min_size     = var.node_scaling_config.min_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy
  ]

  # AWS Node Group Tags
  tags = {
    Name = "my-eks-node-group"
  }
}

# Adding the Load Balancer Controller

# Crear el proveedor OIDC en IAM
resource "aws_iam_openid_connect_provider" "my_aws_iam_openid_connect_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b0d5af3c095d1e66e"]  # Este es el thumbprint para los clusters de AWS
  url             = aws_eks_cluster.my_eks_cluster.identity[0].oidc[0].issuer
}

# Crear el documento de política para permitir que el OIDC provider asuma el rol
data "aws_iam_policy_document" "lb_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.my_aws_iam_openid_connect_provider.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.my_eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

# Crear el rol de IAM for LB Controller
resource "aws_iam_role" "lb_controller_role" {
  name               = "eks-lb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.lb_controller_assume_role_policy.json
}

# Adjuntar políticas necesarias al rol
resource "aws_iam_role_policy_attachment" "lb_controller_policy_attachment" {
  role       = aws_iam_role.lb_controller_role.name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/AWSLoadBalancerControllerIAMPolicy"
}

resource "kubernetes_service_account" "service-account" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }

    annotations = {
      "eks.amazonaws.com/role-arn"               = aws_iam_role.lb_controller_role.arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }

  depends_on = [ aws_eks_cluster.my_eks_cluster ]
}

resource "helm_release" "alb-controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  depends_on = [
    kubernetes_service_account.service-account
  ]

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.${var.region}.amazonaws.com/amazon/aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "clusterName"
    value = var.eks_cluster_name
  }
}

# create an access entry for the root account
# data "aws_caller_identity" "current" {}

resource "aws_eks_access_entry" "root_access" {
  cluster_name  = aws_eks_cluster.my_eks_cluster.name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "root_access_policy" {
  cluster_name  = aws_eks_cluster.my_eks_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"  
  access_scope {
    type = "cluster"
  }
}

# # Desployment de App
# # k8s namespace
# resource "kubernetes_namespace" "sample-application-namespace" {
#   metadata {
#     annotations = {
#       name = "sample-application"
#     }

#     labels = {
#       application = "sample-nginx-application"
#     }

#     name = "sample-application"
#   }
# }

# # Policy para la app
# module "sample_application_iam_policy" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-policy"

#   name        = "${var.environment}_sample_application_policy"
#   path        = "/"
#   description = "Sample Application Policy"

#   policy = <<EOF
#  {
#  "Version": "2012-10-17",
#  "Statement": [
#      {
#      "Action": [
#          "ec2:Describe*"
#      ],
#      "Effect": "Allow",
#      "Resource": "*"
#      }
#  ]
#  }
#  EOF
# }

# # Rol para la App

# # Usamos el data source aws_caller_identity

# module "sample_application_role" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

#   role_name = "${var.environment}_sample_application"
#   role_policy_arns = {
#     policy = module.sample_application_iam_policy.arn
#   }

#   oidc_providers = {
#     main = {
#       provider_arn               = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.my_eks_cluster.identity[0].oidc[0].issuer, "https://", "")}"
#       namespace_service_accounts = ["sample-application:sample-application-sa"]
#     }
#   }

#   depends_on = [ aws_eks_cluster.my_eks_cluster ]
# }

# # Cuenta de servicio para la App
# resource "kubernetes_service_account" "service-account-app" {
#   metadata {
#     name      = "sample-application-sa"
#     namespace = kubernetes_namespace.sample-application-namespace.metadata[0].name
#     labels = {
#       "app.kubernetes.io/name" = "sample-application-sa"
#     }
#     annotations = {
#       "eks.amazonaws.com/role-arn"               = module.sample_application_role.iam_role_arn
#       "eks.amazonaws.com/sts-regional-endpoints" = "true"
#     }
#   }
# }

# # Despliegue de la App
# resource "kubernetes_deployment_v1" "sample_application_deployment" {
#   metadata {
#     name      = "sample-application-deployment"
#     namespace = kubernetes_namespace.sample-application-namespace.metadata[0].name
#     labels = {
#       app = "nginx"
#     }
#   }

#   spec {
#     replicas = 2

#     selector {
#       match_labels = {
#         app = "nginx"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           app = "nginx"
#         }
#       }

#       spec {
#         service_account_name = kubernetes_service_account.service-account-app.metadata[0].name
#         container {
#           image = "nginx:1.21.6"
#           name  = "nginx"

#           resources {
#             limits = {
#               cpu    = "0.5"
#               memory = "512Mi"
#             }
#             requests = {
#               cpu    = "250m"
#               memory = "50Mi"
#             }
#           }

#           liveness_probe {
#             http_get {
#               path = "/"
#               port = 80

#               http_header {
#                 name  = "X-Custom-Header"
#                 value = "Awesome"
#               }
#             }

#             initial_delay_seconds = 3
#             period_seconds        = 3
#           }
#         }
#       }
#     }
#   }
# }

# # Servicio de la App
# resource "kubernetes_service_v1" "sample_application_svc" {
#   metadata {
#     name      = "sample-application-svc"
#     namespace = kubernetes_namespace.sample-application-namespace.metadata[0].name
#   }
#   spec {
#     selector = {
#       app = "nginx"
#     }
#     session_affinity = "ClientIP"
#     port {
#       port        = 80
#       target_port = 80
#     }

#     type = "NodePort"
#   }
# }

# # Ingress de la App
# resource "kubernetes_ingress_v1" "sample_application_ingress" {
#   metadata {
#     name      = "sample-application-ingress"
#     namespace = kubernetes_namespace.sample-application-namespace.metadata[0].name
#     annotations = {
#       "kubernetes.io/ingress.class" = "alb"
#       "alb.ingress.kubernetes.io/scheme" = "internal"
#     }
#   }

#   wait_for_load_balancer = "true"

#   spec {
#     ingress_class_name = "alb"
#     default_backend {
#       service {
#         name = "sample-application-svc"
#         port {
#           number = 80
#         }
#       }
#     }

#     rule {
#       http {
#         path {
#           backend {
#             service {
#               name = "sample-application-svc"
#               port {
#                 number = 80
#               }
#             }
#           }

#           path = "/app1/*"
#         }

#       }
#     }

#     tls {
#       secret_name = "tls-secret"
#     }
#   }
# }
