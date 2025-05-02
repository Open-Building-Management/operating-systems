#!/bin/bash

SERVER_IP="192.168.1.91"
if [ $1 ]; then
  SERVER_IP=$1
fi

# Variables
TARGET_HOST="root@$SERVER_IP"
TARGET_DOCKER_VOLUME_PATH="/var/lib/docker/volumes"
LOCAL_BACKUP_DIR="$HOME/docker_backups/$(date +%Y-%m-%d_%Hh%Mm%Ss)"

# Crée le dossier local de sauvegarde
mkdir -p "$LOCAL_BACKUP_DIR"

echo "🔄 Début de la sauvegarde des volumes Docker depuis $TARGET_HOST..."

# Rsync des volumes
rsync -avz -e ssh \
    --delete \
    "$TARGET_HOST:$TARGET_DOCKER_VOLUME_PATH/" \
    "$LOCAL_BACKUP_DIR"

echo "✅ Sauvegarde terminée dans : $LOCAL_BACKUP_DIR"
