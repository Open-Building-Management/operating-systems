# 📘 NetBox Deployment with HTTPS (Let's Encrypt via Gandi DNS)

This document summarizes the setup of a secure NetBox instance using Docker Compose, Nginx as a reverse proxy, and automatic TLS certificate management via `acme.sh` and Gandi's DNS API.

---

## 📦 Docker Compose Stack

### 🛠️ Services

- **Official NetBox containers.** from https://github.com/netbox-community/netbox-docker
- **`nginx`**: reverse proxy providing HTTPS on port `8443`.
- **`acme`**: Alpine container managing Let's Encrypt certificates with DNS challenge (via Gandi) and reloading Nginx when renewed.

### 🛠️ Volumes

- **`dyndns_data`**: Gandi token, dns and acme scripts, certs, etc.
- **`netbox-docker-src`**: netbox-docker source code (cloned through git) plus docker-compose.override.yml and nginx.conf
---

Create a new volume named `netbox-docker`

Create a new git container through portainer UI :
- name : `get-netbox-docker-src`
- image : `alpine/git`
- Commands & logging > Command > Override : `clone --depth 1 https://github.com/netbox-community/netbox-docker.git /data`
- Volumes > container | `/data`
- Volumes > volume : choose `netbox-docker - local` in the selector
 
We now have the netbox-docker sources in `/var/lib/docker/volumes/netbox-docker/_data` on the server

## 🌍 Required Environment Variables

For the `netbox` container, set the following environment variables :

```env
ALLOWED_HOSTS=netbox.dromotherm.com localhost
CSRF_TRUSTED_ORIGINS=https://netbox.dromotherm.com:8443
```

> 🔐 These are essential for proper CSRF validation and host header checking in Django when served behind a proxy.

---

## 🔁 `acme.sh` Certificate Management

The `acme` container runs a shell script (`acme_run.sh`) that:

1. Installs `acme.sh` if not present.
2. Uses the Gandi DNS API for issuing certs.
3. Automatically reloads Nginx via `docker exec nginx nginx -s reload`.
4. Runs in a loop, checking every 24h (`RENEW_INTERVAL=86400`).

Make sure the following environment variables are set in the `acme` container:

```env
DOMAIN=netbox.dromotherm.com
NGINX_CONTAINER_NAME=nginx
RENEW_INTERVAL=86400
```

Also ensure the Gandi LiveDNS API token is stored in:

```text
/data/gandi_ddns_token
```

And the container mounts the Docker socket:

```yaml
- /var/run/docker.sock:/var/run/docker.sock
```

---

## ✅ Key Takeaways

- ✅ No need to modify `netbox_docker/configration/configuration.py` manually.
- ✅ HTTPS works on custom port (`8443`).
- ✅ `ALLOWED_HOSTS` and `CSRF_TRUSTED_ORIGINS` are handled via env vars.
- ✅ Self-renewing, automated TLS setup using DNS challenge.
- ✅ Reusable approach for other reverse-proxied services.

---
