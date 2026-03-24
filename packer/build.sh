#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAR_FILE="$SCRIPT_DIR/packer.pkrvars.hcl"

if [ ! -f "$VAR_FILE" ]; then
    echo "Error: packer.pkrvars.hcl not found."
    echo "Run: cp packer.pkrvars.hcl.template packer.pkrvars.hcl && vim packer.pkrvars.hcl"
    exit 1
fi

# Extract proxmox_host from the var file
PVE_HOST=$(grep -oP 'proxmox_host\s*=\s*"\K[^"]+' "$VAR_FILE")
if [ -z "$PVE_HOST" ]; then
    echo "Error: proxmox_host not found in packer.pkrvars.hcl"
    exit 1
fi

PVE_USER="root"
SSH_KEY="${SSH_KEY:-~/.ssh/ovh-pve-01}"

echo "==> Opening SSH tunnels to $PVE_HOST"
echo "    -L 2222:192.168.10.5:22  (Packer SSH to VM)"
echo "    -R 192.168.10.1:8001:127.0.0.1:8001  (Preseed HTTP server)"

ssh -f -N \
    -L 2222:192.168.10.5:22 \
    -R 192.168.10.1:8001:127.0.0.1:8001 \
    -i "$SSH_KEY" \
    -o ExitOnForwardFailure=yes \
    -o ServerAliveInterval=30 \
    "$PVE_USER@$PVE_HOST"

cleanup() {
    echo "==> Closing SSH tunnels"
    pkill -f "ssh -f -N.*2222:192.168.10.5:22" 2>/dev/null || true
}
trap cleanup EXIT

echo "==> Running Packer build"
cd "$SCRIPT_DIR"
packer init .
packer build -var-file=packer.pkrvars.hcl .
