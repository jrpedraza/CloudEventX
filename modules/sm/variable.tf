variable "aws_secretsmanager_db_username" {
  type        = string
  description = "Database username"
}

variable "aws_secretsmanager_db_password" {
  type        = string
  description = "Database password"
  sensitive   = true
}