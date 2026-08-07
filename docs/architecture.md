# Heimdall Architecture

## Engineering Question

외부 AI API를 사용하는 Cloud Application에서 Secret과 Data를 보호하면서, 외부로 전달되는 Request/Response와 Traffic을 통제하고 External Dependency의 장애 영향까지 어떻게 줄일 것인가?

## Architecture Evolution

### Phase 1 — Secure Application Foundation

```text
Client
  ↓
Nginx
  ↓
FastAPI
```

- Nginx Reverse Proxy
- FastAPI WAS
- Docker Internal Network
- Health Check

### Phase 2 — Cloud & Data Isolation

```text
Administrator
    ↓
AWS SSM Session Manager
    ↓
EC2 / FastAPI
    ↓
Private RDS
```

- SSH 직접 접근 감소
- AWS Parameter Store 기반 Secret 분리
- Private RDS + Security Group 기반 Workload Access
- RDS Storage Encryption
- Application-level Data Encryption

### Phase 3 — AI Control Layer

```text
User
 ↓
Inbound Guardrail
 ↓
FastAPI
 ↓
RAG / FAISS
 ↓
Gemini API
 ↓
Outbound Guardrail
 ↓
User
```

- Prompt Injection / 위험 Pattern 제한
- Sensitive Data Masking
- FAISS Semantic Search
- Retry + Circuit Breaker

### Phase 4 — Defense in Depth

```text
Client
 ↓
Nginx lightweight WAF
 ↓
Redis Rate Limit
 ↓
FastAPI

Repeated blocked requests
 ↓
Fail2ban
 ↓
DOCKER-USER
 ↓
IP DROP
```

- IP / API Token 기반 Rate Limit
- SQL Injection / Path Traversal 등 Pattern Filtering
- WAF Log 기반 Fail2ban 감지
- `DOCKER-USER` Chain 기반 Drop
- Blocked IP 상태 Parameter Store 기록

### Phase 5 — External Dependency Observability

```text
Infrastructure → Node Exporter → Prometheus → Grafana
External HTTPS → Blackbox Exporter → Prometheus
```

- Infrastructure Metric
- FastAPI Metric
- External HTTPS Availability
- HTTP Status
- TLS Certificate Expiration
- AI API Usage Metric 수집 기반

## Design Boundary

Project 02의 핵심은 CI/CD 또는 Terraform 자체가 아니라 **External AI API & Data Flow Control**입니다.

GitHub Actions OIDC, SSM CD, Terraform, DR, FinOps는 실제 구현 증거로 저장소에 보존하지만 메인 Story에서는 보조 요소로 다룹니다.
