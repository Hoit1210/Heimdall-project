#!/bin/bash
set -e
print_log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"; }

print_log "=== [Heimdall CD] 무중단 Pull-based CD 배포 가동 ==="
# SSM의 root 실행 권한에서도 정확히 찾아갈 수 있도록 절대 경로 지정
cd /home/ssm-user/heimdall-project/deploy

print_log "1. 컨테이너 빌드 및 무중단 교체 실행..."
docker compose up -d --build --remove-orphans

print_log "2. [OOM 차단] 불필요한 구버전 이미지 및 빌드 캐시 강제 청소..."
docker image prune -f > /dev/null 2>&1 || true

print_log "3. 컨테이너 정상 작동 헬스체크 확인..."
sleep 3
docker ps | grep heimdall-api

print_log "=== [Success] 배포가 완벽하게 성공했습니다! ==="
