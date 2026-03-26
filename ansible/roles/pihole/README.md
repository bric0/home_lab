# Role: pihole

Installe Pi-hole comme serveur DNS. Ce role est legacy, remplace par AdGuard Home.

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `pihole_interface` | `eth0` | Interface reseau |
| `pihole_upstream_dns_1` | `1.1.1.1` | DNS upstream primaire |
| `pihole_upstream_dns_2` | `8.8.8.8` | DNS upstream secondaire |
| `pihole_web_password` | `""` | Mot de passe interface web |
| `pihole_custom_dns` | `[{ip: "10.30.0.10", hostname: "vpn.bricoo.fr"}]` | Enregistrements DNS personnalises |

## Taches

- Installe les dependances
- Deploie `setupVars.conf` (installation non-interactive)
- Execute l'installateur Pi-hole
- Configure le mot de passe web et les DNS personnalises
