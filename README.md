# Project Heimdall

> 외부 AI API 통제 프레임워크 기반의 격리형 3-Tier 클라우드 인프라 구축

Project 01에서 구축한 Cloud Infrastructure를 기반으로, 외부 AI API 사용으로 새롭게 발생한 Secret · Data · Request/Response · Traffic · Failure Boundary를 통제하도록 확장한 Security & Reliability 프로젝트입니다.

## Project Context

Project 01에서는 Docker 기반 실행 환경, AWS 3-Tier 구조, HTTPS, RDS 분리와 기본 Monitoring 환경을 구축했습니다.

Heimdall에서는 외부 AI API 연동 이후 생긴 새로운 Trust Boundary를 기준으로 다음 영역을 강화했습니다.

- AWS SSM Session Manager 기반 EC2 관리
- AWS Parameter Store 기반 Secret 관리
- Private RDS + Security Group 기반 Database 접근 통제
- RDS Storage Encryption + Application-level Data Encryption
- Gemini API + FAISS 기반 AI Workload
- Inbound Guardrail / Outbound Sensitive Data Masking
- Redis Rate Limit + Nginx 경량 WAF
- Fail2ban + `DOCKER-USER` 기반 반복 공격 IP 차단
- Retry + Circuit Breaker 기반 External API Failure Isolation
- Prometheus / Grafana / Blackbox Exporter 기반 Observability

> Portfolio Story: Project 01 `BUILD` → Project 02 `SECURE` → Project 03 `OBSERVE & RESPOND` → Project 04 `AUTOMATE`

---

## Architecture

<img width="2816" height="1536" alt="Heimdall-v1" src="https://github.com/user-attachments/assets/5218d1e0-8d36-4eef-bf9a-d8f6015396b2" />

```text
Foundation
   ↓
Cloud & Data Isolation
   ↓
AI Control Layer
   ↓
Defense in Depth
   ↓
External Dependency Observability
```

자세한 설계 의도와 구성 요소는 [`docs/architecture.md`](./docs/architecture.md)를 참고하세요.

---

## Core Engineering Decisions

| Problem | Decision | Reason |
|---|---|---|
| EC2 management port exposure | SSM Session Manager | SSH 직접 노출을 줄이고 AWS 관리 경로 사용 |
| Secret management | Parameter Store | DB Credential/API Key를 Source Code와 분리 |
| Database boundary | Private RDS + SG | Workload 관계 중심으로 접근 제한 |
| Sensitive data storage | Application-level encryption | Storage Encryption과 별도 보호 계층 추가 |
| Dangerous AI request | Inbound Guardrail | 외부 AI API 호출 전 위험 Pattern 제한 |
| Sensitive AI response | Outbound Masking | 사용자 전달 전 민감정보 Masking |
| Repeated API request | Redis Rate Limit | IP/API Token 기준 Request 제어 |
| Malicious web request | Nginx WAF | Application 도달 전 Request Filtering |
| External API failure | Retry + Circuit Breaker | 외부 Dependency 장애 영향 완화 |
| External service visibility | Blackbox Exporter | Client 관점에서 HTTPS 상태 관측 |

---


## 구성도

[클라우드 구성도와 구성 요소 설명](docs/cloud-architecture.md)

## Repository Structure

```text
.
├── backend/                     # FastAPI application
├── nginx/                       # Reverse Proxy / HTTPS / WAF
├── monitoring/                  # Prometheus / Grafana / Blackbox
├── deploy/                      # SSM 기반 배포 스크립트
├── aws-iac/                     # GitHub Actions OIDC 관련 AWS 정책 예제
├── terraform-iac-step27/        # 후반부 Terraform IaC 검증 코드
├── dr-simulation/               # Backup / Restore 검증용 샘플 자산
├── finops/                      # AWS Budget / Cost control 실험 설정
├── .github/workflows/           # DevSecOps CI / OIDC / SSM CD / Trivy
├── docs/                        # Architecture / Troubleshooting 문서
├── docker-compose.yml           # Container execution configuration
├── .env.example                 # 공개 가능한 환경변수 예시
└── SECURITY.md                  # Repository 공개 보안 원칙
```

> `Docker Compose`는 실행 환경과 Container 구성을 정의하는 용도로 사용했으며 Terraform IaC와 구분합니다.

---

## Validation Highlights

- SSM Session Manager 기반 EC2 관리 세션 생성
- Parameter Store `SecureString` 기반 DB/Gemini 설정 분리
- RDS Storage Encryption 상태 확인
- Application-level 암호화/복호화 검증
- FAISS Semantic Search 동작 확인
- AI Response 민감정보 Masking 검증
- IP/API Token Rate Limit 검증
- SQL Injection Pattern Request에 `403 Forbidden` 반환
- Fail2ban → `DOCKER-USER` DROP 연계 검증
- Blocked IP 정보 Parameter Store 기록
- Blackbox HTTPS Probe를 통한 Availability / HTTP Status / TLS Metric 확인

---

## Observability & Reliability

외부 AI Provider는 Application이 직접 제어할 수 없는 Dependency이므로 Retry와 Circuit Breaker를 적용하여 반복 실패의 영향을 완화했습니다.

Monitoring은 Infrastructure Metric뿐 아니라 Application과 External HTTPS Endpoint까지 확장했습니다. 제한된 EC2 자원을 고려해 Prometheus TSDB Retention도 제한했습니다.

---

## Additional Implementation Evidence

Project 후반부에는 아래 항목도 별도로 검증했습니다. Repository에는 실제 수행 증거로 보존하되, Project 02의 메인 스토리는 External AI API & Data Flow Control에 둡니다.

- GitHub Actions OIDC 기반 AWS 인증
- SAST / Dependency / Container Image Security Check
- AWS SSM 기반 Pull-style CD
- Terraform을 이용한 일부 AWS 자산 코드화 검증
- DR Simulation
- AWS Budget / FinOps 실험

이 영역은 이후 Project 04의 IaC / CI-CD / Auto-Healing 주제와 연결됩니다.

---

## Troubleshooting

대표 Troubleshooting은 [`docs/troubleshooting.md`](./docs/troubleshooting.md)에 정리했습니다.

핵심 사례:

1. systemd `ProtectHome`으로 인한 Fail2ban Log 접근 문제
2. Docker Volume 환경에서 Log 변경 Event 감지 문제
3. UTC / KST Timestamp 차이에 따른 Ban 판단 문제
4. External AI API 특성에 따른 Reverse Proxy Timeout 조정

---

## Security Notes

실제 Secret, API Key, Password, Private Key, Terraform State는 Repository에 커밋하지 않습니다.

- Runtime Secret: AWS Parameter Store / GitHub Secret 사용
- Local Secret: `.env` 등 Git 제외
- Account-specific Identifier: 예제에서는 Placeholder 또는 Variable 사용
- Screenshot/Log 공개 시 Credential 및 Identifier Redaction

자세한 내용은 [`SECURITY.md`](./SECURITY.md)를 참고하세요.

---

## Portfolio Documentation

Notion — Project 02 Heimdall  
https://app.notion.com/p/3a459c94122580b1aab2cfd683f61568?pvs=204

Notion은 Problem → Architecture Evolution → Decision → Validation → Troubleshooting을 설명하고, GitHub는 실제 구현 코드와 설정을 보존하는 역할로 분리했습니다.

---

## Limitations & Next Step

Heimdall은 Rule/Pattern 기반 Guardrail과 WAF, Metric 수집 및 일부 자동 차단까지 구현했지만, 여러 Metric/Log/Security Event를 하나의 Incident Context로 해석하는 단계는 운영자 판단에 의존합니다.

> Next Engineering Question  
> Infrastructure Metric, Application Log, Security Event를 하나의 운영 Context로 분석해 장애와 공격의 의미를 판단하고 대응까지 연결할 수 있을까?

→ Project 03: Bifrost — Context-Aware SRE & Security Monitoring Automation


---

## 클라우드 인프라 구성 및 검증

이 프로젝트는 AI 모델 자체를 개발하는 프로젝트보다, 외부 AI API를 사용하는 클라우드 워크로드의 네트워크·데이터·보안·배포 경계를 직접 구축한 프로젝트에 가깝습니다.

- 클라우드/접근 경계: AWS SSM Session Manager, Private RDS, Security Group, IAM/OIDC 기반 인증 구성 및 검증 기록
- Secrets/데이터 보호: Parameter Store, RDS 저장 암호화, 애플리케이션 수준 암호화·복호화
- 애플리케이션 통신: Nginx HTTPS, AI API 요청 전 Guardrail, 응답 Masking, Redis Rate Limit
- 가용성과 관측: Retry/Circuit Breaker, Blackbox Exporter, Prometheus/Grafana
- 보안 검증: Fail2ban → DOCKER-USER 차단 연계, WAF 패턴 차단 및 테스트 기록

위 항목의 작업 과정·스크린샷·검증 근거는 [개인 프로젝트 관리 — Project 02 Heimdall](https://app.notion.com/p/3b559c941225804ebe80cdbe1b098115) 및 [초기 프로젝트 구성 기록](https://app.notion.com/p/3a459c94122580b1aab2cfd683f61568)에서 확인할 수 있습니다.

### 구현 구성도 읽는 법

README 상단의 Heimdall 아키텍처 이미지는 여러 방어·제어 계층을 표현합니다. SSM 관리 경로, Nginx 진입점, FastAPI 기반 AI 처리, Private RDS, Observability 경로가 서로 다른 목적을 가진다는 점에 주목하면 됩니다. Terraform/CI 실험과 DR/FinOps 항목은 메인 AI API 통제 흐름과 구분해 기록했습니다. 일부 부가 실습을 일괄적으로 상시 운영 중인 프로덕션 환경으로 주장하지 않습니다.

[구축 및 검증 화면 목록](docs/evidence-gallery.md)
