#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SERVICE_NAME="docker-compose-sentinel-web-app"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

echo "📁 Using project root for Docker Compose: $PROJECT_ROOT"

if [ ! -f "$PROJECT_ROOT/docker-compose.yaml" ]; then
  echo "❌ Error: docker-compose.yaml not found in $PROJECT_ROOT"
  exit 1
fi

echo "🛠️ Creating systemd service file: $SERVICE_FILE"

sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Sentinel Web App Docker Compose Service
Requires=docker.service
After=docker.service

[Service]
User=admin
WorkingDirectory=${PROJECT_ROOT}
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
RemainAfterExit=yes
Type=oneshot

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
