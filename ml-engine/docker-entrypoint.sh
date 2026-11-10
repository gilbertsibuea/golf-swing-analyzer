#!/bin/sh
set -e
cd /app

# Leftover bind-mount mistake: host path became a directory named *.pt
if [ -d yolov8n-pose.pt ]; then
  echo "ERROR: weight path is a DIRECTORY (old Docker bind-mount bug)."
  echo "  On the VPS host run:"
  echo "    docker compose down"
  echo "    sudo rm -rf ml-engine/yolov8n-pose.pt"
  echo "    # copy real .pt file into ml-engine/, then:"
  echo "    docker compose build --no-cache ml-engine"
  echo "    docker compose up -d"
  exit 1
fi

if [ ! -f yolov8n-pose.pt ]; then
  echo "==> yolov8n-pose.pt missing in image — downloading..."
  python -c "from ultralytics import YOLO; YOLO('yolov8n-pose.pt')"
fi

echo "==> Pose weights OK"
exec "$@"
