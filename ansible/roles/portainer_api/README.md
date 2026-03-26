# Role: portainer_api

Client API Portainer. Fournit des taches individuelles pour initialiser l'admin, s'authentifier, enregistrer des endpoints et deployer des stacks Docker.

Ce role ne s'execute pas directement - ses taches sont appelees via `include_role` + `tasks_from`.

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `portainer_api_url` | `https://127.0.0.1:9443/api` | URL de l'API Portainer |
| `portainer_api_validate_certs` | `false` | Validation des certificats TLS |
| `portainer_admin_user` | (vault) | Nom d'utilisateur admin |
| `portainer_admin_password` | (vault) | Mot de passe admin |

## Taches disponibles

| Tache | Usage | Variables requises |
|-------|-------|--------------------|
| `init_admin.yaml` | Cree le compte admin (si 404) | `portainer_admin_user`, `portainer_admin_password` |
| `authenticate.yaml` | Obtient un JWT, stocke dans `portainer_jwt` | `portainer_admin_user`, `portainer_admin_password` |
| `register_endpoint.yaml` | Enregistre un agent (type 2) | `endpoint_node` ({name, ip}) |
| `deploy_stack.yaml` | Cree/met a jour un stack | `stack` ({name, endpoint_name, compose_content}) |

## Exemple

```yaml
- name: Deploy a stack
  ansible.builtin.include_role:
    name: portainer_api
    tasks_from: deploy_stack.yaml
  vars:
    stack:
      name: "my-stack"
      endpoint_name: "homelab-dmz-01"
      compose_content: "{{ lookup('template', 'docker-compose.yaml.j2') }}"
```
