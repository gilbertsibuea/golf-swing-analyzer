#!/bin/sh
set -e
cd /app

if [ ! -f yolov8n-pose.pt ]; then
  echo "==> yolov8n-pose.pt missing — downloading via Ultralytics..."
  python -c "from ultralytics import YOLO; YOLO('yolov8n-pose.pt')"
fi

if [ -f yolov8n-club.pt ]; then
  echo "==> Clubhead weights found (yolov8n-club.pt)"
else
  echo "==> No yolov8n-club.pt — club tracking falls back to line+kalman"
fi

exec "$@"
