# Role: nginx_proxy

Deploie un reverse proxy Nginx avec routage SNI (Layer 4) et terminaison TLS (Layer 7). Le conteneur Docker est deploye separement via l'API Portainer.

## Variables

| Variable                 | Default                   | Description                              |
| ------------------------ | ------------------------- | ---------------------------------------- |
| `nginx_proxy_data_dir`   | `/opt/nginx-proxy`        | Repertoire de travail                    |
| `nginx_proxy_acme_email` | `bric0l@proton.me`        | Email pour Let's Encrypt                 |
| `cloudflare_api_token`   | (vault)                   | Token API Cloudflare pour certbot DNS-01 |
| `portainer_server_ip`    | (group_vars) `10.30.0.20` | IP du serveur Portainer (backend L7)     |

## Routage

```
Port 443 (stream/L4 - SNI routing)
  |
  |-- vpn.bricoo.fr      -> 10.30.0.10:8080 (Headscale, passthrough TLS)
  |-- *                   -> 127.0.0.1:8443  (local L7)

Port 8443 (http/L7 - TLS termination)
  |
  |-- portainer.bricoo.fr -> https://10.30.0.20:9443 (Portainer)
```

## Taches

- Cree les repertoires
- Deploie `nginx.conf`
- Deploie les credentials Cloudflare (`cloudflare.ini`)
- Obtient le certificat Let's Encrypt via certbot DNS-01 (Cloudflare)
