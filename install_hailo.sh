#!/bin/bash

set -e

DRIVER_PKG="hailort-pcie-driver_4.21.0_all.deb"
RUNTIME_PKG="hailort_4.21.0_arm64.deb"

echo "🔍 Checking for required packages..."
sudo apt update
sudo apt install -y dkms linux-headers-$(uname -r) build-essential

echo "📦 Installing Hailo PCIe driver: $DRIVER_PKG"
sudo dpkg -i "$DRIVER_PKG" || sudo apt --fix-broken install -y

echo "📦 Installing Hailo runtime: $RUNTIME_PKG"
sudo dpkg -i "$RUNTIME_PKG" || sudo apt --fix-broken install -y

echo "🔁 Reloading driver..."
sudo modprobe -r hailo_pci || true
sudo modprobe hailo_pci

echo "✅ Hailo driver and runtime installation complete."
echo "ℹ️  You should see /dev/hailo0 if the board is connected and initialized."
