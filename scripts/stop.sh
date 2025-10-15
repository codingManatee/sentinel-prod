#!/bin/bash

# Move to project root (where docker-compose.yml is)
cd "$(dirname "$0")/.." || exit

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
    echo "🛑 Stopping all profiles..."
    docker compose --profile detection down
    docker compose --profile main down
    ;;
esac

echo "✅ Done!"
