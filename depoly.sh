#!/bin/bash

# ============================
# CONFIG
# ============================
REPO_DIR="/home/diva/deiva-url-shortner"
APP_DIR="$REPO_DIR/app"

# Timestamp
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")

# Log folder structure
LOG_DIR="$REPO_DIR/logs"
STARTUP_LOG="$LOG_DIR/startup/uvicorn_start_$TIMESTAMP.log"
ERROR_LOG="$LOG_DIR/error/uvicorn_error_$TIMESTAMP.log"
ACCESS_LOG="$LOG_DIR/access/uvicorn_access_$TIMESTAMP.log"

# Create log directories
mkdir -p "$LOG_DIR/startup" "$LOG_DIR/error" "$LOG_DIR/access"


# ============================
# STEP 1 — GIT PULL
# ============================
echo "➡ Pulling latest changes from repo..."
cd "$REPO_DIR" || { echo "❌ Repo directory not found"; exit 1; }

git pull origin develop
echo "✔ Git updated successfully"


# ============================
# STEP 2 — PYTHON ENV SETUP
# ============================
echo "➡ Setting up virtual environment..."
cd "$APP_DIR"

if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

source venv/bin/activate

echo "➡ Installing dependencies..."
pip install -r requirements.txt
echo "✔ Dependencies installed"


# ============================
# STEP 3 — START UVICORN
# ============================
echo "➡ Starting Uvicorn server..."

# Kill old uvicorn instances cleanly
if pgrep -f "uvicorn"; then
    echo "➡ Stopping previous Uvicorn instance..."
    pkill -f "uvicorn"
fi

# Start new instance with proper logs
nohup uvicorn src.main:app \
    --host 0.0.0.0 \
    --port 8000 \
    --reload \
    --access-log \
    > "$STARTUP_LOG" \
    2> "$ERROR_LOG" &

# Extract ONLY access logs from STDOUT into a separate file
grep --line-buffered "INFO:     " "$STARTUP_LOG" > "$ACCESS_LOG" &

echo "✔ Uvicorn started"
echo "📌 Startup log: $STARTUP_LOG"
echo "📌 Error log:   $ERROR_LOG"
echo "📌 Access log:  $ACCESS_LOG"
echo "✅ Deployment complete"