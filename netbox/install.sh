#!/bin/sh
set -e

GIT_NETBOX_DOCKER="https://github.com/netbox-community/netbox-docker"
# target
TARGET_DIR="$HOME/docker_backups/${1-now}"

# --dry-run simulation
DRYRUN=""
if [ "$2" = "--dry-run" ]; then
  DRYRUN="--dry-run"
  echo "[INFO] Dry-run simulation - no modification applied."
fi

# Create target if needed
mkdir -p "$TARGET_DIR"

# Cloning netbox-docker if needed
if [ -d "$TARGET_DIR/netbox-docker/_data/.git" ]; then
  echo "[INFO] $TARGET_DIR/netbox-docker/_data already a git folder"
else
  git clone "$GIT_NETBOX_DOCKER" "$TARGET_DIR/netbox-docker/_data"
  echo "[INFO] netbox-docker sources cloned in $TARGET_DIR/netbox-docker/_data..."
fi

# Synchroniser les répertoires dans le répertoire cible
rsync -av $DRYRUN ./dyndns_data/       "$TARGET_DIR/dyndns_data/"
rsync -av $DRYRUN ./netbox-docker/     "$TARGET_DIR/netbox-docker/"
rsync -av $DRYRUN ./netbox-docker_netbox-scripts-files/ "$TARGET_DIR/netbox-docker_netbox-scripts-files/"

echo "[INFO] Synchronisation terminée dans $TARGET_DIR"

