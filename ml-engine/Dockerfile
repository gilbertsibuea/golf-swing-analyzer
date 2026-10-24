FROM python:3.12-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# OpenCV / video encode deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    libgomp1 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# CPU PyTorch first (smaller than default CUDA wheel), then app deps
COPY requirements.txt .
RUN pip install --upgrade pip \
    && pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu \
    && pip install -r requirements.txt

COPY . .

# Fail the build early if pose weights were not present in the build context
RUN mkdir -p /app/output \
    && chmod +x /app/docker-entrypoint.sh \
    && if [ ! -f /app/yolov8n-pose.pt ]; then \
         echo "ERROR: ml-engine/yolov8n-pose.pt missing at build time."; \
         echo "Copy the file into ml-engine/ before: docker compose build"; \
         exit 1; \
       fi \
    && ls -lh /app/yolov8n*.pt

EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=5 \
  CMD curl -fsS http://127.0.0.1:8000/health || exit 1

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
