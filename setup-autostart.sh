#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_NAME="docker-compose-sentinel-web-app"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

echo "📁 Using current directory for Docker Compose: $SCRIPT_DIR"

if [ ! -f "$SCRIPT_DIR/docker-compose.yaml" ]; then
  echo "❌ Error: docker-compose.yaml not found in $SCRIPT_DIR"
  exit 1
fi

echo "🛠️ Creating systemd service file: $SERVICE_FILE"

sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Local Docker Compose App Service
Requires=docker.service
After=docker.service

[Service]
User=admin
Type=oneshot
WorkingDirectory=${SCRIPT_DIR}
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

echo "🔄 Reloading systemd daemon..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

echo "✅ Enabling service to start at boot..."
sudo systemctl enable "$SERVICE_NAME"

echo "🚀 Starting service now..."
sudo systemctl start "$SERVICE_NAME"

echo "🎉 Service '${SERVICE_NAME}' is now running and will auto-start on reboot."
