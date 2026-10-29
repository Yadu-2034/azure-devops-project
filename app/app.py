"""Simple Flask web app deployed to an Azure VM by a Jenkins pipeline."""
import os
import platform
import socket
from datetime import datetime, timezone

from flask import Flask, jsonify, render_template

app = Flask(__name__)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
STARTED_AT = datetime.now(timezone.utc)


def read_version() -> str:
    """Jenkins writes build number + commit into the VERSION file at deploy time."""
    try:
        with open(os.path.join(BASE_DIR, "VERSION"), encoding="utf-8") as f:
            return f.read().strip() or "dev"
    except OSError:
        return "dev"


def build_info() -> dict:
    return {
        "version": read_version(),
        "hostname": socket.gethostname(),
        "python": platform.python_version(),
        "os": platform.platform(),
        "started_at": STARTED_AT.strftime("%Y-%m-%d %H:%M:%S UTC"),
    }


@app.route("/")
def index():
    return render_template("index.html", info=build_info())


@app.route("/health")
def health():
    return jsonify(status="ok")


@app.route("/api/info")
def api_info():
    return jsonify(build_info())


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
