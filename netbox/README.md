# 📘 NetBox Deployment with HTTPS (Let's Encrypt via Gandi DNS)

Setup of a secure NetBox instance using Docker Compose, Nginx as a reverse proxy, and automatic TLS certificate management via `acme.sh` and Gandi's DNS API.

# data volumes

The machine used to configure the server is called the **development station**

The following assumes the volumes to upload to the server are in `~/docker_backups/now` on your development station

Adapt the commands if the volumes are somewhere else on your development station

## initiate a new tree with mandatory files

From the `operating-systems/netbox` folder :

`./install.sh now` 

Be sure the Gandi LiveDNS API token is filled in :

```text
~/docker_backups/now/dyndns_data/_data/gandi_ddns_token
```

## use an existing backup of your docker volumes

Be sure you have a netbox-docker volume with the files from the netbox-docker github repository

## restore all volumes automatically to the target server

From the workstation, still in the `operating-systems/netbox` folder :

- stop the docker daemon : `ssh root@ip_target "systemctl stop docker"`

- restore with rsync :

```
../backup_tools/restore_some_volumes.sh ip_target netbox-docker docker_backups/now
../backup_tools/restore_some_volumes.sh ip_target dyndns_data docker_backups/now
```
- restart the docker daemon : `ssh root@ip_target "systemctl start docker"`

## restore manually, volume per volume

From the parent folder of the volume to be restored :

```
rsync -avz -e ssh netbox-docker "root@ip_target:/var/lib/docker/volumes"
```

# start the netbox compose stack

ssh to the server and run :

```
cd /var/lib/docker/volumes/netbox-docker/_data
docker compose pull
docker compose -p "netbox-docker" up -d
```

docker should warn about existing volumes and tell to use external: true, but all containers should be up and healthy


```
WARN[0000] volume "netbox-docker_netbox-redis-data" already exists but was not created by Docker Compose. Use `external: true` to use an existing volume 
```

There are some maintenance scripts for the `netbox-docker_netbox-scripts-files` worker

identify which user run the netbox container :
```
docker compose -p "netbox-docker" exec netbox sh -c 'id -u && id -g'
999
0
```

Adapt the permissions on the media folder :
```
sudo chown -R 999:999 /srv/docker/netbox/media/
```
---

# netbox change admin password :

`/opt/netbox/netbox/manage.py changepassword admin`
