# netbox change admin password :

`/opt/netbox/netbox/manage.py changepassword admin`

# restore volumes

from the workstation :

Stop the docker daemon : `ssh root@ip_target "systemctl stop docker"`

from the workstation, restore the netbox-docker datas with `restore_some_volumes.sh` from the backup_tools folder of this repo

```
./restore_some_volumes.sh ip_target netbox-docker docker_backups/now
```
Restart the docker daemon : ssh root@ip_target "systemctl start docker"

# start the netbox compose stack

ssh to the server and run :

```
cd /var/lib/docker/volumes/netbox-docker-sources/_data
docker compose pull
docker compose -p "netbox-docker" up -d
```

docker should warn about existing volumes and tell to use external: true, but all containers should be up and healthy


```
WARN[0000] volume "netbox-docker_netbox-redis-data" already exists but was not created by Docker Compose. Use `external: true` to use an existing volume 
```

There are some maintenance scripts for the `netbox-docker_netbox-scripts-files` worker
