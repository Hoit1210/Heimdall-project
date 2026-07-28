output "oidc_provider_arn" {
  description = "Reverse Engineered OIDC Provider ARN"
  value       = aws_iam_openid_connect_provider.github_actions.arn
}

output "iam_role_name" {
  description = "Reverse Engineered Keyless IAM Role Name"
  value       = aws_iam_role.github_actions_oidc.name
}
