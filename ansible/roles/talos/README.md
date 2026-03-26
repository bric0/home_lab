# Role: talos

Genere et applique les configurations pour un cluster Kubernetes Talos avec Cilium CNI. S'execute en local (pas de connexion SSH aux noeuds Talos).

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `talos_cluster_name` | `home` | Nom du cluster |
| `talos_cluster_endpoint` | `https://10.40.0.105:6443` | Endpoint API Kubernetes (VIP) |
| `talos_version` | `v1.12.2` | Version Talos OS |
| `talos_kubernetes_version` | `v1.35.0` | Version Kubernetes |
| `talos_machineconfigs_dir` | `{{ playbook_dir }}/machineconfigs` | Repertoire de sortie des configs |
| `talos_pod_cidr` | `10.40.10.0/23` | CIDR des pods |
| `talos_service_cidr` | `10.40.20.0/24` | CIDR des services |
| `talos_gateway` | `10.40.0.1` | Gateway par defaut |
| `talos_node_cidr` | `16` | Prefix CIDR des noeuds |
| `talos_dns_server` | `10.40.0.1` | Serveur DNS des noeuds |
| `talos_ntp_server` | `time.cloudflare.com` | Serveur NTP |
| `talos_vip` | `10.40.0.105` | VIP pour l'API Kubernetes |
| `talos_region` | `homelab` | Label region |
| `talos_zone` | `ovh-pve-01` | Label zone |
| `talos_cilium_version` | `1.18.6` | Version Cilium CNI |
| `talos_install_image` | (factory URL) | Image d'installation Talos |
| `talos_nodes` | voir ci-dessous | Liste des noeuds |
| `talos_apply` | `true` | Appliquer les configs aux noeuds |
| `talos_apply_insecure` | `false` | Mode insecure |
| `talos_apply_mode` | `auto` | Mode d'application (auto/staged/reboot) |

### talos_nodes

```yaml
talos_nodes:
  - hostname: "talos-cp-01"
    ip: "10.40.0.101"
    is_controlplane: true
    install_disk: "/dev/sda"
  - hostname: "talos-worker-01"
    ip: "10.40.0.111"
    is_controlplane: false
    install_disk: "/dev/sda"
```

## Taches

1. `generate-manifests.yaml` : Genere le manifeste Cilium via Helm
2. `prepare.yaml` : Prepare les patches (common, controlplane, worker)
3. `generate-node.yaml` : Genere les machineconfigs par noeud avec talosctl
4. `apply.yaml` : Applique les configs aux noeuds
