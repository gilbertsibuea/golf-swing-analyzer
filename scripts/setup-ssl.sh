#!/usr/bin/env bash
# Bootstrap Let's Encrypt for golf.gilbertsibuea.id (Docker nginx + certbot volumes).
# On VPS: cd /opt/projects/golf && ./scripts/setup-ssl.sh
set -euo pipefail

DOMAIN="${DOMAIN:-golf.gilbertsibuea.id}"
EMAIL="${CERTBOT_EMAIL:-admin@gilbertsibuea.id}"
LIVE_REL="live/${DOMAIN}"

cd "$(dirname "$0")/.."

# Resolve compose project volume names (directory name + suffix)
PROJECT="$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')"
# Prefer explicit name from compose: usually <dir>_certbot_certs
CERT_VOL="$(docker volume ls -q | grep -E '_certbot_certs$' | head -1 || true)"
WWW_VOL="$(docker volume ls -q | grep -E '_certbot_www$' | head -1 || true)"

echo "==> Ensure cert volumes exist"
docker compose up -d --no-start nginx certbot 2>/dev/null || true
docker compose create nginx certbot >/dev/null 2>&1 || docker compose up -d --no-deps --no-start nginx
CERT_VOL="$(docker volume ls -q | grep -E '_certbot_certs$' | head -1)"
WWW_VOL="$(docker volume ls -q | grep -E '_certbot_www$' | head -1)"
if [[ -z "${CERT_VOL}" || -z "${WWW_VOL}" ]]; then
  echo "ERROR: certbot volumes not found. Run: docker compose up -d nginx"
  exit 1
fi
echo "    certs: ${CERT_VOL}"
echo "    www:   ${WWW_VOL}"

echo "==> Dummy certs if missing (nginx needs files before first LE issue)"
docker run --rm \
  -v "${CERT_VOL}:/etc/letsencrypt" \
  alpine:3.20 \
  sh -c "
    set -e
    apk add --no-cache openssl >/dev/null
    if [ -s /etc/letsencrypt/${LIVE_REL}/fullchain.pem ] && [ -s /etc/letsencrypt/${LIVE_REL}/privkey.pem ]; then
      echo 'Certs already present'
      exit 0
    fi
    mkdir -p /etc/letsencrypt/${LIVE_REL}
    openssl req -x509 -nodes -newkey rsa:2048 -days 1 \
      -keyout /etc/letsencrypt/${LIVE_REL}/privkey.pem \
      -out /etc/letsencrypt/${LIVE_REL}/fullchain.pem \
      -subj '/CN=${DOMAIN}'
    echo 'Dummy cert created'
  "

echo "==> Start nginx for ACME HTTP-01"
docker compose up -d nginx

echo "==> Clear dummy lineage so Certbot can issue a real cert"
docker run --rm -v "${CERT_VOL}:/etc/letsencrypt" alpine:3.20 \
  sh -c "rm -rf /etc/letsencrypt/live/${DOMAIN} /etc/letsencrypt/archive/${DOMAIN} /etc/letsencrypt/renewal/${DOMAIN}.conf"

echo "==> Request Let's Encrypt certificate"
docker compose run --rm --entrypoint certbot certbot certonly \
  --webroot -w /var/www/certbot \
  -d "${DOMAIN}" \
  --email "${EMAIL}" \
  --agree-tos \
  --no-eff-email \
  --non-interactive \
  --preferred-challenges http

echo "==> Reload nginx"
docker compose exec -T nginx nginx -s reload

echo "==> Start certbot renew loop"
docker compose up -d certbot

echo "==> Verify"
curl -fsS "https://${DOMAIN}/api/health"
echo
echo "OK → https://${DOMAIN}/"
