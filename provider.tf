provider "aws" {
  region = var.region
  //profile = "prashant_appgambit"
}

//TODO: Cambiar host y cluster_ca_certificate
# provider "kubernetes" {
#   host                   = "https://45E5F4920F8C4CFF8FB08A77D7AB1220.gr7.us-east-1.eks.amazonaws.com"
#   cluster_ca_certificate = base64decode("LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJVXh1NVEyT1FsVTh3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TkRFd01ERXhNekUzTlRWYUZ3MHpOREE1TWpreE16SXlOVFZhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURmbzBabVZDcnhlTjdBcnAyYUZnZ0YvZUdXUkFwTkt0YnRYSzUxOTJzZVZYTFIwdERZcTNGTzF4TDkKQzU5dFZWcjd2bDh2LzJlcVgya2hRWlZSbUcxQlQvOS8rRXZVVVI1UXh2K2dwM0s4ZVcvWjA1ckh2Z1lUbXRUQwpBZU9EY1lWK0RiRkh6VXhjeVR6MlBKSGtYL2psRTJNQmhiZ3J0K3Zsa2xuTVNqRkxHcnZPSVRianVjR2hBWGVzClVuZUFvV2FzL1ZHdUpFLy9USkhvK0JITmt6QVpENTZUQkx1N2dwaXdTR2dZYWtkS29YQkhXU1lidiswWVJMRUsKbnlwWjZvOVFwZW4wRW5wS2ZRaXpOcVBwaEM1enJyQjdVRFEvL1JUcGNCK0VGT0cyb01RUmpONk56MkpUeEtnLwpMdHBaR1pyWkt3MXNnbkZ1VCt6SkVQL3ZMcDFCQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTaGY0b3BzUWhlaTQ2cFZXZEFqQ0YzQzVGbnpUQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQjRsUm5xQVlHdwpWWkplMjdkTExsUzJoZHFhR3RydFlycUdqaFg5Tno2clltSGlCQStoODdPakZONVh0NS91UGVlQklzZ0l2dC9MCkN1aDhCQUFWMGFoREhOSUhPdm1zZ3lSRVFtVEJ1REdYcW5LamRTVUlBay9uQ3JUKzJDZGxOSU1OVUE1eHMvbW8KQTM2dWtEYnNWVFlQRFdPc0NCUm1iZmJIWTcyYXZCZzRmUmcvQ3p2Rm9iUUFDa3U3U1lOU2srUmNqT2pJOVcrVQpRRkx5L0ROVWFaMm1xT1JGc1NLWFpWM3JGQmFWd2p5VXVCZDhMcWQ3Q1RjazNRd1h5Y1VVYU45eGNoMHcweU1sCklyd0l1dGpmVW5rbzBDdW13bTJXWVpXRXBsNDM4ZzBZb0s2ekRtQ1UrblpON1ZuaE9vazdHWVo3dEJUbVMzSGEKNlJlZkEwbVR6ZEsxCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K")
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     # This requires the awscli to be installed locally where Terraform is executed
#     args = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
#   }
# }

# //TODO: Cambiar host y cluster_ca_certificate
# provider "helm" {
#   kubernetes {
#     host                   = "https://45E5F4920F8C4CFF8FB08A77D7AB1220.gr7.us-east-1.eks.amazonaws.com"
#     cluster_ca_certificate = base64decode("LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJVXh1NVEyT1FsVTh3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TkRFd01ERXhNekUzTlRWYUZ3MHpOREE1TWpreE16SXlOVFZhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURmbzBabVZDcnhlTjdBcnAyYUZnZ0YvZUdXUkFwTkt0YnRYSzUxOTJzZVZYTFIwdERZcTNGTzF4TDkKQzU5dFZWcjd2bDh2LzJlcVgya2hRWlZSbUcxQlQvOS8rRXZVVVI1UXh2K2dwM0s4ZVcvWjA1ckh2Z1lUbXRUQwpBZU9EY1lWK0RiRkh6VXhjeVR6MlBKSGtYL2psRTJNQmhiZ3J0K3Zsa2xuTVNqRkxHcnZPSVRianVjR2hBWGVzClVuZUFvV2FzL1ZHdUpFLy9USkhvK0JITmt6QVpENTZUQkx1N2dwaXdTR2dZYWtkS29YQkhXU1lidiswWVJMRUsKbnlwWjZvOVFwZW4wRW5wS2ZRaXpOcVBwaEM1enJyQjdVRFEvL1JUcGNCK0VGT0cyb01RUmpONk56MkpUeEtnLwpMdHBaR1pyWkt3MXNnbkZ1VCt6SkVQL3ZMcDFCQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTaGY0b3BzUWhlaTQ2cFZXZEFqQ0YzQzVGbnpUQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQjRsUm5xQVlHdwpWWkplMjdkTExsUzJoZHFhR3RydFlycUdqaFg5Tno2clltSGlCQStoODdPakZONVh0NS91UGVlQklzZ0l2dC9MCkN1aDhCQUFWMGFoREhOSUhPdm1zZ3lSRVFtVEJ1REdYcW5LamRTVUlBay9uQ3JUKzJDZGxOSU1OVUE1eHMvbW8KQTM2dWtEYnNWVFlQRFdPc0NCUm1iZmJIWTcyYXZCZzRmUmcvQ3p2Rm9iUUFDa3U3U1lOU2srUmNqT2pJOVcrVQpRRkx5L0ROVWFaMm1xT1JGc1NLWFpWM3JGQmFWd2p5VXVCZDhMcWQ3Q1RjazNRd1h5Y1VVYU45eGNoMHcweU1sCklyd0l1dGpmVW5rbzBDdW13bTJXWVpXRXBsNDM4ZzBZb0s2ekRtQ1UrblpON1ZuaE9vazdHWVo3dEJUbVMzSGEKNlJlZkEwbVR6ZEsxCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K")
#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
#       command     = "aws"
#     }
#   }
# }

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

