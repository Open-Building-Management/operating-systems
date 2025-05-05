# netbox change admin password :

```
/opt/netbox/netbox/manage.py changepassword admin
```


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
docker compose -p "netbox-docker" up -d
```

docker should warn about existing volumes and tell to use external: true, but all 6 containers should be up and healthy


```
WARN[0000] volume "netbox-docker_netbox-redis-data" already exists but was not created by Docker Compose. Use `external: true` to use an existing volume 
```

Nota there are some maintenance scripts on the worker, restored from the backup :
```
unit@7186e9196b89:/opt/netbox/netbox/scripts$ ls
__init__.py  check_available_models.py  cleanup_history.py  cleanup_orphaned_images.py
```
