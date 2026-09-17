#!/usr/bin/env bash
# Start Label Studio preconfigured for datasets/clubhead/to_label
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PYTHON="${ROOT}/venv/bin/python"
if [[ ! -x "$PYTHON" ]]; then
  PYTHON="$(command -v python3)"
fi

export LABEL_STUDIO_LOCAL_FILES_SERVING_ENABLED=true
export LABEL_STUDIO_LOCAL_FILES_DOCUMENT_ROOT="${ROOT}/datasets/clubhead"

echo ""
echo "=== Clubhead Label Studio ==="
echo "1) Install once: pipx install label-studio"
echo ""
echo "2) Create project → Settings → Labeling Interface → paste:"
echo "     ${ROOT}/datasets/clubhead/label_studio_config.xml"
echo ""
echo "3) Import IMAGES (not JSON):"
echo "     ${ROOT}/datasets/clubhead/to_label/*.jpg"
echo "   Do NOT import label_studio_tasks.json — /data/local-files/ returns 404"
echo "   unless Cloud Storage is enabled in Label Studio settings."
echo ""
echo "4) After labeling: Export → JSON, then:"
echo "     cd ${ROOT}"
echo "     ./venv/bin/python scripts/import_label_studio_export.py ~/Downloads/project-*.json"
echo "     ./venv/bin/python scripts/split_club_labels.py"
echo "     ./venv/bin/python scripts/train_clubhead.py --epochs 100"
echo ""
echo "DOCUMENT_ROOT=${LABEL_STUDIO_LOCAL_FILES_DOCUMENT_ROOT}"
echo "LOCAL_FILES_SERVING=${LABEL_STUDIO_LOCAL_FILES_SERVING_ENABLED}"
echo ""

if command -v label-studio >/dev/null 2>&1; then
  exec label-studio start --host 127.0.0.1 --port 8080
fi

echo "label-studio not on PATH — install it, then re-run this script or start manually."
exit 0
