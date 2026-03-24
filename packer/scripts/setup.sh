#!/bin/bash
set -e

# Variables d'environnement pour éviter les prompts
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

echo "==> Configuration du système pour Cloud-Init"

# Mise à jour
apt-get update
apt-get upgrade -y

# Installation des paquets essentiels
apt-get install -y \
    cloud-init \
    ifupdown \
    qemu-guest-agent \
    sudo \
    openssh-server \
    curl \
    wget \
    vim \
    git \
    console-setup \
    keyboard-configuration

# Configuration clavier français
cat > /etc/default/keyboard <<EOF
XKBMODEL="pc105"
XKBLAYOUT="fr"
XKBVARIANT=""
XKBOPTIONS=""
EOF

# Appliquer la configuration clavier
setupcon -k --force || true

echo "==> Configuration des noms d'interfaces (eth0, eth1...)"
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 net.ifnames=0 biosdevname=0"/' /etc/default/grub
update-grub

# Configuration SSH - Autoriser root login
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

systemctl restart sshd

cat > /etc/cloud/cloud.cfg.d/99_pve.cfg <<'EOF'
# Datasources
datasource_list: [NoCloud, ConfigDrive]

# Network renderer ENI (doc: https://cloudinit.readthedocs.io/)
system_info:
  network:
    renderers: ['eni']
    activators: ['eni']
EOF

# Démarrer qemu-guest-agent
systemctl start qemu-guest-agent || true
systemctl status qemu-guest-agent --no-pager || true

# Configuration sudo sans password
echo "%sudo ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/cloud-init
chmod 0440 /etc/sudoers.d/cloud-init

# Nettoyer machine-id
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

# Nettoyage des clés SSH host
rm -f /etc/ssh/ssh_host_*

echo "==> Configuration terminée"
