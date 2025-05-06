# 📘 NetBox Deployment with HTTPS (Let's Encrypt via Gandi DNS)

This document summarizes the setup of a secure NetBox instance using Docker Compose, Nginx as a reverse proxy, and automatic TLS certificate management via `acme.sh` and Gandi's DNS API.


`./install.sh now` updates the relevant files in an existing backup that you already have on `~/docker_backups/now`

Be sure the Gandi LiveDNS API token is filled in the dyndns_data volume :

```text
/_data/gandi_ddns_token
```

---

## 📦 Docker Compose Stack 🛠️

### Services

- **Official NetBox containers.** from https://github.com/netbox-community/netbox-docker
- **`nginx`**: reverse proxy providing HTTPS on port `8443`.
- **`acme`**: Alpine container managing Let's Encrypt certificates with DNS challenge (via Gandi) and reloading Nginx when renewed.

The `acme` container runs a shell script (`acme_run.sh`) that:

1. Installs `acme.sh` if not present.
2. Uses the Gandi DNS API for issuing certs.
3. Automatically reloads Nginx via `docker exec nginx nginx -s reload`.
4. Runs in a loop, checking every 24h (`RENEW_INTERVAL=86400`).

The container needs the Docker socket:

```yaml
- /var/run/docker.sock:/var/run/docker.sock
```

### Volumes

- **`dyndns_data`**: Gandi token, dns and acme scripts, certs, etc.
- **`netbox-docker`**: netbox-docker source code (cloned through git) plus docker-compose.override.yml and nginx.conf
---

### 🌍 Required Environment Variables

- `netbox` container :

```env
ALLOWED_HOSTS=netbox.dromotherm.com localhost
CSRF_TRUSTED_ORIGINS=https://netbox.dromotherm.com:8443
```

> 🔐 These are essential for proper CSRF validation and host header checking in Django when served behind a proxy.

- `acme` container:

```env
DOMAIN=netbox.dromotherm.com
NGINX_CONTAINER_NAME=nginx
RENEW_INTERVAL=86400
```

---

## ✅ Key Takeaways

- ✅ No need to modify `netbox_docker/configration/configuration.py` manually.
- ✅ HTTPS works on custom port (`8443`).
- ✅ `ALLOWED_HOSTS` and `CSRF_TRUSTED_ORIGINS` are handled via env vars.
- ✅ Self-renewing, automated TLS setup using DNS challenge.
- ✅ Reusable approach for other reverse-proxied services.

---
