#!/bin/sh
set -e
cd /app

# Docker creates a *directory* when a bind-mounted file is missing on the host.
# That silently breaks Ultralytics. Fail fast with a clear message.
for w in yolov8n-pose.pt yolov8n-club.pt; do
  if [ -d "$w" ]; then
    echo "ERROR: $w is a DIRECTORY, not a weight file."
    echo "  Cause: host file was missing when 'docker compose up' ran."
    echo "  Fix on VPS:"
    echo "    docker compose down"
    echo "    sudo rm -rf /path/to/project/ml-engine/$w"
    echo "    scp yolov8n-pose.pt yolov8n-club.pt user@vps:~/.../ml-engine/"
    echo "    docker compose up -d --build"
    exit 1
  fi
done

if [ ! -f yolov8n-pose.pt ]; then
  echo "==> yolov8n-pose.pt missing — downloading via Ultralytics (needs network)..."
  python -c "from ultralytics import YOLO; YOLO('yolov8n-pose.pt')"
fi

if [ -f yolov8n-club.pt ]; then
  echo "==> Clubhead weights found (yolov8n-club.pt)"
else
  echo "==> No yolov8n-club.pt — club tracking falls back to line+kalman"
fi

exec "$@"
