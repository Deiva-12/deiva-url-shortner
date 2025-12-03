#!/bin/bash

# Directory where your repo lives
REPO_DIR="/home/diva/deiva-url-shortner" 

# Move into the repo directory
cd "$REPO_DIR" || { echo "Repo directory not found"; exit 1; }

# Fetch and pull latest changes
echo "Pulling latest changes..."
git pull origin develop   # change 'main' to 'master' or another branch if needed

echo "Done!"

# printing present working directory

pwd

#listing 

ls

#installing requirements and changing directory
cd app
python3 -m venv venv
source venv/bin/activate
echo "Installing dependencies..."
pip install -r requirements.txt
echo "Done!"

#running uvicorn server 

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
mkdir -p start_logs

# Server startup logs
SERVER_LOG="start_logs/uvicorn_server_${TIMESTAMP}.log"

# Endpoint logs (each API request)
ENDPOINT_LOG="start_logs/endpoints_${TIMESTAMP}.log"

echo "Starting Uvicorn with separate logs..."

# Start server logs
nohup uvicorn src.main:app \
    --host 0.0.0.0 \
    --port 8000 \
    --reload \
    --no-access-log > "$SERVER_LOG" 2>&1 &

# Start a second Uvicorn process ONLY for access logs (works reliably)
nohup uvicorn src.main:app \
    --host 0.0.0.0 \
    --port 8000 \
    --reload \
    --access-log > "$ENDPOINT_LOG" 2>&1 &
echo "Uvicorn started in background. Logs: $LOGFILE"