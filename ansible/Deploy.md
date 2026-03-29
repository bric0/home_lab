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

## Pattern de deploiement Portainer

Les services Docker ne sont **pas** deployes directement avec `docker compose` sur les VMs.
Ils passent par l'API Portainer, centralisee sur `homelab-infra-01` (10.30.0.20).

Chaque service Docker suit un deploiement en 2 plays :

```
Play 1 - Config (SSH direct sur le host cible)
  |  Le role Ansible deploie les fichiers de config, certificats, etc.
  |  Ex: /opt/adguardhome/conf/AdGuardHome.yaml
  v
Play 2 - Stack (via API Portainer sur homelab-infra-01)
  1. Charger les variables du role   (include_vars)
  2. S'authentifier a l'API          (portainer_api/authenticate.yaml -> portainer_jwt)
  3. Rendre le docker-compose        (lookup template -> set_fact)
  4. Deployer le stack                (portainer_api/deploy_stack.yaml)
     -> Cree le stack si inexistant
     -> Met a jour si deja present (pull image + prune)
```

Ce pattern est utilise pour **AdGuard** (phase 4), **Nginx** (phase 5.5), et tout futur service Docker.

Les playbooks standalone (`adguard.yaml`, `nginx_proxy.yaml`) suivent le meme pattern et peuvent etre relances pour mettre a jour un service individuellement.

### Exemple : deployer un nouveau service

```yaml
# 1. Creer le role avec config + docker-compose template
# roles/mon-service/defaults/main.yaml
# roles/mon-service/tasks/main.yaml       <- deploie les fichiers de config
# roles/mon-service/templates/docker-compose.yaml.j2

# 2. Playbook standalone (mon-service.yaml)
- name: Deploy config files
  hosts: homelab-dmz-01          # host cible
  become: true
  roles:
    - mon-service

- name: Deploy stack via Portainer
  hosts: homelab-infra-01        # toujours infra-01 (serveur Portainer)
  gather_facts: false
  tasks:
    - name: Load defaults
      ansible.builtin.include_vars:
        file: roles/mon-service/defaults/main.yaml

    - name: Authenticate
      ansible.builtin.include_role:
        name: portainer_api
        tasks_from: authenticate.yaml

    - name: Render compose
      ansible.builtin.set_fact:
        _compose: "{{ lookup('template', 'roles/mon-service/templates/docker-compose.yaml.j2') }}"

    - name: Deploy stack
      ansible.builtin.include_role:
        name: portainer_api
        tasks_from: deploy_stack.yaml
      vars:
        stack:
          name: "mon-service"
          endpoint_name: "homelab-dmz-01"
          compose_content: "{{ _compose }}"
```

### Infrastructure Portainer

```
homelab-infra-01 (10.30.0.20)          <- Portainer Server (port 9443) + Agent
       |
       |--- API (portainer_api role) -------> Gere les stacks Docker sur :
       |                                        homelab-infra-01  (agent :9001)
       |                                        homelab-dmz-01    (agent :9001)
       |                                        homelab-prod-01   (agent :9001)
       |                                        homelab-prod-02   (agent :9001)
```

Les endpoints sont enregistres dans Portainer en Phase 3 du bootstrap.
Le `endpoint_name` dans `deploy_stack.yaml` correspond au `name` dans `portainer_nodes` (group_vars/all.yaml).

## Deploiement from scratch

### Etape 1 : Firewall

```bash
ansible-playbook firewall.yaml
```

Configure le firewall VM comme routeur central.
Roles : `common` (IP forwarding) + `firewall` (VLAN interfaces, nftables, DHCP relay).

**Cible :** `homelab-firewall-01` (152.228.222.18:2222)
**Apres cette etape :** les VMs internes sont joignables via le firewall (SSH ProxyJump).

### Etape 2 : Docker + Portainer

```bash
ansible-playbook portainer.yaml
```

Installe Docker CE et Portainer sur les 4 docker_hosts.
Le role `portainer` detecte automatiquement le type (server/agent) via `portainer_nodes`.

**Cible :** `docker_hosts` (dmz-01, infra-01, prod-01, prod-02)
**Apres cette etape :** Portainer server tourne sur infra-01:9443, les agents ecoutent sur :9001.

### Etape 3 : Bootstrap

```bash
ansible-playbook bootstrap.yaml
```

Enchaine automatiquement les phases suivantes :

#### Phase 3 - Init Portainer API
**Cible :** `homelab-infra-01`

Initialise Portainer pour pouvoir deployer des stacks :
1. Cree le compte admin (`portainer_api/init_admin.yaml`)
2. Obtient un JWT (`portainer_api/authenticate.yaml`)
3. Enregistre les 4 endpoints agents (`portainer_api/register_endpoint.yaml` en boucle sur `portainer_nodes`)

**Apres cette etape :** l'API Portainer est prete, les stacks peuvent etre deployes sur n'importe quel endpoint.

#### Phase 4 - AdGuard Home (pattern Portainer)
**Cible :** `homelab-dmz-01` puis `homelab-infra-01`

1. **Play config :** le role `adguard` deploie `AdGuardHome.yaml` sur dmz-01
   - Upstream DNS : 1.1.1.1, 8.8.8.8
   - Custom DNS : vpn.bricoo.fr, portainer.bricoo.fr -> 10.10.0.10
   - DHCP : plage 10.40.0.100-10.40.0.99 (VLAN Prod via relay)
2. **Play stack :** deploie le conteneur AdGuard sur l'endpoint `homelab-dmz-01` via Portainer API

**Apres cette etape :** AdGuard repond sur 10.10.0.10:53.

#### Phase 5 - Bascule DNS
**Cible :** `homelab-firewall-01` + `docker_hosts`

Met a jour `/etc/resolv.conf` sur toutes les VMs pour pointer vers AdGuard (10.10.0.10).

**Apres cette etape :** toute l'infra utilise AdGuard comme DNS.

#### Phase 5.5 - Nginx Reverse Proxy (pattern Portainer)
**Cible :** `homelab-dmz-01` puis `homelab-infra-01`

1. **Play config :** le role `nginx_proxy` deploie nginx.conf + obtient le certificat Let's Encrypt (DNS-01 Cloudflare)
2. **Play stack :** deploie le conteneur Nginx sur l'endpoint `homelab-dmz-01` via Portainer API

Routage nginx :
```
:443 (L4 SNI) -> vpn.bricoo.fr       -> 10.30.0.10:8080 (Headscale)
              -> *                    -> 127.0.0.1:8443 (L7 TLS termination)
:8443 (L7)   -> portainer.bricoo.fr  -> 10.30.0.20:9443 (Portainer)
```

**Apres cette etape :** les services sont accessibles depuis Internet via vpn.bricoo.fr et portainer.bricoo.fr.

#### Phase 6 - VPN Headscale
**Cible :** `homelab-vpn-01` puis `homelab-firewall-01`

Headscale est un service **systemd** (pas Docker), donc pas de pattern Portainer ici.

1. **6.1** : Installe Headscale sur vpn-01 (roles `common` + `vpn`). Le certificat TLS est obtenu via ACME TLS-ALPN-01, le trafic arrive via nginx (Phase 5.5).
2. **6.2** : Cree un utilisateur headscale + preauth key (1h, reusable)
3. **6.3** : Le firewall rejoint le tailnet (`tailscale up --login-server=https://vpn.bricoo.fr`) et advertise les routes :
   - 10.10.0.0/24, 10.20.0.0/24, 10.30.0.0/24, 10.40.0.0/16, 192.168.10.0/29
4. **6.4** : Approbation des routes sur headscale

**Apres cette etape :** l'infra est accessible via VPN Tailscale depuis n'importe ou.

### Etape 4 : Talos Kubernetes (optionnel)

```bash
ansible-playbook talos.yaml
```

Deploie un cluster Kubernetes Talos sur le VLAN Prod.
S'execute en local (talosctl), pas de SSH vers les noeuds Talos.

- Control plane : talos-cp-01 (10.40.0.101), VIP : 10.40.0.105
- Worker : talos-worker-01 (10.40.0.111)
- CNI : Cilium

## Mise a jour d'un service

Pour mettre a jour la config d'un service existant, relancer son playbook standalone.
Le pattern Portainer gere l'idempotence : le stack est cree s'il n'existe pas, mis a jour sinon (pull image + prune).

```bash
# Modifier roles/adguard/defaults/main.yaml ou templates, puis :
ansible-playbook adguard.yaml

# Idem pour nginx :
ansible-playbook nginx_proxy.yaml
```

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
