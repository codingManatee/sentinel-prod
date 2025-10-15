#!/bin/bash

# Read the first argument (e.g., detection, main, or none)
PROFILE=$1

case "$PROFILE" in
  detection)
    echo "🛑 Stopping Detection profile..."
    docker compose --profile detection down
    ;;
  main)
    echo "🛑 Stopping Main profile..."
    docker compose --profile main down
    ;;
  *)
    echo "🛑 Stopping all profiles (Detection + Main)..."
    docker compose --profile detection down
    docker compose --profile main down
    ;;
esac

echo "✅ Done!"
