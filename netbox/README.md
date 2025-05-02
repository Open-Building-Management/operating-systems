# netbox change admin password :

```
/opt/netbox/netbox/manage.py changepassword admin
```

# cloning netbox-docker with alpine/git through portainer

Create a new volume named `netbox-docker-sources`

Create a new git container through portainer UI :
- name : `get-netbox-docker-sources`
- image : `alpine/git`
- Commands & logging > Command > Override : `clone --depth 1 https://github.com/netbox-community/netbox-docker.git /data`
- Volumes > container | `/data`
- Volumes > volume : choose `netbox-docker-sources - local` in the selector
 
We now have the netbox-docker sources in `/var/lib/docker/volumes/netbox-docker-sources/_data` on the server

Stop the docker daemon on the server : `systemctl stop docker`

from the workstation, restore the netbox-docker datas with `restore_some_volumes.sh` from the backup_tools folder of this repo

```
./restore_some_volumes.sh 192.168.1.91 netbox-docker docker_backups/now
```

on the server :

```
systemctl start docker
cd /var/lib/docker/volumes/netbox-docker-sources/_data
docker compose pull
tee docker-compose.override.yml <<EOF
services:
  netbox:
    restart: unless-stopped
    ports:
      - 8888:8080
  netbox-worker:
    restart: unless-stopped
  netbox-housekeeping:
    restart: unless-stopped
  postgres:
    restart: unless-stopped
  redis:
    restart: unless-stopped
  redis-cache:
    restart: unless-stopped
EOF
docker compose -p "netbox-docker" up -d
```

docker should warn about existing volumes and tell to use external: true, but all 6 containers should be up and healthy


```
WARN[0000] volume "netbox-docker_netbox-redis-data" already exists but was not created by Docker Compose. Use `external: true` to use an existing volume 
```

Nota there are some maintenance scripts on the worker, restored from the backup :
```
unit@7186e9196b89:/opt/netbox/netbox$ ls
account   core  extras                  ipam   manage.py  netbox          release.yaml  scripts  templates  translations  utilities       vpn
circuits  dcim  generate_secret_key.py  local  media      project-static  reports       static   tenancy    users         virtualization  wireless
unit@7186e9196b89:/opt/netbox/netbox$ cd scripts
unit@7186e9196b89:/opt/netbox/netbox/scripts$ ls
__init__.py  check_available_models.py  cleanup_history.py  cleanup_orphaned_images.py
```
