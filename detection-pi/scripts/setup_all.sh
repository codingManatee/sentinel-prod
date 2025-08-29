#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Starting full system setup..."

# Step 1: Install Docker (only if not already installed)
if ! command -v docker &> /dev/null; then
    echo "🐳 Docker not found. Installing Docker..."
    bash "$SCRIPT_DIR/install_docker.sh"
else
    echo "✅ Docker is already installed. Skipping Docker setup."
fi

# Step 2: Install Hailo drivers and runtime
echo "📦 Installing Hailo drivers and runtime..."
bash "$SCRIPT_DIR/install_hailo.sh"

# Step 3: Setup autostart
if [ -f "$SCRIPT_DIR/setup_autostart.sh" ]; then
    echo "🔁 Configuring autostart..."
    bash "$SCRIPT_DIR/setup_autostart.sh"
else
    echo "⚠️ Autostart script not found: $SCRIPT_DIR/setup_autostart.sh"
fi

echo "✅ All setup steps completed successfully."
