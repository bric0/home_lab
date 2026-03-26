# Role: portainer

Deploie Portainer Server ou Agent selon le host. Le role determine automatiquement le type de deploiement en comparant `ansible_host` avec la liste `portainer_nodes`.

Depend du role `docker`.

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `portainer_server_image` | `portainer/portainer-ce:latest` | Image Docker du serveur |
| `portainer_agent_image` | `portainer/agent:latest` | Image Docker de l'agent |
| `portainer_server_data_dir` | `/opt/portainer-server` | Repertoire donnees serveur |
| `portainer_agent_data_dir` | `/opt/portainer-agent` | Repertoire donnees agent |
| `portainer_nodes` | `[]` (group_vars) | Liste des noeuds avec `name`, `ip`, `host_portainer` |

### portainer_nodes (group_vars/all.yaml)

```yaml
portainer_nodes:
  - name: "homelab-infra-01"
    ip: "10.30.0.20"
    host_portainer: true      # <- deploie le serveur ici
  - name: "homelab-dmz-01"
    ip: "10.10.0.10"
  - name: "homelab-prod-01"
    ip: "10.40.0.10"
  - name: "homelab-prod-02"
    ip: "10.40.0.20"
```

## Comportement

- Si `host_portainer: true` : deploie le serveur (port 9443) + l'agent (port 9001)
- Sinon : deploie l'agent uniquement (port 9001)
- Les hosts absents de `portainer_nodes` sont ignores
