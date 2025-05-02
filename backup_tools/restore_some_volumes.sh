#!/bin/bash

TARGET_IP="192.168.1.91"
PATTERN="netbox-docker"
BACKUP_DIR_IN_HOME="docker_backups/now"
if [ $1 ] && [ $2 ] && [ $3 ]; then
  TARGET_IP=$1
  PATTERN=$2
  BACKUP_DIR_IN_HOME=$3
fi

# Variables
TARGET_HOST="root@$TARGET_IP"
TARGET_DOCKER_VOLUME_PATH="/var/lib/docker/volumes"
LOCAL_BACKUP_DIR="$HOME/$BACKUP_DIR_IN_HOME"

echo "target host is $TARGET_HOST"
echo "volume pattern is $PATTERN"
echo "files to restore are in $LOCAL_BACKUP_DIR"

read -p "Press enter to continue"

# Check
if [ ! -d "$LOCAL_BACKUP_DIR" ]; then
  echo "❌ Inexisting backup folder : $LOCAL_BACKUP_DIR"
  exit 1
fi


echo "♻️ Restoring docker volumes with pattern $PATTERN into $TARGET_HOST..."
for subfolder in "$LOCAL_BACKUP_DIR"/*/; do
  if [[ $(basename "$subfolder") == *"$PATTERN"* ]]; then
    echo "Sous-dossier trouvé: $subfolder"
    subfolder_name="$(basename "$subfolder")"
    rsync -avz -e ssh $subfolder "$TARGET_HOST:$TARGET_DOCKER_VOLUME_PATH/$subfolder_name"
  fi
done

echo "✅ All volumes restored."
