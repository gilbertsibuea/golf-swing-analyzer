# Deploy with Docker (VPS)

Stack:

| Service   | Role                          | Internal |
|-----------|-------------------------------|----------|
| nginx     | Public entry (`:80`)          | → frontend + backend |
| frontend  | SvelteKit (adapter-node)      | `:3000` |
| backend   | Go Fiber API                  | `:3000` |
| ml-engine | FastAPI + YOLOv8              | `:8000` |

Browser → `http://YOUR_VPS/` → nginx  
`/api/*` → backend → ml-engine  
`/outputs/*` → backend → ml-engine static files  

## 1. Prerequisites on VPS

- Docker Engine + Compose plugin
- At least **4 GB RAM** recommended (YOLO + OpenCV on CPU)
- Copy YOLO weights onto the VPS (they are gitignored)

## 2. Copy project + weights

```bash
# On your laptop (example)
rsync -avz --exclude node_modules --exclude venv --exclude .git \
  ./golf-swing-analyzer/ user@YOUR_VPS:~/golf-swing-analyzer/

# Weights (required for pose; club optional but recommended)
scp ml-engine/yolov8n-pose.pt user@YOUR_VPS:~/golf-swing-analyzer/ml-engine/
scp ml-engine/yolov8n-club.pt user@YOUR_VPS:~/golf-swing-analyzer/ml-engine/
```

If `yolov8n-pose.pt` is missing, Ultralytics may download it on first start (needs outbound HTTPS).

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

Open: `http://YOUR_VPS_IP/` (or `http://YOUR_VPS_IP:$HTTP_PORT`)

Health:

```bash
curl -s http://127.0.0.1/api/health   # via nginx → backend
docker compose exec ml-engine curl -s http://127.0.0.1:8000/health
```

## 5. Useful commands

```bash
docker compose logs -f
docker compose restart
docker compose down
docker compose down -v   # also remove annotated-video volume
```

## 6. Notes

- Analysis can take several minutes on CPU; nginx `proxy_read_timeout` is 300s.
- Annotated videos persist in Docker volume `ml_output`.
- Do **not** ship `datasets/` / Label Studio training data to the VPS — inference only needs `*.pt`.
- For HTTPS: put Caddy/Certbot or Cloudflare in front of nginx, or replace nginx with a TLS-terminating reverse proxy.

## Troubleshooting

**`ml-engine` unhealthy / crash**  
Check weights mounts: `ls -lh ml-engine/*.pt` on the host.  
`docker compose logs ml-engine`

**Upload 502**  
Backend cannot reach ML: ensure service name is `ml-engine` and healthcheck passed.

**Images 404 for videos**  
Confirm nginx proxies `/outputs/` and file exists in the `ml_output` volume.
