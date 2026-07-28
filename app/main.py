from fastapi import FastAPI
app = FastAPI()
@app.get("/")
async def root():
    return {"status": "success", "message": "Heimdall WAS: Nginx WAF 보안 검사를 정상 통과했습니다!"}
