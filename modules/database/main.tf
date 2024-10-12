# Create an Amazon RDS MySQL database

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = flatten(var.private_subnets_id)

  tags = {
    Name = "main"
  }
}

# create an instance of the database
resource "aws_db_instance" "my_db_instance" {
  identifier             = var.db_instance_identifier
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = var.db_instance_username
  password               = var.db_instance_password
  publicly_accessible    = false
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.default.name
}

# IAM role statement that provides the necessary permissions for an RDS Proxy
resource "aws_iam_role" "rds_proxy_role" {
  name = "rds-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "rds_proxy_policy" {
  name = "rds-proxy-policy"
  role = aws_iam_role.rds_proxy_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Resource = [
          var.aws_secretsmanager_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = [
          var.aws_kms_key_arn
        ]
        Condition = {
          StringEquals = {
            "kms:ViaService": "secretsmanager.${var.region}.amazonaws.com"
          }
        }
      }
    ]
  })
}

# security group for the RDS Proxy
resource "aws_security_group" "rds_proxy_sg" {
  name        = "rds-proxy-security-group"
  description = "Security group for RDS Proxy"
  vpc_id      = var.vpc_id

  # Allow inbound traffic on the database port from your application security group
  ingress {
    from_port       = 3306  # Adjust for your database type (e.g., 5432 for PostgreSQL)
    to_port         = 3306
    protocol        = "tcp"
    # security_groups = [var.app_security_group_id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create a db proxy to connect to the database
resource "aws_db_proxy" "example" {
  name                   = "example-proxy"
  debug_logging          = false
  engine_family          = "MYSQL"
  idle_client_timeout    = 1800
  require_tls            = true
  role_arn               = aws_iam_role.rds_proxy_role.arn
  vpc_security_group_ids = [aws_security_group.rds_proxy_sg.id]
  vpc_subnet_ids         = flatten(var.private_subnets_id)

  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "DISABLED"
    secret_arn  = var.aws_secretsmanager_arn
  }
}

resource "aws_db_proxy_default_target_group" "example" {
  db_proxy_name = aws_db_proxy.example.name

  connection_pool_config {
    max_connections_percent = 100
  }
}

resource "aws_db_proxy_target" "example" {
  db_proxy_name         = aws_db_proxy.example.name
  target_group_name     = aws_db_proxy_default_target_group.example.name
  db_instance_identifier = aws_db_instance.my_db_instance.id
}
