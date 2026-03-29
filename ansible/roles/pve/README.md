# Role: pve

Configure le reseau de l'hyperviseur Proxmox VE : bridges (vmbr0/1/2), VLAN-aware, SNAT/DNAT pour l'acces aux VMs.

## Variables

| Variable                | Default             | Description                  |
| ----------------------- | ------------------- | ---------------------------- |
| `pve_public_interface`  | `enp5s0f0`          | Interface WAN                |
| `pve_vlan_interface`    | `enp5s0f1`          | Interface VLAN (vers vmbr2)  |
| `pve_public_ip`         | `152.228.222.18/24` | IP publique OVH              |
| `pve_public_gateway`    | `152.228.222.254`   | Gateway OVH                  |
| `pve_mac_address`       | `a0:42:3f:49:50:1a` | MAC de l'interface publique  |
| `pve_management_ip`     | `192.168.10.1/29`   | IP management (vmbr1)        |
| `pve_management_subnet` | `192.168.10.0/29`   | Subnet management            |
| `pve_vlan_ids`          | `[10, 20, 30, 40]`  | VLANs configures sur vmbr2   |
| `pve_dnat_rules`        | voir ci-dessous     | Regles DNAT vers le firewall |

### pve_dnat_rules

```yaml
pve_dnat_rules:
  - comment: "DNAT for VPN access"
    proto: tcp
    public_port: 443
    dest_ip: "192.168.10.2"
    dest_port: 443
  - comment: "DNAT for SSH access to firewall"
    proto: tcp
    public_port: 2222
    dest_ip: "192.168.10.2"
    dest_port: 22
```

## ZFS Pool

| Variable              | Default          | Description                 |
| --------------------- | ---------------- | --------------------------- |
| `pve_zfs_pool_name`   | `data`           | Nom du pool ZFS             |
| `pve_zfs_compression` | `lz4`            | Algorithme de compression   |
| `pve_zfs_atime`       | `off`            | Access time tracking        |
| `pve_zfs_autotrim`    | `on`             | TRIM automatique (SSD/NVMe) |
| `pve_zfs_content`     | `images,rootdir` | Types de contenu PVE        |

## Bridges

| Bridge | Role       | Config                                               |
| ------ | ---------- | ---------------------------------------------------- |
| vmbr0  | WAN        | IP publique, gateway OVH                             |
| vmbr1  | Management | 192.168.10.0/29, SNAT vers vmbr0, DNAT vers firewall |
| vmbr2  | VLANs      | VLAN-aware, bridge-vids 10,20,30,40                  |
