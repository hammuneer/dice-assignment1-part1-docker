import os
import platform
import socket
from datetime import datetime, timezone
from pathlib import Path

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

APP_VERSION = os.getenv("APP_VERSION", "1.0.0")
STATIC_DIR = Path(__file__).parent / "static"

app = FastAPI(title="Dice Docker Demo", version=APP_VERSION)


@app.get("/api/health")
def health():
    return {"status": "ok"}


@app.get("/api/hello")
def hello(name: str = "World"):
    return {"message": f"Hello, {name}! This response comes from FastAPI inside Docker."}


@app.get("/api/info")
def info():
    # Container details, handy for showing which container served the request
    return {
        "app_version": APP_VERSION,
        "hostname": socket.gethostname(),
        "python_version": platform.python_version(),
        "platform": platform.platform(),
        "server_time": datetime.now(timezone.utc).isoformat(),
    }


# Serve the built React app (only present inside the Docker image)
if STATIC_DIR.exists():
    app.mount("/", StaticFiles(directory=STATIC_DIR, html=True), name="frontend")
