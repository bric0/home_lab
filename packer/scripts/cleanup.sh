#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

echo "==> Nettoyage final pour template"

# Désactiver root login (n'était activé que pour le build Packer)
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

cloud-init clean --machine-id --logs --seed

# Supprimer tous les artifacts cloud-init
rm -rf /var/lib/cloud/instances/*
rm -rf /var/lib/cloud/instance
rm -rf /var/lib/cloud/data
rm -rf /var/lib/cloud/seed
rm -rf /run/cloud-init

# Supprimer la config réseau Debian (pour que cloud-init prenne le contrôle)
rm -f /etc/network/interfaces.d/*
cat > /etc/network/interfaces <<'EOF'
source /etc/network/interfaces.d/*
auto lo
iface lo inet loopback
EOF

# Nettoyer DHCP leases
rm -f /var/lib/dhcp/*

# Nettoyer les règles udev réseau
rm -f /etc/udev/rules.d/70-persistent-net.rules

# Nettoyer logs
find /var/log -type f -exec truncate -s 0 {} \;
rm -f /root/.bash_history
history -c

# Nettoyage apt
apt-get clean
apt-get autoremove -y

sync
echo "==> Template prêt"
