# Create a KMS key for encrypting the secret (optional but recommended)
resource "aws_kms_key" "secret_key" {
  description             = "KMS key for Secrets Manager"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

# Create the Secrets Manager secret
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "db-credentials"
  description = "Database credentials for RDS"
  kms_key_id  = aws_kms_key.secret_key.key_id
}

# Add a version to the secret with the actual values
resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.aws_secretsmanager_db_username
    password = var.aws_secretsmanager_db_password
  })
}

