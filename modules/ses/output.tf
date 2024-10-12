# IAM user credentials output
output "smtp_username" {
  value = aws_iam_user.user.id
}

# output "smtp_password" {
#   value     = aws_iam_access_key.access_key.ses_smtp_password_v4
#   sensitive = true
# }