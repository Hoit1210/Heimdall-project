# Security Policy for the Portfolio Repository

이 저장소는 Project Heimdall의 공개 포트폴리오용 구현 자산을 보존합니다.

## Secret Handling

다음 값은 Git에 커밋하지 않습니다.

- AWS Access Key / Secret Access Key
- Gemini API Key
- Database Password
- Application Encryption Key
- Private Key / Certificate Private Key
- Terraform State
- 실제 운영용 `.env`

Runtime Secret은 AWS Systems Manager Parameter Store 또는 GitHub Secrets/Variables를 사용합니다.

## Public Examples

공개 예제에는 실제 계정 정보 대신 Placeholder 또는 Variable을 사용합니다.

예:

```text
arn:aws:iam::<AWS_ACCOUNT_ID>:role/Heimdall-GitHubActions-OIDC-Role
```

## Evidence / Screenshots

포트폴리오에 Screenshot이나 Log를 공개할 경우 다음 정보를 Redact합니다.

- Credential / Token / Password
- AWS Account ID
- 불필요한 Endpoint / Instance Identifier
- Private IP 등 개인 환경 식별에 불필요한 값

## Security Test Assets

공격 문자열, 취약 코드 및 DR 데이터는 교육/검증용 Sample로만 취급하며 Production Application Code와 분리합니다.

## Scope

이 프로젝트는 Rule-based Guardrail, lightweight WAF, Rate Limiting, Fail2ban 및 External Dependency Failure Isolation을 검증한 포트폴리오 프로젝트입니다. 완전한 공격 차단, DDoS 방어, Zero Trust 준수 또는 무중단 운영을 보장한다고 주장하지 않습니다.
