#!/bin/bash

# Detect host IP (works on macOS and Raspberry Pi)
if [[ "$OSTYPE" == "darwin"* ]]; then
  HOST_IP=$(ipconfig getifaddr en0)
else
  HOST_IP=$(hostname -I | awk '{print $1}')
fi

# Check if we actually got an IP
if [ -z "$HOST_IP" ]; then
  echo "❌ Could not determine host IP. Make sure you're connected to a network."
  exit 1
fi

# Move to project root (where docker-compose.yml is)
cd "$(dirname "$0")/.." || exit

# Read the first argument (e.g., detection, main, or none)
PROFILE=$1

echo "🌐 Using HOST_IP: $HOST_IP"

case "$PROFILE" in
  detection)
    echo "🚀 Starting Detection profile..."
    HOST_IP=$HOST_IP docker compose --profile detection up -d
    ;;
  main)
    echo "🚀 Starting Main profile..."
    HOST_IP=$HOST_IP docker compose --profile main up -d
    ;;
  *)
    echo "🚀 Starting both Detection and Main profiles..."
    HOST_IP=$HOST_IP docker compose --profile detection up -d
    HOST_IP=$HOST_IP docker compose --profile main up -d
    ;;
esac

echo "✅ Done!"
