resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_actions_oidc" {
  name        = "Heimdall-GitHubActions-OIDC-Role"
  description = "OIDC role used by the Heimdall GitHub Actions validation pipeline"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github_actions.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:Hoit1210/Heimdall-project:*"
        }
      }
    }]
  })
}

# These managed policies reflect the project experiment and are intentionally
# kept as implementation evidence. They should be narrowed before production use.
resource "aws_iam_role_policy_attachment" "ecr_power_user" {
  role       = aws_iam_role.github_actions_oidc.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "ssm_full_access" {
  role       = aws_iam_role.github_actions_oidc.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_ssm_parameter" "heimdall_cd_status" {
  name        = "/heimdall/devsecops/cd_status"
  description = "Heimdall IaC validation status"
  type        = "String"
  value       = "Terraform validation asset created"
  overwrite   = true
}
