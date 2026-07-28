# Project [ Heimdall ]: 외부 AI API 통제 프레임워크 기반의 격리형 3-Tier 클라우드 인프라 구축

> **최종 빌드 일시:** 2026-07-28 11:24:24 KST (2026년 7월 최신 DevSecOps & Agentic RAG 규격)  
> **프로젝트 개요:** 본 프로젝트는 외부 AI API(Google Gemini 3.5 Flash) 이용 시 발생할 수 있는 데이터 유출 및 프롬프트 인젝션을 통제하고, AWS 프리티어 기반의 격리된 3-Tier 인프라 환경에서 무키(Keyless) DevSecOps 파이프라인과 완벽한 FinOps/관제 시스템을 구축한 프로젝트입니다.

---
## 1. 전체 엔드투엔드 아키텍처 다이어그램 (System Architecture)

```mermaid
graph TD
    subgraph Client & External
        User([Client / Developer])
        GH[GitHub Actions CI/CD Pipeline]
        Gemini[Google AI Studio / Gemini 3.5 Flash API]
    end

    subgraph AWS Cloud (ap-northeast-2)
        subgraph Public Subnet
            WAF[Nginx Reverse Proxy & Fail2ban]
            Prom[Prometheus & Grafana 관제]
        end

        subgraph Private Application Subnet (EC2 t3.micro)
            App[Python FastAPI WAS Container]
            Redis[Redis Rate Limiter Container]
            Chroma[ChromaDB Local Vector Store]
        end

        subgraph Private Database Subnet (RDS)
            RDS[(AWS RDS MySQL - Encrypted At-Rest)]
        end

        SSM[AWS SSM Parameter Store]
        OIDC[AWS IAM OIDC Provider - Keyless]
    end

    User -->|HTTPS / Port 443| WAF
    WAF -->|Internal Rate Limit| App
    App <-->|AES-256 Auth & Data| RDS
    App <-->|Vector Context| Chroma
    App <-->|Token Count & Throttling| Redis
    App -->|Guardrail Filtered Prompt| Gemini
    GH -->|Keyless OIDC AssumeRole| OIDC
    GH -->|Pull-based CD via SSM| App
    Prom -->|Metrics / Blackbox Exporter| WAF
```

---
