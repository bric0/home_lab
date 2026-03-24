#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

echo "==> Mise à jour du système"
apt-get update
apt-get upgrade -y

echo "==> Installation des paquets"
# cloud-init, qemu-guest-agent, sudo sont déjà installés par le preseed
apt-get install -y \
    ifupdown \
    nftables \
    openssh-server \
    python3 \
    curl \
    wget \
    vim \
    git \
    console-setup \
    keyboard-configuration

echo "==> Configuration clavier français"
cat > /etc/default/keyboard <<EOF
XKBMODEL="pc105"
XKBLAYOUT="fr"
XKBVARIANT=""
XKBOPTIONS=""
EOF
setupcon -k --force || true

echo "==> Noms d'interfaces legacy (eth0, eth1...)"
if ! grep -q 'net.ifnames=0' /etc/default/grub; then
    sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 net.ifnames=0 biosdevname=0"/' /etc/default/grub
fi
update-grub

echo "==> Configuration SSH"
sed -i 's/#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

echo "==> Configuration cloud-init pour Proxmox"
cat > /etc/cloud/cloud.cfg.d/99_pve.cfg <<'EOF'
datasource_list: [NoCloud, ConfigDrive]
system_info:
  network:
    renderers: ['eni']
    activators: ['eni']
EOF

echo "==> Activation qemu-guest-agent"
systemctl enable --now qemu-guest-agent || true

echo "==> Configuration sudo sans password"
echo "%sudo ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/cloud-init
chmod 0440 /etc/sudoers.d/cloud-init

echo "==> Nettoyage machine-id et clés SSH host"
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id
rm -f /etc/ssh/ssh_host_*

echo "==> Configuration terminée"
