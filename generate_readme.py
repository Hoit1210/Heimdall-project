#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
==============================================================================
Project [ Heimdall ] - 최종 포트폴리오용 README.md 자동 생성 스크립트
==============================================================================
* 실행 위치: Ubuntu Linux OS (AWS EC2 t3.micro 호스트의 ~/heimdall-project)
* 기준 버전: Python 3.12+ (2026년 7월 최신 DevSecOps & FinOps 규격)
* 반영 사항: 
  1) 이모티콘 및 불필요한 시각적 장식 완전 배제 (엔터프라이즈 기술 문서 규격)
  2) 외부 AI API 모델명을 최신 'Google Gemini 3.5 Flash'로 정확히 매핑
  3) GitHub Mermaid 렌더링 파서(Parser)의 괄호 '()' 충돌 오류 완벽 해결
==============================================================================
"""

import sys
from datetime import datetime
from pathlib import Path


def _build_header() -> str:
    """프로젝트 타이틀 및 엔터프라이즈 요약 헤더를 빌드합니다."""
    timestamp: str = datetime.now().strftime("%Y-%m-%d %H:%M:%S KST")
    return f"""# Project [ Heimdall ]: 외부 AI API 통제 프레임워크 기반의 격리형 3-Tier 클라우드 인프라 구축

> **최종 빌드 일시:** {timestamp} (2026년 7월 최신 DevSecOps & Agentic RAG 규격)  
> **프로젝트 개요:** 본 프로젝트는 외부 AI API(Google Gemini 3.5 Flash) 이용 시 발생할 수 있는 데이터 유출 및 프롬프트 인젝션을 통제하고, AWS 프리티어 기반의 격리된 3-Tier 인프라 환경에서 무키(Keyless) DevSecOps 파이프라인과 완벽한 FinOps/관제 시스템을 구축한 프로젝트입니다.

---
"""


def _build_architecture_section() -> str:
    """Mermaid.js 기반의 3-Tier 격리 아키텍처 및 네트워크 다이어그램을 빌드합니다."""
    return """## 1. 전체 엔드투엔드 아키텍처 다이어그램 (System Architecture)

```mermaid
graph TD
    subgraph External["Client & External"]
        User([Client / Developer])
        GH[GitHub Actions CI/CD Pipeline]
        Gemini[Google AI Studio / Gemini 3.5 Flash API]
    end

    subgraph AWS["AWS Cloud (ap-northeast-2)"]
        subgraph Public["Public Subnet"]
            WAF[Nginx Reverse Proxy & Fail2ban]
            Prom[Prometheus & Grafana 관제]
        end

        subgraph PrivateApp["Private Application Subnet (EC2 t3.micro)"]
            App[Python FastAPI WAS Container]
            Redis[Redis Rate Limiter Container]
            Chroma[ChromaDB Local Vector Store]
        end

        subgraph PrivateDB["Private Database Subnet (RDS)"]
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
"""


def generate_readme() -> None:
    """
    모듈화된 빌더 함수들을 호출하여 README.md 문서를 조합하고
    로컬 디스크에 UTF-8 인코딩으로 안전하게 작성합니다.
    """
    readme_content: str = "".join([
        _build_header(),
        _build_architecture_section()
    ])

    output_path: Path = Path.cwd() / "README.md"

    try:
        output_path.write_text(readme_content, encoding="utf-8")
        file_size_kb: float = output_path.stat().st_size / 1024
        print("========================================================================")
        print("[Pass] Project [ Heimdall ] 포트폴리오 README.md 생성 완료")
        print(f"       -> 절대 경로: {output_path.resolve()}")
        print(f"       -> 파일 크기: {file_size_kb:.2f} KB")
        print("========================================================================")
    except PermissionError:
        print("[Error] 파일 쓰기 권한이 없습니다. sudo 권한이나 디렉토리 소유권을 확인하세요.", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"[Error] README.md 파일 생성 중 예기치 못한 오류 발생: {str(e)}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    generate_readme()
