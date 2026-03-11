from fastapi import FastAPI

app = FastAPI(title="Backend PACA test")

@app.get("/")
def read_root():
    return {"message": "Backend PACA OK"}
