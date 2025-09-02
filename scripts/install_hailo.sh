#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRIVER_PKG="$SCRIPT_DIR/../resources/drivers/hailort-pcie-driver_4.21.0_all.deb"
RUNTIME_PKG="$SCRIPT_DIR/../resources/drivers/hailort_4.21.0_arm64.deb"

echo "🔍 Updating package lists and installing prerequisites..."
sudo apt-get update
sudo apt-get install -y dkms linux-headers-$(uname -r) build-essential \
    ca-certificates curl gnupg lsb-release

# Optional check
if ! command -v docker &> /dev/null; then
    echo "⚠️ Docker is not installed. Run scripts/install_docker.sh first."
    exit 1
fi

echo "📦 Installing Hailo PCIe driver: $DRIVER_PKG"
sudo dpkg -i "$DRIVER_PKG" || sudo apt --fix-broken install -y

echo "📦 Installing Hailo runtime: $RUNTIME_PKG"
sudo dpkg -i "$RUNTIME_PKG" || sudo apt --fix-broken install -y

echo "⚙️ Setting Hailo PCIe driver options..."
echo "options hailo_pci force_desc_page_size=256" | sudo tee /etc/modprobe.d/hailo_pci.conf

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
