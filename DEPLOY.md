# Déploiement from scratch → VPN

## Chaîne d'accès SSH

```
Machine locale
  │
  ├── SSH :22 ──────────► PVE (152.228.222.18)          [direct, clé ovh-pve-01]
  │
  ├── SSH :2222 ────────► Firewall (192.168.10.2)        [DNAT par PVE, clé ovh-homelab]
  │
  └── SSH ProxyJump :2222 ──► Firewall ──► VMs VLAN      [clé ovh-homelab]
          ├── 10.10.0.10  (pihole, VLAN 10)
          ├── 10.20.0.10  (admin, VLAN 20)
          └── 10.30.0.10  (vpn, VLAN 30)
```

## Étape 1 — Configurer le PVE

```bash
cd ansible
ansible-playbook -i inventory/ovh-pve-01/main.yaml pve.yaml
```

- Connexion : SSH direct `root@152.228.222.18:22`
- Déploie les interfaces (vmbr0/1/2, DNAT, VLANs), active GatewayPorts
- Résultat : port 2222 → firewall:22, port 443 → firewall:443

## Étape 2 — Builder le template Packer

```bash
cd packer
cp packer.pkrvars.hcl.template packer.pkrvars.hcl
vim packer.pkrvars.hcl
./build.sh
```

- Le script ouvre les tunnels SSH automatiquement
- Résultat : template VM 9000 prêt sur le PVE

## Étape 3 — Déployer les VMs avec OpenTofu

```bash
cd opentofu
cp .env.template .env && vim .env
source .env
tofu init && tofu apply
```

- Crée 4 VMs : firewall, pihole, admin, vpn
- Cloud-init configure les IPs et le user `brico` avec la clé SSH
- **Le firewall est immédiatement joignable** sur 152.228.222.18:2222
- **Les VMs VLAN sont isolées** jusqu'à l'étape 4

## Étape 4 — Configurer le firewall (débloque les VLANs)

```bash
cd ansible
ansible-playbook -i inventory/ovh-pve-01/main.yaml firewall.yaml
```

- Connexion : SSH `brico@152.228.222.18:2222` (DNAT → firewall)
- Installe VLAN/8021q, interfaces eth0.10/20/30/40, nftables, ip_forward
- **Résultat : les VMs VLAN peuvent atteindre leur gateway et internet**

## Étape 5 — Configurer le VPN (Headscale)

```bash
ansible-playbook -i inventory/ovh-pve-01/main.yaml vpn.yaml
```

- Connexion : ProxyJump via firewall → 10.30.0.10
- Installe headscale, TLS-ALPN-01 via Let's Encrypt
- Résultat : VPN accessible sur `vpn.bricoo.fr:443`

## Étape 6 — Configurer AdGuard Home

```bash
ansible-playbook -i inventory/ovh-pve-01/main.yaml adguard.yaml
```

- Connexion : ProxyJump via firewall → 10.10.0.10
- Installe Docker + AdGuard Home (DNS) pour tous les VLANs

## Vérification

1. PVE : `ssh root@152.228.222.18 "ip a show vmbr1"`
2. Packer : template 9000 dans `qm list`
3. OpenTofu : `ssh brico@152.228.222.18 -p 2222`
4. Firewall : `ssh -o ProxyJump=brico@152.228.222.18:2222 brico@10.30.0.10`
5. VPN : `curl https://vpn.bricoo.fr`
6. AdGuard Home : `dig @10.10.0.10 google.com`
