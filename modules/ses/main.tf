# Provides an SES email identity resource
resource "aws_ses_email_identity" "example" {
  email = var.aws_ses_email_identity_email
}

# Provides an IAM access key. This is a set of credentials that allow API requests to be made as an IAM user.
resource "aws_iam_user" "user" {
  name = var.aws_iam_user_name
}

# Provides an IAM access key. This is a set of credentials that allow API requests to be made as an IAM user.
resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.user.name
}

# Attaches a Managed IAM Policy to SES Email Identity resource
data "aws_iam_policy_document" "policy_document" {
  statement {
    actions   = ["ses:SendEmail", "ses:SendRawEmail"]
    # resources = [data.aws_ses_email_identity.example.arn]
    resources = [aws_ses_email_identity.example.arn]
  }
}

# Provides an IAM policy attached to a user.
resource "aws_iam_policy" "policy" {
  name   = "ses-send-email-policy"
  policy = data.aws_iam_policy_document.policy_document.json
}

# Attaches a Managed IAM Policy to an IAM user
resource "aws_iam_user_policy_attachment" "user_policy" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.policy.arn
}
