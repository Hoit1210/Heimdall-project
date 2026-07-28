# [Reverse Engineering 1] GitHub Actions OIDC 자격 증명 공급자
resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# [Reverse Engineering 2] Keyless DevSecOps IAM 역할
resource "aws_iam_role" "github_actions_oidc" {
  name        = "Heimdall-GitHubActions-OIDC-Role"
  description = "Keyless DevSecOps CI/CD OIDC Role for GitHub Actions"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github_actions.arn }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = { "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com" }
        StringLike   = { "token.actions.githubusercontent.com:sub" = "repo:*:*" }
      }
    }]
  })
}

# [Reverse Engineering 3] 정책 연결
resource "aws_iam_role_policy_attachment" "ecr_power_user" {
  role       = aws_iam_role.github_actions_oidc.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "ssm_full_access" {
  role       = aws_iam_role.github_actions_oidc.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

# [One-Click Simulation Asset] 즉시 응답하는 시뮬레이션 검증 자산
resource "aws_ssm_parameter" "heimdall_cd_status" {
  name        = "/heimdall/devsecops/cd_status"
  description = "Heimdall Zero-downtime CD Pipeline Status via Terraform"
  type        = "String"
  value       = "Step 27 Completed - Keyless IaC Reverse Engineered!"
  overwrite   = true
}
