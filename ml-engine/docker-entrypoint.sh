#!/bin/sh
set -e
cd /app

# Leftover bind-mount mistake: host path became a directory named *.pt
if [ -d yolov8n-pose.pt ] || [ -d yolov8n-club.pt ]; then
  echo "ERROR: weight path is a DIRECTORY (old Docker bind-mount bug)."
  echo "  On the VPS host run:"
  echo "    docker compose down"
  echo "    sudo rm -rf ml-engine/yolov8n-pose.pt ml-engine/yolov8n-club.pt"
  echo "    # copy real .pt files into ml-engine/, then:"
  echo "    docker compose build --no-cache ml-engine"
  echo "    docker compose up -d"
  exit 1
fi

if [ ! -f yolov8n-pose.pt ]; then
  echo "==> yolov8n-pose.pt missing in image — downloading..."
  python -c "from ultralytics import YOLO; YOLO('yolov8n-pose.pt')"
fi

if [ -f yolov8n-club.pt ]; then
  echo "==> Clubhead weights OK"
else
  echo "==> No yolov8n-club.pt — line+kalman fallback"
fi

exec "$@"
