#!/bin/bash

# 📍 Configuration
TARGET_HOST="root@ip_de_ta_cible"
TARGET_DOCKER_VOLUME_PATH="/var/lib/docker/volumes"
LOCAL_BACKUP_BASE="$HOME/docker_backups"
DATE=$(date +%Y-%m-%d_%Hh%Mm)
BACKUP_DIR="$LOCAL_BACKUP_BASE/$DATE"
MAX_BACKUPS=7  # Nombre de sauvegardes à conserver

# 📁 Création du dossier
mkdir -p "$BACKUP_DIR"

echo "🔄 Sauvegarde Docker [$DATE] depuis $TARGET_HOST..."

# 🔁 Rsync des volumes
rsync -avz --delete -e ssh \
    "$TARGET_HOST:$TARGET_DOCKER_VOLUME_PATH/" \
    "$BACKUP_DIR"

# 🧹 Rotation : suppression des plus anciens backups
cd "$LOCAL_BACKUP_BASE" || exit 1
BACKUPS_COUNT=$(ls -1d 20* | wc -l)

if [ "$BACKUPS_COUNT" -gt "$MAX_BACKUPS" ]; then
    TO_DELETE=$(ls -1d 20* | sort | head -n $(("$BACKUPS_COUNT" - "$MAX_BACKUPS")))
    echo "🗑️  Suppression des anciennes sauvegardes :"
    echo "$TO_DELETE"
    rm -rf $TO_DELETE
fi

echo "✅ Sauvegarde terminée dans : $BACKUP_DIR"

