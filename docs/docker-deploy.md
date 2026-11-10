# Deploy with Docker (VPS)

Stack:

| Service   | Role                          | Internal |
|-----------|-------------------------------|----------|
| nginx     | Public entry (`:80` / `:443`) | → frontend + backend |
| frontend  | SvelteKit (adapter-node)      | `:3000` |
| backend   | Go Fiber API                  | `:3000` |
| ml-engine | FastAPI + YOLOv8              | `:8000` |

Browser → `https://golf.gilbertsibuea.id/` → nginx  
`/api/*` → backend → ml-engine  
`/outputs/*` → backend → ml-engine static files  

TLS: Let's Encrypt via `certbot` + webroot (see § HTTPS below). 

## 1. Prerequisites on VPS

- Docker Engine + Compose plugin
- At least **4 GB RAM** recommended (YOLO + OpenCV on CPU)
- Copy YOLO weights onto the VPS (they are gitignored)

## 2. Copy project + weights onto the VPS

Weights are **baked into the ML image at build time** (not bind-mounted). They must be real files under `ml-engine/` before `docker compose build`.

```bash
# Laptop → VPS
rsync -avz --exclude node_modules --exclude venv --exclude .git \
  ./golf-swing-analyzer/ user@YOUR_VPS:~/golf-swing-analyzer/

scp ml-engine/yolov8n-pose.pt \
  user@YOUR_VPS:~/golf-swing-analyzer/ml-engine/
```

On the VPS, confirm they are files (not directories):

```bash
ls -lh ml-engine/*.pt
file ml-engine/yolov8n-pose.pt   # should mention Zip/data, NOT "directory"
```

## 3. Configure

```bash
cd ~/golf-swing-analyzer
cp .env.example .env
# optional: edit HTTP_PORT=8080 if 80 is taken
```

## 4. Build & run

```bash
docker compose up -d --build
docker compose ps
docker compose logs -f ml-engine   # first boot can take a while
```

Open: `https://golf.gilbertsibuea.id/` (or `http://YOUR_VPS_IP/` over plain HTTP)

Health:

```bash
curl -s https://golf.gilbertsibuea.id/api/health
curl -s http://127.0.0.1/api/health   # via nginx → backend
docker compose exec ml-engine curl -s http://127.0.0.1:8000/health
```

## HTTPS (Let's Encrypt)

DNS A record must point at the VPS (`golf.gilbertsibuea.id` → server IP). Then:

```bash
cd /opt/projects/golf   # or your VPS_PATH
chmod +x scripts/setup-ssl.sh
./scripts/setup-ssl.sh
# optional: CERTBOT_EMAIL=you@example.com ./scripts/setup-ssl.sh
```

This creates dummy certs → starts nginx → issues a real cert → reloads nginx → starts the renew loop.

## 5. Useful commands

```bash
docker compose logs -f
docker compose restart
docker compose down
docker compose down -v   # also remove annotated-video volume
```

## 6. Notes

- Analysis can take several minutes on CPU; nginx `proxy_read_timeout` is 300s.
- Latency wins (quality preserved): batched YOLO, single H.264 pass, slowmo via ffmpeg `setpts`, score before render.
- Annotated videos persist in Docker volume `ml_output`.
- Inference only needs `yolov8n-pose.pt` (clubhead tracking was removed from the MVP).
- HTTPS is terminated at nginx with Let's Encrypt (`scripts/setup-ssl.sh`).
- On a 2GB VPS, `ml-engine` `mem_limit` is `1536m` — prefer ≥4GB RAM for comfortable runs.

## 7. Disk size (why rebuilds look huge)

| What | Typical size | Notes |
|------|--------------|--------|
| Project on disk | ~100–150 MB | Code + `yolov8n-pose.pt` (~7 MB). |
| `golf-swing-ml` image | ~3 GB | **PyTorch CPU + ultralytics** — this is normal for YOLO. |
| Docker **build cache** | can grow to **8–12 GB** | Intermediate layers from `pip install torch`. Reclaim with prune. |

After each deploy, prune cache (also done by `scripts/deploy-vps.sh`):

```bash
docker builder prune -af
docker image prune -f
df -h /
```

If disk spikes after rebuild, it is almost always Docker build cache (PyTorch layers), not app data.

## Troubleshooting

**`ml-engine` unhealthy / crash**

1. See logs:
   ```bash
   docker compose logs ml-engine --tail 100
   ```
2. Check weights are **files**, not directories:
   ```bash
   ls -lh ml-engine/*.pt
   file ml-engine/yolov8n-pose.pt
   # must say "Zip archive" / data — NOT "directory"
   ```
   If Docker created empty dirs (host file was missing at first `up`):
   ```bash
   docker compose down
   sudo rm -rf ml-engine/yolov8n-pose.pt
   # scp real yolov8n-pose.pt back into ml-engine/
   docker compose up -d --build
   ```
3. Low RAM (OOM kill): VPS needs ~2–4 GB free. Check `dmesg | tail` / `docker inspect` ExitCode 137.
4. Health: `curl -s http://127.0.0.1:8000/health` inside the container — expect `"status":"ok"`. `"ready":true` after YOLO finishes loading.

**Upload 502**  
Backend cannot reach ML: ensure service name is `ml-engine` and healthcheck passed.

**Images 404 for videos**  
Confirm nginx proxies `/outputs/` and file exists in the `ml_output` volume.
