# [Security 1] 경량화된 Slim 이미지 사용으로 불필요한 OS 패키지 취약점 최소화
FROM python:3.11-slim

WORKDIR /app

# [Security 2] 컨테이너 내 권한 상승 탈취 방지를 위한 논-루트(Non-root) 전용 유저 생성
RUN useradd -m -r -u 1001 appuser

# 의존성 파일 복사 및 초고속 바이너리 설치 (OOM/Rust 컴파일 에러 회피)
COPY requirements.txt .
RUN pip install --no-cache-dir --only-binary=:all: -r requirements.txt

# 애플리케이션 소스 코드 복사
COPY app/ ./app/

# [Security 3] 일반 유저(appuser) 권한으로 전환하여 애플리케이션 실행
USER appuser

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
