#!/bin/bash

set -e

DRIVER_PKG="hailort-pcie-driver_4.21.0_all.deb"
RUNTIME_PKG="hailort_4.21.0_arm64.deb"

echo "🔍 Updating package lists and installing prerequisites..."
sudo apt-get update
sudo apt-get install -y dkms linux-headers-$(uname -r) build-essential \
    ca-certificates curl gnupg lsb-release

echo "🐳 Setting up Docker apt repository and installing Docker..."

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/raspbian/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/raspbian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "✅ Docker installation complete."

echo "📦 Installing Hailo PCIe driver: $DRIVER_PKG"
sudo dpkg -i "$DRIVER_PKG" || sudo apt --fix-broken install -y

echo "📦 Installing Hailo runtime: $RUNTIME_PKG"
sudo dpkg -i "$RUNTIME_PKG" || sudo apt --fix-broken install -y

echo "🔁 Reloading hailo_pci kernel module..."
sudo modprobe -r hailo_pci || true
sudo modprobe hailo_pci

echo "⏳ Waiting a few seconds for device initialization..."
sleep 3

echo "🔍 Running hailortcli fw-control identify to check installation..."
if command -v hailortcli &> /dev/null
then
    hailortcli fw-control identify
    if [ $? -eq 0 ]; then
        echo "✅ Hailo driver and runtime are installed and working."
    else
        echo "❌ hailortcli fw-control identify failed. Check driver/runtime installation."
        exit 1
    fi
else
    echo "❌ hailortcli command not found. Check if the runtime installed correctly."
    exit 1
fi
