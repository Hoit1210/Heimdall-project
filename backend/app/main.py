from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI(title="Heimdall DevSecOps API")

Instrumentator().instrument(app).expose(app)

@app.get("/")
def read_root():
    return {"status": "secure", "project": "Heimdall DevSecOps Pipeline"}

@app.get("/health")
def health_check():
    return {"status": "up"}
