# Troubleshooting

## 1. Fail2ban이 Nginx WAF Log를 읽지 못한 문제

### Problem
Nginx WAF에서 `403` / `429` Log가 생성됐지만 Fail2ban이 해당 Log를 안정적으로 읽지 못했습니다.

### Cause
Nginx Log가 `/home/...` 아래 Docker Volume 경로에 있었고, systemd Service Sandbox의 `ProtectHome` 정책 때문에 Fail2ban의 접근에 제약이 발생했습니다.

### Solution
Log 경로를 시스템 Log 영역으로 이동했습니다.

```text
/home/...
   ↓
/var/log/heimdall-nginx/
```

### Result
Fail2ban이 WAF Log를 감지하고 이후 Ban 절차로 연결할 수 있었습니다.

---

## 2. Docker Volume 환경의 Log 변경 감지 문제

### Problem
Log File에는 새로운 Event가 기록됐지만 일부 변경이 Fail2ban에 즉시 반영되지 않았습니다.

### Solution
File Event 의존 방식 대신 Polling 기반 감시를 적용했습니다.

### Result
Docker Volume 환경에서도 WAF Event를 지속적으로 추적할 수 있었습니다.

---

## 3. UTC / KST Timestamp 차이

### Problem
최근 발생한 WAF Event가 Fail2ban 판단 범위에서 제외되는 현상이 있었습니다.

### Cause
Container와 Host의 Timestamp 기준 차이가 Log Event 판단에 영향을 줬습니다.

### Solution
`findtime` 범위를 조정해 유효한 Event가 시간 차이로 제외되지 않도록 수정했습니다.

### Result
반복적인 WAF 차단 Event가 Ban 조건에 정상 반영됐습니다.

---

## 4. External AI API와 Reverse Proxy Timeout

### Problem
External AI API는 일반 Web Request보다 응답 시간이 길어질 수 있어 Nginx Proxy Timeout이 먼저 발생할 가능성이 있었습니다.

### Solution
AI API Request Path의 Proxy Timeout을 외부 AI 응답 특성에 맞게 조정했습니다.

### Result
일반 Web Request와 AI Request의 처리 특성 차이를 Reverse Proxy 정책에 반영했습니다.
