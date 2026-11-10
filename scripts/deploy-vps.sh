#!/usr/bin/env bash
# Deploy SwingLab to VPS: rsync sources (+ weights) then build & restart compose.
# Prunes Docker build cache after deploy so disk does not balloon (PyTorch layers).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VPS_HOST="${VPS_HOST:-root@203.194.113.61}"
VPS_PATH="${VPS_PATH:-/opt/projects/golf}"

cd "$ROOT"

if [[ ! -f ml-engine/yolov8n-pose.pt ]]; then
  echo "ERROR: ml-engine/yolov8n-pose.pt missing (required for image bake)."
  exit 1
fi

echo "==> Rsync → ${VPS_HOST}:${VPS_PATH}"
rsync -avz --delete \
  --exclude node_modules \
  --exclude venv \
  --exclude .git \
  --exclude .hallmark \
  --exclude '**/__pycache__' \
  --exclude ml-engine/datasets \
  --exclude ml-engine/output \
  --exclude ml-engine/video \
  --exclude ml-engine/yolov8n.pt \
  --exclude ml-engine/yolov8n-club.pt \
  --exclude frontend/.svelte-kit \
  --exclude frontend/build \
  ./ "${VPS_HOST}:${VPS_PATH}/"

echo "==> Build & restart on VPS"
ssh "${VPS_HOST}" "cd ${VPS_PATH} && \
  (test -f .env || cp .env.example .env) && \
  ls -lh ml-engine/yolov8n-pose.pt && \
  file ml-engine/yolov8n-pose.pt && \
  docker compose up -d --build && \
  echo '==> Prune build cache (keeps running images)' && \
  docker builder prune -af && \
  docker image prune -f && \
  docker compose ps && \
  df -h / && \
  curl -fsS http://127.0.0.1/api/health || true"

echo "==> Done. Open http://203.194.113.61/"
