# Deploiement Homelab

## Pre-requis

1. **Proxmox VE** configure avec `ansible-playbook pve.yaml` (bridges vmbr0/1/2, DNAT)
2. **VMs creees** via OpenTofu (`cd opentofu && tofu apply -parallelism=2`)
3. **SSH ProxyJump** configure dans `~/.ssh/config` pour atteindre les VMs internes via le firewall :
   ```
   Host homelab-firewall
     HostName 152.228.222.18
     Port 2222
     User brico
     IdentityFile ~/.ssh/ovh-homelab

   Host 10.10.0.* 10.20.0.* 10.30.0.* 10.40.0.*
     User brico
     IdentityFile ~/.ssh/ovh-homelab
     ProxyJump homelab-firewall
   ```
4. **Vault** configure dans `inventory/ovh-pve-01/group_vars/all/main.yaml`

## Architecture reseau

```
Internet
   |
   | 152.228.222.18
   |
[PVE - vmbr0] ----DNAT----> [vmbr1 - 192.168.10.0/29] -----> [Firewall VM]
                  :443->FW:443                                     |
                  :2222->FW:22                              eth0 (trunk)
                                                           /   |   |   \
                                                     .10  .20  .30  .40
                                                     DMZ  ADM  INF  PROD
                                                   /24    /24  /24   /16
```

| VLAN | Subnet | Gateway | Machines |
|------|--------|---------|----------|
| 10 - DMZ | 10.10.0.0/24 | 10.10.0.1 | dmz-01 (AdGuard, Nginx) |
| 20 - Admin | 10.20.0.0/24 | 10.20.0.1 | admin-01 |
| 30 - Infra | 10.30.0.0/24 | 10.30.0.1 | vpn-01 (Headscale), infra-01 (Portainer) |
| 40 - Prod | 10.40.0.0/16 | 10.40.0.1 | prod-01, prod-02 (+ Talos k8s) |

## Ordre de deploiement

### Etape 1 : Firewall (manuel)

```bash
ansible-playbook firewall.yaml
```

Configure le firewall VM comme routeur central :
- Interfaces VLAN (eth0.10/20/30/40)
- nftables (inter-VLAN, DNAT 443 -> DMZ, DNS, admin/VPN full access)
- DHCP relay (VLAN 40 -> AdGuard sur DMZ)
- sysctl IP forwarding

**Cible :** `homelab-firewall-01` (152.228.222.18:2222)

### Etape 2 : Docker + Portainer (manuel)

```bash
ansible-playbook portainer.yaml
```

Installe Docker CE et Portainer sur tous les docker_hosts :
- **homelab-infra-01** : Portainer Server (port 9443) + Agent (port 9001)
- **homelab-dmz-01, prod-01, prod-02** : Portainer Agent (port 9001)

**Cible :** `docker_hosts` (dmz-01, infra-01, prod-01, prod-02)

### Etape 3 : Bootstrap

```bash
ansible-playbook bootstrap.yaml
```

Enchaine les phases suivantes automatiquement :

#### Phase 3 - Portainer API
**Cible :** `homelab-infra-01`
- Initialise le compte admin Portainer
- Authentification API (JWT)
- Enregistre les 4 endpoints (agents) dans Portainer

#### Phase 4 - AdGuard Home
**Cible :** `homelab-dmz-01` puis `homelab-infra-01`
- Deploie la config AdGuard sur dmz-01
- Deploie le stack Docker via l'API Portainer
- DNS : upstream 1.1.1.1/8.8.8.8, custom records (vpn.bricoo.fr, portainer.bricoo.fr -> 10.10.0.10)

#### Phase 5 - Bascule DNS
**Cible :** `homelab-firewall-01` + `docker_hosts`
- Met a jour `/etc/resolv.conf` sur toutes les VMs pour pointer vers AdGuard (10.10.0.10)

#### Phase 5.5 - Nginx Reverse Proxy
**Cible :** `homelab-dmz-01` puis `homelab-infra-01`
- Deploie la config nginx sur dmz-01 (SNI routing + TLS termination)
- Obtient le certificat Let's Encrypt via DNS-01 (Cloudflare)
- Deploie le stack Docker via Portainer API
- Routage : `vpn.bricoo.fr:443` -> headscale:8080, `portainer.bricoo.fr:443` -> portainer:9443

#### Phase 6 - VPN (Headscale)
**Cible :** `homelab-vpn-01` puis `homelab-firewall-01`
1. Installe Headscale sur vpn-01 (systemd, TLS-ALPN-01 via nginx)
2. Cree un utilisateur + preauth key
3. Le firewall rejoint le tailnet et advertise toutes les routes (4 VLANs + management)
4. Approbation des routes sur headscale

### Etape 4 : Talos Kubernetes (optionnel)

```bash
ansible-playbook talos.yaml
```

Deploie un cluster Kubernetes Talos sur le VLAN Prod :
- Control plane : talos-cp-01 (10.40.0.101)
- Worker : talos-worker-01 (10.40.0.111)
- VIP API : 10.40.0.105:6443
- CNI : Cilium

## Variables globales

Definies dans `group_vars/all.yaml` :

| Variable | Valeur | Usage |
|----------|--------|-------|
| `dns_servers` | `["10.10.0.10"]` | DNS pour toutes les VMs |
| `vlans` | dmz/admin/infra/prod | Subnets et gateways |
| `management_subnet` | `192.168.10.0/29` | Reseau PVE <-> Firewall |
| `portainer_server_ip` | `10.30.0.20` | IP du serveur Portainer |
| `portainer_nodes` | 4 noeuds | Liste des endpoints Docker |

Definies dans `inventory/ovh-pve-01/group_vars/all/main.yaml` (vault) :

| Variable | Usage |
|----------|-------|
| `portainer_admin_user` | Compte admin Portainer |
| `portainer_admin_password` | Mot de passe admin |
| `cloudflare_api_token` | Token API Cloudflare (certbot DNS-01) |

## Roles Ansible

| Role | Description |
|------|-------------|
| [common](roles/common/) | Config de base : nftables flush, sysctl, DNS, desactive unattended-upgrades |
| [firewall](roles/firewall/) | Routeur central : VLAN interfaces, nftables, DNAT, DHCP relay, Tailscale |
| [docker](roles/docker/) | Installation Docker CE + docker-compose-plugin |
| [portainer](roles/portainer/) | Deploiement Portainer server ou agent selon le host |
| [portainer_api](roles/portainer_api/) | Client API Portainer : init admin, auth, endpoints, stacks |
| [adguard](roles/adguard/) | AdGuard Home : DNS + DHCP optionnel |
| [vpn](roles/vpn/) | Headscale VPN server (systemd) |
| [nginx_proxy](roles/nginx_proxy/) | Reverse proxy Nginx : SNI routing L4 + TLS termination L7 |
| [pihole](roles/pihole/) | Pi-hole DNS (legacy, remplace par AdGuard) |
| [pve](roles/pve/) | Config reseau Proxmox : bridges, VLAN-aware, DNAT |
| [talos](roles/talos/) | Cluster Kubernetes Talos avec Cilium CNI |
