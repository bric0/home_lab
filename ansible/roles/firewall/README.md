# Role: firewall

Configure la VM firewall comme routeur central du homelab. Met en place les interfaces VLAN, les regles nftables inter-VLAN, le DNAT vers la DMZ, le relais DHCP et l'integration Tailscale.

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `firewall_management_ip` | `192.168.10.2/29` | IP interface management (eth1) |
| `firewall_management_gateway` | `192.168.10.1` | Gateway management (PVE) |
| `firewall_dns_servers` | `10.10.0.10` | DNS pour l'interface management |
| `firewall_vlans` | voir ci-dessous | Liste des VLANs avec ID et adresse |
| `headscale_url` | `https://vpn.bricoo.fr` | URL du serveur Headscale |
| `tailscale_authkey` | `""` | Cle d'authentification Tailscale |
| `advertise_routes` | 5 subnets | Routes annoncees via Tailscale |
| `firewall_dnat_rules` | 1 regle | Regles DNAT (eth1 TCP 443 -> 10.10.0.10:443) |
| `dhcp_relay_server` | `10.10.0.10` | IP du serveur DHCP (AdGuard) |
| `dhcp_relay_interfaces` | `[eth0.40, eth0.10]` | Interfaces pour le relais DHCP |
| `sysctl_settings` | `{net.ipv4.ip_forward: 1, ...}` | IP forwarding active |

### firewall_vlans

```yaml
firewall_vlans:
  - id: 10
    address: "10.10.0.1/24"   # DMZ
  - id: 20
    address: "10.20.0.1/24"   # Admin
  - id: 30
    address: "10.30.0.1/24"   # Infra
  - id: 40
    address: "10.40.0.1/16"   # Prod
```

## Taches

- `setup.yaml` : Desactive cloud-init networking, charge 8021q, deploie interfaces
- `nftables.yaml` : Regles firewall (filter + nat)
- `dhcp-relay.yaml` : Installe et configure isc-dhcp-relay
- `join-tailscale.yaml` : Installe Tailscale (curl + apt)
