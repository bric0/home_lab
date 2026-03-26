# Role: vpn

Installe Headscale (serveur VPN Tailscale self-hosted) en tant que service systemd. Obtient son certificat TLS via Let's Encrypt (TLS-ALPN-01, necessite que nginx soit deployé avant).

## Variables

| Variable                  | Default                                          | Description                |
| ------------------------- | ------------------------------------------------ | -------------------------- |
| `headscale_version`       | `0.28.0`                                         | Version de Headscale       |
| `headscale_arch`          | `amd64`                                          | Architecture CPU           |
| `vpn_fqdn`                | `vpn.bricoo.fr`                                  | FQDN du serveur VPN        |
| `vpn_listen_addr`         | `0.0.0.0:8080`                                   | Adresse d'ecoute Headscale |
| `vpn_acme_url`            | `https://acme-v02.api.letsencrypt.org/directory` | URL ACME Let's Encrypt     |
| `vpn_acme_challenge_type` | `TLS-ALPN-01`                                    | Type de challenge ACME     |
| `vpn_acme_email`          | `bric0l@proton.me`                               | Email pour Let's Encrypt   |
| `vpn_magicdns_fqdn`       | `mc.bricoo.fr`                                   | Domaine MagicDNS           |

## Taches

- Telecharge le paquet .deb Headscale depuis GitHub
- Installe le paquet
- Deploie `/etc/headscale/config.yaml`
- Active et demarre le service headscale

## Flux TLS

```
Internet:443 -> PVE DNAT -> Firewall:443 -> FW DNAT -> DMZ:443 (nginx)
  -> SNI vpn.bricoo.fr -> Headscale:8080 (TLS-ALPN-01 + trafic VPN)
```
