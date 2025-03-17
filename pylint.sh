#!/bin/bash

# Enforce strict error handling
set -euxo pipefail  

# Define variables
APP_DIR="/home/ubuntu/todo-app"
VENV_DIR="$APP_DIR/venv"
UVICORN_CMD="$VENV_DIR/bin/uvicorn"

# Navigate to the application directory
cd "$APP_DIR"

# Activate the virtual environment
source "$VENV_DIR/bin/activate"

# Stop any existing Uvicorn process
pkill -f "uvicorn" || true

# Start Uvicorn server
echo "Starting Django app with Uvicorn..."
nohup $UVICORN_CMD myproject.asgi:application --host 0.0.0.0 --port 8000 > app.log 2>&1 &

echo "✅ Deployment successful!"
