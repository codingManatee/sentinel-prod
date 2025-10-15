#!/bin/bash

# Get the host IP from en0 (Mac network interface)
HOST_IP=$(ipconfig getifaddr en0)

# Check if we actually got an IP
if [ -z "$HOST_IP" ]; then
  echo "❌ Could not determine host IP from en0. Make sure you're connected to a network."
  exit 1
fi

# Read the first argument (e.g., detection, main, or none)
PROFILE=$1

echo "🌐 Using HOST_IP: $HOST_IP"

case "$PROFILE" in
  detection)
    echo "🚀 Starting Detection profile..."
    docker compose --profile detection up -d --env "HOST_IP=$HOST_IP"
    ;;
  main)
    echo "🚀 Starting Main profile..."
    docker compose --profile main up -d --env "HOST_IP=$HOST_IP"
    ;;
  *)
    echo "🚀 Starting both Detection and Main profiles..."
    docker compose --profile detection up -d --env "HOST_IP=$HOST_IP"
    docker compose --profile main up -d --env "HOST_IP=$HOST_IP"
    ;;
esac

echo "✅ Done!"
