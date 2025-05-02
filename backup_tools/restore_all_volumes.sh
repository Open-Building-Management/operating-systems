#!/bin/bash

# Variables
TARGET_HOST="root@ip_de_ta_cible"
TARGET_DOCKER_VOLUME_PATH="/var/lib/docker/volumes"
LOCAL_BACKUP_DIR="$HOME/docker_backups/2025-04-29_10h00m00s"  # Remplace par le bon dossier

# Vérification
if [ ! -d "$LOCAL_BACKUP_DIR" ]; then
  echo "❌ Dossier de sauvegarde introuvable : $LOCAL_BACKUP_DIR"
  exit 1
fi

echo "♻️ Restauration des volumes Docker vers $TARGET_HOST..."

# Rsync de la sauvegarde vers la cible
rsync -avz -e ssh \
    "$LOCAL_BACKUP_DIR/" \
    "$TARGET_HOST:$TARGET_DOCKER_VOLUME_PATH"

echo "✅ Restauration terminée."
