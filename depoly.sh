#!/bin/bash

# Directory where your repo lives
REPO_DIR="/home/diva/deiva-url-shortner" 

cd "$REPO_DIR" || { echo "Repo directory not found"; exit 1; }

echo "stopping the server"
pkill -f uvicorn 
echo "Server stopped"

echo "Pulling latest changes..."
git pull origin develop
echo "Done!"

pwd
ls

cd app
python3 -m venv venv
source venv/bin/activate

echo "Installing dependencies..."
pip install -r requirements.txt
echo "Done!"

# -------------------------------
# CREATE LOG FILES
# -------------------------------
TIMESTAMP=$(TZ='Asia/Kolkata' date +"%Y-%m-%d_%H-%M")

SERVER_LOG="start_logs/server_$TIMESTAMP.log"
APP_LOG="app_logs/endpoints_$TIMESTAMP.log"

mkdir -p start_logs
mkdir -p app_logs

# -------------------------------
# START UVICORN WITH SPLIT LOGS
# -------------------------------
echo "Starting Uvicorn..."

nohup uvicorn src.main:app \
    --host 0.0.0.0 \
    --port 8000 \
    --reload \
    > "$SERVER_LOG" \
    2> "$APP_LOG" &

echo "Uvicorn started."
echo "Server startup logs → $SERVER_LOG"
echo "API endpoint logs → $APP_LOG"