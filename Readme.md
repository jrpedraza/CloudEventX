# Terraform AWS Infraestructura CloudEventX

Esta configuración de Terraform define la configuración de infraestructura para los diversos ambientes de la solucion CloudEventX. Se utilizan míltiples modulos para lograr una arquitectura comprensible. 

## Networking Module
```hcl 
module "networking" {
  source = "./modules/networking"
  # ... configuration ...
}
``` 
- Configura la infraestructura de red.
- configura VPC, subnets, y zonas de disponibilidad (AZ). 

## EKS Cluster Module
```hcl 
module "ekscluster" {
  source = "./modules/ekscluster"
  # ... configuration ...
}
```
- Configura un Amazon EKS (Elastic Kubernetes Service) cluster. 
- Usa salidas del módulo de networking para VPC y subnets. 

## Database Module 
```hcl 
module "database" {
  source = "./modules/database"
  # ... configuration ...
}
```
- Configura la infraestructura de bd, como la misma instancia de RDS. 
- Usa salidas del módulo de networking para VPC y subnets. 
- Se integra con el modulo de Secret Manager para la administración de credenciales. 
- Hace uso de un Proxy RDS para para mejorar la eficiencia de la base de datos y escalabilidad.   

## CloudFront Module
```hcl 
module "cloudfront" {
  source = "./modules/cloudfront"
  aws_s3_bucket_cloudfront_name = "${var.aws_s3_bucket_cloudfront_name}"
}
```
- Configura una distribución Amazon Cloudfront.
- Utiliza como origen un s3 bucket para la entrega de contenido. 

## Simple Email Service (SES) Module
```hcl 
module "simpleemailservice" {
  source = "./modules/ses"
  aws_ses_email_identity_email = var.aws_ses_email_identity_email
  aws_iam_user_name = var.aws_iam_user_name
}
```
- Se configura un Amazon SES para el servicio de email. 
- Se configura un email identity y se asocia con un usuario IAM.

## Secrets Manager Module
```hcl 
module "secretsmanagersecret" {
  source = "./modules/sm"
  aws_secretsmanager_db_username = var.aws_secretsmanager_db_username
  aws_secretsmanager_db_password = var.aws_secretsmanager_db_password
}
```
- Administra secretos mediante AWS Secret Manager. 
- Almacena credenciales y secretos de manera segura. 

--- 
## Observaciones 
1. Arquitectura modular: Se usa un enfoque modular, con lo que se logra la separación de intéreses. 
2. Uso de variables: Intensivo uso de varibales con lo que se promueve la reusabilidad y la fácil administración de los diversos ambientes. 
3. Dependencia de recursos: Los módulos se interconectan por lo que facilita su seguimiento. 
4. consideraciones de seguridad: Se usa Secret Manager para el manejo de información sencible de la infraestructura. 
5. Escalabilidad: El uso de múltiples zonas de disponibilidad (AZ) en la configuración de la red, con lo que se brinda un foco en la disponibilidad y la tolerancia a fallos. 

--- 
## Arquitectura de solucion CloudEventX 
![Alt text](CloudEventX.drawio.svg)
