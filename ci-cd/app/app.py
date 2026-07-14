import os

from flask import Flask

app = Flask(__name__)


@app.get("/healthz")
def healthz():
    creds_present = bool(os.environ.get("username") and os.environ.get("password"))
    return {"status": "ok", "db_creds_injected": creds_present}


@app.get("/debug/creds")
def debug_creds():
    return {
        "username": os.environ.get("username"),
        "password": os.environ.get("password"),
    }


@app.get("/")
def index():
    return "demo1: secure the pipeline\n"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
