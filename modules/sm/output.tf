# Output the secret ARN (you'll need this for other resources)
output "secretsmanager_arn" {
  value       = aws_secretsmanager_secret.db_credentials.arn
  description = "ARN of the Secrets Manager secret"
}

output "aws_kms_key_arn" {
  value       = aws_kms_key.secret_key.arn
  description = "ARN of the KMS key"
}
  