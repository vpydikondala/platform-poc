from fastapi import FastAPI

app = FastAPI(title="{{ name }}")

@app.get("/")
def root():
    return {
        "service": "{{ name }}",
        "status": "running"
    }

@app.get("/healthz")
def healthz():
    return {"status": "ok"}
