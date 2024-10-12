# Arquitectura de solucion CloudEventX 
![Alt text](CloudEventX.drawio.svg)

A muy alto nivel la solucíon se compone de una **VPC**, la cual cuenta con dos zonas de disponibilidad **AZ** (AZ1 y AZ2), en cada ZD hay definida una subred publica y una subred privada. También se define a nivel de redes un balanceador de carga **ALB**. 

En la subred privada se disponibiliza un **Amazon EKS**, y en la subred pública se encuentra un nat gateway **NAT**, con elque se da acceso a Internet a la subred privada. 

Se hace uso de servicios globales de Amazon como: 
- Cloudfront
- Elastic Storage Simple Service S3
- RDS
- RDS Proxy 
- AWS Codepipeline
- AWS Codebuild 
- AWS Codedeploy 
- AWS Elastic Container Registry ECR
- Simple Email Service 
- Git (externo AWS)

A nivel funcional el *Cloudfront* va a recibir las peticiones procedentes de los usuario ubicados en Internet, este va a obtener el contenido alojado en el servicio *S3* y va a retornar la respuesta. Las peticiones posteriores del navagador van a ir al **ALB** y este va a distribuir convenientemente entre los servicios expuestos por el **EKS** en el que se disponibiliza la lógica de negocio de la aplicación. La capa de lógica de negocio va a servirse de un *RDS Proxy* que tiene acceso a las instancias de base de datos requeridas<sub>*1</sub> y se sirve de las características de tolerancia a fallas y alta disponibilidad. El servicio de base de datos usa el modelo de maestro/esclavo con lo que se logra alta disponibilidad ya que el servicio contempla una instancia de lectura/escritura y dos de lectura en zonas diferentes. 

La solución hace uso de una instancia de *Simple Email Service* para el envío de notificaciones, el cual tiene características de flexibilidad y escalabilidad que lo hacen ideales para la solución. 

El IT Team hace uso de la solucion en dos casos de uso específicos: 
* El primero el equipo de infraestructura tiene un proyecto de Terraform, con el que realiza el proceso de creación de la infraestructura para los diversos ambientes. 
* En el segundo el equipo de desarrollo tiene los fuentes de sus aplicaciones en los diversos lenguajes y haciendo uso de plantillas YML y un Pipeline realiza los procesos de CI/CD.     

## Instalación y ejecución
Paso 1: clonar el repositorio. 
```hcl 
https://github.com/jrpedraza/CloudEventX.git
```
Paso 2: actualizar las variables en **./environments/dev/terraform.tfvars** acorde a los requerimientos y teniendo en cuenta en que ambiente se desea trabajar. Para el ejemplo ambiente de desarrollo (*/dev/*). 

Paso 3: tener habilitado un ambiente totalmente operativo para trabajar con Terraform. 

Paso 4: definir claramente y sin lugar a dudas la ubicación de almacenamiento local del estado. *Mantener el estado es de suma importancia, lo cual permite realizar operaciones de reconciliación o destrucción de recursos*. 

Paso 5: comandos básicos: 
```hcl 
terraform init
terraform validate
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars -state=/custom/path/to/terraform.tfstate
```

## Terraform AWS Infraestructura CloudEventX

Esta configuración de Terraform define la configuración de infraestructura para los diversos ambientes de la solucion CloudEventX. Se utilizan míltiples modulos para lograr una arquitectura comprensible. 

### Networking Module
```hcl 
module "networking" {
  source = "./modules/networking"
  # ... configuration ...
}
``` 
- Configura la infraestructura de red.
- configura VPC, subnets, y zonas de disponibilidad (AZ). 

### EKS Cluster Module
```hcl 
module "ekscluster" {
  source = "./modules/ekscluster"
  # ... configuration ...
}
```
- Configura un Amazon EKS (Elastic Kubernetes Service) cluster. 
- Usa salidas del módulo de networking para VPC y subnets. 

### Database Module 
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

### CloudFront Module
```hcl 
module "cloudfront" {
  source = "./modules/cloudfront"
  aws_s3_bucket_cloudfront_name = "${var.aws_s3_bucket_cloudfront_name}"
}
```
- Configura una distribución Amazon Cloudfront.
- Utiliza como origen un s3 bucket para la entrega de contenido. 

### Simple Email Service (SES) Module
```hcl 
module "simpleemailservice" {
  source = "./modules/ses"
  aws_ses_email_identity_email = var.aws_ses_email_identity_email
  aws_iam_user_name = var.aws_iam_user_name
}
```
- Se configura un Amazon SES para el servicio de email. 
- Se configura un email identity y se asocia con un usuario IAM.

### Secrets Manager Module
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
### Observaciones 
1. Arquitectura modular: Se usa un enfoque modular, con lo que se logra la separación de intéreses. 
2. Uso de variables: Intensivo uso de varibales con lo que se promueve la reusabilidad y la fácil administración de los diversos ambientes. 
3. Dependencia de recursos: Los módulos se interconectan por lo que facilita su seguimiento. 
4. consideraciones de seguridad: Se usa Secret Manager para el manejo de información sencible de la infraestructura. 
5. Escalabilidad: El uso de múltiples zonas de disponibilidad (AZ) en la configuración de la red, con lo que se brinda un foco en la disponibilidad y la tolerancia a fallos. 

--- 
### Aclaraciones
<sub>*1</sub> Solo se muestra una instancia de base de datos, pero se contempla la creación de tantas instancias como se requieran (esto se define con el developer team).