# Role: docker

Installe Docker CE et le plugin docker-compose depuis le depot officiel Docker.

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `docker_arch` | `amd64` | Architecture CPU |

## Taches

- Installe les pre-requis (ca-certificates, curl, gnupg)
- Ajoute la cle GPG et le depot APT Docker
- Installe docker-ce, docker-ce-cli, containerd.io, docker-compose-plugin
- Active et demarre le service Docker
