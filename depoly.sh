#!/bin/bash

# ============================
# CONFIG
# ============================
REPO_DIR="/home/diva/deiva-url-shortner"
APP_DIR="$REPO_DIR/app"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")

# Log directories
LOG_DIR="$REPO_DIR/logs"
STARTUP_LOG="$LOG_DIR/startup/uvicorn_start_$TIMESTAMP.log"
ACCESS_LOG="$LOG_DIR/access/uvicorn_access_$TIMESTAMP.log"
ERROR_LOG="$LOG_DIR/error/uvicorn_error_$TIMESTAMP.log"

mkdir -p "$LOG_DIR/startup" "$LOG_DIR/error" "$LOG_DIR/access"


# ============================
# STEP 1 — PULL LATEST CODE
# ============================
echo "➡ Pulling latest changes..."
cd "$REPO_DIR" || { echo "❌ Repo not found"; exit 1; }
git pull origin develop
echo "✔ Git updated"


# ============================
# STEP 2 — VENV + REQUIREMENTS
# ============================
echo "➡ Preparing Python environment..."
cd "$APP_DIR"

if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

source venv/bin/activate

echo "➡ Installing dependencies..."
pip install -r requirements.txt
echo "✔ Dependencies installed"


# ============================
# STEP 3 — STOP PREVIOUS UVICORN
# ============================
if pgrep -f "uvicorn" > /dev/null; then
    echo "➡ Stopping previous Uvicorn instance..."
    pkill -f "uvicorn"
fi


# ============================
# STEP 4 — START UVICORN (CORRECT LOGGING)
# ============================
echo "➡ Starting Uvicorn server..."

# IMPORTANT FIX:
# Uvicorn sends ALL logs to STDERR by default.
# We force access logs to STDOUT using --log-level and filtering.

nohup uvicorn src.main:app \
    --host 0.0.0.0 \
    --port 8000 \
    --reload \
    --access-log \
    --log-level info \
    1> "$STARTUP_LOG" \
    2> "$ERROR_LOG" &

# Extract access logs from startup stdout (they always start with "INFO:     ")
grep --line-buffered "INFO:     " "$STARTUP_LOG" > "$ACCESS_LOG" &

echo "✔ Uvicorn started successfully"
echo "📌 Startup log → $STARTUP_LOG"
echo "📌 Access log  → $ACCESS_LOG"
echo "📌 Error log   → $ERROR_LOG"
echo "✅ Deployment complete"