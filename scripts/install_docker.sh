#!/bin/bash

set -e

echo "🐳 Setting up Docker apt repository and installing Docker..."

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "✅ Docker installation complete."

if ! getent group docker > /dev/null; then
  echo "⚙️  Creating docker group..."
  sudo groupadd docker
fi

echo "➕ Adding $USER to docker group..."
sudo usermod -aG docker "$USER"

echo "✅ User $USER added to docker group. You may need to log out and back in (or run 'newgrp docker') for this to take effect."
