# Role: adguard

Deploie la configuration d'AdGuard Home (DNS + DHCP optionnel). Le conteneur Docker est deploye separement via l'API Portainer.

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `adguard_upstream_dns` | `["1.1.1.1", "8.8.8.8"]` | Serveurs DNS upstream |
| `adguard_bootstrap_dns` | `["1.1.1.1"]` | DNS bootstrap (resolution initiale) |
| `adguard_dns_port` | `53` | Port DNS |
| `adguard_web_port` | `3000` | Port interface web |
| `adguard_data_dir` | `/opt/adguardhome` | Repertoire de donnees |
| `adguard_custom_dns` | voir ci-dessous | Enregistrements DNS personnalises |
| `adguard_dhcp_enabled` | `true` | Active le serveur DHCP |
| `adguard_dhcp_interface` | `eth0` | Interface DHCP |
| `adguard_dhcp_domain` | `lan` | Domaine local |
| `adguard_dhcp_gateway` | `10.40.0.1` | Gateway pour les clients DHCP |
| `adguard_dhcp_subnet_mask` | `255.255.0.0` | Masque de sous-reseau |
| `adguard_dhcp_range_start` | `10.40.0.100` | Debut de la plage DHCP |
| `adguard_dhcp_range_end` | `10.40.0.99` | Fin de la plage DHCP |
| `adguard_dhcp_lease_duration` | `86400` | Duree du bail (secondes) |

### adguard_custom_dns

```yaml
adguard_custom_dns:
  - domain: "vpn.bricoo.fr"
    answer: "10.10.0.10"
  - domain: "portainer.bricoo.fr"
    answer: "10.10.0.10"
```

## Taches

- Cree les repertoires `/opt/adguardhome/{work,conf}`
- Deploie `AdGuardHome.yaml` dans le repertoire conf
