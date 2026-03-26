# Role: common

Configuration de base appliquée a toutes les VMs. Deploie un nftables minimal (flush ruleset), configure les parametres sysctl, le DNS et desactive les mises a jour automatiques.

## Variables

| Variable          | Default                                                                                              | Description                                             |
| ----------------- | ---------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| `sysctl_settings` | `{net.ipv4.ip_forward: 0, net.ipv6.conf.all.disable_ipv6: 1, net.ipv6.conf.default.disable_ipv6: 1}` | Parametres noyau. Le firewall override `ip_forward` a 1 |
| `dns_servers`     | (group_vars) `["10.10.0.10"]`                                                                        | Liste des serveurs DNS pour `/etc/resolv.conf`          |

## Taches

- `main.yaml` : nftables base, sysctl, DNS, desactive unattended-upgrades
- `dns.yaml` : Deploie `/etc/resolv.conf` (peut etre appele seul)

## Templates

- `nftables-base.conf.j2` : `flush ruleset` uniquement
- `sysctl.conf.j2` : Boucle sur `sysctl_settings`
- `resolv.conf.j2` : Boucle sur `dns_servers`
