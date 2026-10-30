import os
import sys
import time
import socket
import subprocess
import urllib.request
import pytest
from playwright.sync_api import sync_playwright

API_PORT = 8000
WEB_PORT = 3000
API_BASE = f"http://127.0.0.1:{API_PORT}"
WEB_BASE = f"http://127.0.0.1:{WEB_PORT}"

def is_port_open(port: int) -> bool:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex(("127.0.0.1", port)) == 0

def wait_for_url(url: str, timeout: float = 30.0) -> bool:
    start = time.time()
    while time.time() - start < timeout:
        try:
            with urllib.request.urlopen(url, timeout=1.5) as res:
                if res.status == 200:
                    return True
        except Exception:
            time.sleep(0.5)
    return False

@pytest.fixture(scope="session")
def live_servers():
    api_proc = None
    web_proc = None
    root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

    # 1. Start FastAPI backend if not already running
    if not is_port_open(API_PORT):
        api_dir = os.path.join(root_dir, "services", "api")
        api_proc = subprocess.Popen(
            [sys.executable, "-m", "uvicorn", "app.main:app", "--host", "127.0.0.1", "--port", str(API_PORT)],
            cwd=api_dir,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        if not wait_for_url(f"{API_BASE}/api/v1/health", timeout=30.0):
            if api_proc:
                subprocess.run(["taskkill", "/F", "/T", "/PID", str(api_proc.pid)], capture_output=True)
            raise RuntimeError("FastAPI server failed to start on port 8000")

    # 2. Start Next.js frontend if not already running
    if not is_port_open(WEB_PORT):
        web_proc = subprocess.Popen(
            ["cmd.exe", "/c", "pnpm", "--filter", "@buildmart/web", "start", "-p", str(WEB_PORT)],
            cwd=root_dir,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        if not wait_for_url(f"{WEB_BASE}/", timeout=30.0):
            if web_proc:
                subprocess.run(["taskkill", "/F", "/T", "/PID", str(web_proc.pid)], capture_output=True)
            if api_proc:
                subprocess.run(["taskkill", "/F", "/T", "/PID", str(api_proc.pid)], capture_output=True)
            raise RuntimeError("Next.js server failed to start on port 3000")

    yield WEB_BASE

    # Teardown
    if web_proc:
        try:
            subprocess.run(["taskkill", "/F", "/T", "/PID", str(web_proc.pid)], capture_output=True)
        except Exception:
            pass
    if api_proc:
        try:
            subprocess.run(["taskkill", "/F", "/T", "/PID", str(api_proc.pid)], capture_output=True)
        except Exception:
            pass

@pytest.fixture
def page(live_servers):
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(
            viewport={"width": 1280, "height": 800},
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 PlaywrightE2E"
        )
        page = context.new_page()
        yield page
        context.close()
        browser.close()
