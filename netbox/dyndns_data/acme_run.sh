#!/bin/sh
set -e

DOMAIN=${DOMAIN:-netbox.dromotherm.com}
NGINX_CONTAINER=${NGINX_CONTAINER:-nginx}
RENEW_INTERVAL=${RENEW_INTERVAL:-86400}  # 24h
CERT_DIR=/data
TOKEN_FILE=/data/gandi_ddns_token
ROOT=/root/.acme.sh
EMAIL="alexandrep.cuer@gmail.com"

if ! command -v git >/dev/null; then
    echo "[INFO] installing requirements"
    apk add --no-cache git openssl socat curl ca-certificates
fi

# Cloning acme.sh
if [ ! -d "/acme.sh" ]; then
  git clone https://github.com/acmesh-official/acme.sh.git /acme.sh
  cd /acme.sh
  ./acme.sh --install -m "$EMAIL"
fi

if [ -f "$TOKEN_FILE" ]; then
  export GANDI_LIVEDNS_TOKEN=$(cat "$TOKEN_FILE")
else
  echo "[ERROR] No (Gandi) Token in $TOKEN_FILE"
  exit 1
fi

# Force Let's Encrypt
$ROOT/acme.sh --set-default-ca --server letsencrypt

if [ ! -f "$CERT_DIR/fullchain.cer" ] || [ ! -f "$CERT_DIR/$DOMAIN.key" ]; then
  echo "[INFO] NO CERTS, launching initial processing"
  $ROOT/acme.sh --issue --dns dns_gandi_livedns -d "$DOMAIN"
  $ROOT/acme.sh --install-cert -d "$DOMAIN" \
    --key-file "$CERT_DIR/$DOMAIN.key" \
    --fullchain-file "$CERT_DIR/$DOMAIN-fullchain.cer" \
    --reloadcmd "docker exec $NGINX_CONTAINER nginx -s reload || true"
fi

while true; do
  if ! $ROOT/acme.sh --renew -d "$DOMAIN" \
    --key-file "$CERT_DIR/$DOMAIN.key" \
    --fullchain-file "$CERT_DIR/$DOMAIN-fullchain.cer" \
    --reloadcmd "docker exec $NGINX_CONTAINER nginx -s reload || true"; then
    echo "[WARN] RENEWAL PROCESS SKIPPED :-)"
  else
    echo "[INFO] CERTS RENEWED"
  fi
  echo "SLEEPING FOR ${RENEW_INTERVAL} SECONDS..."
  sleep "$RENEW_INTERVAL"
done
