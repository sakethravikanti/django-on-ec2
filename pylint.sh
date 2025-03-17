!/bin/bash



# Enforce strict error handling
set -euxo pipefail  

# Define variables
APP_DIR="/home/ubuntu/todo-app"
PYTHON_BIN="/usr/bin/python3"
APP_FILE="app.py"

# Navigate to the application directory
cd "$APP_DIR"

# Start the application
echo "Starting application..."
nohup $PYTHON_BIN "$APP_FILE" > app.log 2>&1 &


echo "✅ Deployment successful!"